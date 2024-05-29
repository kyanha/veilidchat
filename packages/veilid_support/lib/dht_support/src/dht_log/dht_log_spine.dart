part of 'dht_log.dart';

class _DHTLogPosition extends DHTCloseable<_DHTLogPosition, DHTShortArray> {
  _DHTLogPosition._({
    required _DHTLogSpine dhtLogSpine,
    required this.shortArray,
    required this.pos,
    required int segmentNumber,
  })  : _dhtLogSpine = dhtLogSpine,
        _segmentNumber = segmentNumber;
  final int pos;

  final _DHTLogSpine _dhtLogSpine;
  final DHTShortArray shortArray;
  var _openCount = 1;
  final int _segmentNumber;
  final Mutex _mutex = Mutex();

  /// Check if the DHTLogPosition is open
  @override
  bool get isOpen => _openCount > 0;

  /// The type of the openable scope
  @override
  FutureOr<DHTShortArray> scoped() => shortArray;

  /// Add a reference to this log
  @override
  Future<_DHTLogPosition> ref() async => _mutex.protect(() async {
        _openCount++;
        return this;
      });

  /// Free all resources for the DHTLogPosition
  @override
  Future<void> close() async => _mutex.protect(() async {
        if (_openCount == 0) {
          throw StateError('already closed');
        }
        _openCount--;
        if (_openCount != 0) {
          return;
        }
        await _dhtLogSpine._segmentClosed(_segmentNumber);
      });
}

class _OpenedSegment {
  _OpenedSegment._({
    required this.shortArray,
  });

  final DHTShortArray shortArray;
  int openCount = 1;
}

class _DHTLogSegmentLookup extends Equatable {
  const _DHTLogSegmentLookup({required this.subkey, required this.segment});
  final int subkey;
  final int segment;

  @override
  List<Object?> get props => [subkey, segment];
}

class _SubkeyData {
  _SubkeyData({required this.subkey, required this.data});
  int subkey;
  Uint8List data;
  bool changed = false;
}

class _DHTLogSpine {
  _DHTLogSpine._(
      {required DHTRecord spineRecord,
      required int head,
      required int tail,
      required int stride})
      : _spineRecord = spineRecord,
        _head = head,
        _tail = tail,
        _segmentStride = stride,
        _openedSegments = {},
        _spineCache = [];

  // Create a new spine record and push it to the network
  static Future<_DHTLogSpine> create(
      {required DHTRecord spineRecord, required int segmentStride}) async {
    // Construct new spinehead
    final spine = _DHTLogSpine._(
        spineRecord: spineRecord, head: 0, tail: 0, stride: segmentStride);

    // Write new spine head record to the network
    await spine.operate((spine) async {
      final success = await spine.writeSpineHead();
      assert(success, 'false return should never happen on create');
    });

    return spine;
  }

  // Pull the latest or updated copy of the spine head record from the network
  static Future<_DHTLogSpine> load({required DHTRecord spineRecord}) async {
    // Get an updated spine head record copy if one exists
    final spineHead = await spineRecord.getProtobuf(proto.DHTLog.fromBuffer,
        subkey: 0, refreshMode: DHTRecordRefreshMode.network);
    if (spineHead == null) {
      throw StateError('spine head missing during refresh');
    }
    return _DHTLogSpine._(
        spineRecord: spineRecord,
        head: spineHead.head,
        tail: spineHead.tail,
        stride: spineHead.stride);
  }

  proto.DHTLog _toProto() {
    assert(_spineMutex.isLocked, 'should be in mutex here');

    final logHead = proto.DHTLog()
      ..head = _head
      ..tail = _tail
      ..stride = _segmentStride;
    return logHead;
  }

  Future<void> close() async {
    await _spineMutex.protect(() async {
      if (!isOpen) {
        return;
      }
      final futures = <Future<void>>[_spineRecord.close()];
      for (final (_, sc) in _spineCache) {
        futures.add(sc.close());
      }
      await Future.wait(futures);

      assert(_openedSegments.isEmpty, 'should have closed all segments by now');
    });
  }

  Future<void> delete() async {
    await _spineMutex.protect(() async {
      // Will deep delete all segment records as they are children
      await _spineRecord.delete();
    });
  }

  Future<T> operate<T>(Future<T> Function(_DHTLogSpine) closure) async =>
      // ignore: prefer_expression_function_bodies
      _spineMutex.protect(() async {
        return closure(this);
      });

  Future<T> operateAppend<T>(Future<T> Function(_DHTLogSpine) closure) async =>
      _spineMutex.protect(() async {
        final oldHead = _head;
        final oldTail = _tail;
        try {
          final out = await closure(this);
          // Write head assuming it has been changed
          if (!await writeSpineHead(old: (oldHead, oldTail))) {
            // Failed to write head means head got overwritten so write should
            // be considered failed
            throw DHTExceptionTryAgain();
          }
          return out;
        } on Exception {
          // Exception means state needs to be reverted
          _head = oldHead;
          _tail = oldTail;
          rethrow;
        }
      });

  Future<void> operateAppendEventual(
      Future<bool> Function(_DHTLogSpine) closure,
      {Duration? timeout}) async {
    final timeoutTs = timeout == null
        ? null
        : Veilid.instance.now().offset(TimestampDuration.fromDuration(timeout));

    await _spineMutex.protect(() async {
      late int oldHead;
      late int oldTail;

      try {
        // Iterate until we have a successful element and head write
        do {
          // Save off old values each pass of writeSpineHead because the head
          // will have changed
          oldHead = _head;
          oldTail = _tail;

          // Try to do the element write
          while (true) {
            if (timeoutTs != null) {
              final now = Veilid.instance.now();
              if (now >= timeoutTs) {
                throw TimeoutException('timeout reached');
              }
            }
            if (await closure(this)) {
              break;
            }
            // Failed to write in closure resets state
            _head = oldHead;
            _tail = oldTail;
          }

          // Try to do the head write
        } while (!await writeSpineHead(old: (oldHead, oldTail)));
      } on Exception {
        // Exception means state needs to be reverted
        _head = oldHead;
        _tail = oldTail;
        rethrow;
      }
    });
  }

  /// Serialize and write out the current spine head subkey, possibly updating
  /// it if a newer copy is available online. Returns true if the write was
  /// successful
  Future<bool> writeSpineHead({(int, int)? old}) async {
    assert(_spineMutex.isLocked, 'should be in mutex here');

    final headBuffer = _toProto().writeToBuffer();

    final existingData = await _spineRecord.tryWriteBytes(headBuffer);
    if (existingData != null) {
      // Head write failed, incorporate update
      await _updateHead(proto.DHTLog.fromBuffer(existingData));
      if (old != null) {
        sendUpdate(old.$1, old.$2);
      }
      return false;
    }
    if (old != null) {
      sendUpdate(old.$1, old.$2);
    }
    return true;
  }

  /// Send a spine update callback
  void sendUpdate(int oldHead, int oldTail) {
    final oldLength = _ringDistance(oldTail, oldHead);
    if (oldHead != _head || oldTail != _tail || oldLength != length) {
      onUpdatedSpine?.call(DHTLogUpdate(
          headDelta: _ringDistance(_head, oldHead),
          tailDelta: _ringDistance(_tail, oldTail),
          length: length));
    }
  }

  /// Validate a new spine head subkey that has come in from the network
  Future<void> _updateHead(proto.DHTLog spineHead) async {
    assert(_spineMutex.isLocked, 'should be in mutex here');

    _head = spineHead.head;
    _tail = spineHead.tail;
  }

  /////////////////////////////////////////////////////////////////////////////
  // Spine element management

  static final Uint8List _emptySegmentKey =
      Uint8List.fromList(List.filled(TypedKey.decodedLength<TypedKey>(), 0));
  static Uint8List _makeEmptySubkey() => Uint8List.fromList(List.filled(
      DHTLog.segmentsPerSubkey * TypedKey.decodedLength<TypedKey>(), 0));

  static TypedKey? _getSegmentKey(Uint8List subkeyData, int segment) {
    final decodedLength = TypedKey.decodedLength<TypedKey>();
    final segmentKeyBytes = subkeyData.sublist(
        decodedLength * segment, decodedLength * (segment + 1));
    if (segmentKeyBytes.equals(_emptySegmentKey)) {
      return null;
    }
    return TypedKey.fromBytes(segmentKeyBytes);
  }

  static void _setSegmentKey(
      Uint8List subkeyData, int segment, TypedKey? segmentKey) {
    final decodedLength = TypedKey.decodedLength<TypedKey>();
    late final Uint8List segmentKeyBytes;
    if (segmentKey == null) {
      segmentKeyBytes = _emptySegmentKey;
    } else {
      segmentKeyBytes = segmentKey.decode();
    }
    subkeyData.setRange(decodedLength * segment, decodedLength * (segment + 1),
        segmentKeyBytes);
  }

  Future<DHTShortArray> _openOrCreateSegmentInner(int segmentNumber) async {
    assert(_spineMutex.isLocked, 'should be in mutex here');
    assert(_spineRecord.writer != null, 'should be writable');

    // Lookup what subkey and segment subrange has this position's segment
    // shortarray
    final l = _lookupSegment(segmentNumber);
    final subkey = l.subkey;
    final segment = l.segment;

    var subkeyData = await _spineRecord.get(subkey: subkey);
    subkeyData ??= _makeEmptySubkey();
    while (true) {
      final segmentKey = _getSegmentKey(subkeyData!, segment);
      if (segmentKey == null) {
        // Create a shortarray segment
        final segmentRec = await DHTShortArray.create(
          debugName: '${_spineRecord.debugName}_spine_${subkey}_$segment',
          stride: _segmentStride,
          crypto: _spineRecord.crypto,
          parent: _spineRecord.key,
          routingContext: _spineRecord.routingContext,
          writer: _spineRecord.writer,
        );
        var success = false;
        try {
          // Write it back to the spine record
          _setSegmentKey(subkeyData, segment, segmentRec.recordKey);
          subkeyData =
              await _spineRecord.tryWriteBytes(subkeyData, subkey: subkey);
          // If the write was successful then we're done
          if (subkeyData == null) {
            // Return it
            success = true;
            return segmentRec;
          }
        } finally {
          if (!success) {
            await segmentRec.close();
            await segmentRec.delete();
          }
        }
      } else {
        // Open a shortarray segment
        final segmentRec = await DHTShortArray.openWrite(
          segmentKey,
          _spineRecord.writer!,
          debugName: '${_spineRecord.debugName}_spine_${subkey}_$segment',
          crypto: _spineRecord.crypto,
          parent: _spineRecord.key,
          routingContext: _spineRecord.routingContext,
        );
        return segmentRec;
      }
      // Loop if we need to try again with the new data from the network
    }
  }

  Future<DHTShortArray?> _openSegmentInner(int segmentNumber) async {
    assert(_spineMutex.isLocked, 'should be in mutex here');

    // Lookup what subkey and segment subrange has this position's segment
    // shortarray
    final l = _lookupSegment(segmentNumber);
    final subkey = l.subkey;
    final segment = l.segment;

    final subkeyData = await _spineRecord.get(subkey: subkey);
    if (subkeyData == null) {
      return null;
    }
    final segmentKey = _getSegmentKey(subkeyData, segment);
    if (segmentKey == null) {
      return null;
    }

    // Open a shortarray segment
    final segmentRec = await DHTShortArray.openRead(
      segmentKey,
      debugName: '${_spineRecord.debugName}_spine_${subkey}_$segment',
      crypto: _spineRecord.crypto,
      parent: _spineRecord.key,
      routingContext: _spineRecord.routingContext,
    );
    return segmentRec;
  }

  Future<DHTShortArray> _openOrCreateSegment(int segmentNumber) async {
    assert(_spineMutex.isLocked, 'should be in mutex here');

    // See if we already have this in the cache
    for (var i = 0; i < _spineCache.length; i++) {
      if (_spineCache[i].$1 == segmentNumber) {
        // Touch the element
        final x = _spineCache.removeAt(i);
        _spineCache.add(x);
        // Return the shortarray for this position
        return x.$2.ref();
      }
    }

    // If we don't have it in the cache, get/create it and then cache a ref
    final segment = await _openOrCreateSegmentInner(segmentNumber);
    _spineCache.add((segmentNumber, await segment.ref()));
    if (_spineCache.length > _spineCacheLength) {
      // Trim the LRU cache
      final (_, sa) = _spineCache.removeAt(0);
      await sa.close();
    }
    return segment;
  }

  Future<DHTShortArray?> _openSegment(int segmentNumber) async {
    assert(_spineMutex.isLocked, 'should be in mutex here');

    // See if we already have this in the cache
    for (var i = 0; i < _spineCache.length; i++) {
      if (_spineCache[i].$1 == segmentNumber) {
        // Touch the element
        final x = _spineCache.removeAt(i);
        _spineCache.add(x);
        // Return the shortarray for this position
        return x.$2.ref();
      }
    }

    // If we don't have it in the cache, get it and then cache it
    final segment = await _openSegmentInner(segmentNumber);
    if (segment == null) {
      return null;
    }
    _spineCache.add((segmentNumber, await segment.ref()));
    if (_spineCache.length > _spineCacheLength) {
      // Trim the LRU cache
      final (_, sa) = _spineCache.removeAt(0);
      await sa.close();
    }
    return segment;
  }

  _DHTLogSegmentLookup _lookupSegment(int segmentNumber) {
    assert(_spineMutex.isLocked, 'should be in mutex here');

    if (segmentNumber < 0) {
      throw IndexError.withLength(
          segmentNumber, DHTLog.spineSubkeys * DHTLog.segmentsPerSubkey);
    }
    final subkey = segmentNumber ~/ DHTLog.segmentsPerSubkey;
    if (subkey >= DHTLog.spineSubkeys) {
      throw IndexError.withLength(
          segmentNumber, DHTLog.spineSubkeys * DHTLog.segmentsPerSubkey);
    }
    final segment = segmentNumber % DHTLog.segmentsPerSubkey;
    return _DHTLogSegmentLookup(subkey: subkey + 1, segment: segment);
  }

  ///////////////////////////////////////////
  // API for public interfaces

  Future<_DHTLogPosition?> lookupPosition(int pos) async {
    assert(_spineMutex.isLocked, 'should be locked');
    return _spineCacheMutex.protect(() async {
      // Check if our position is in bounds
      final endPos = length;
      if (pos < 0 || pos >= endPos) {
        throw IndexError.withLength(pos, endPos);
      }

      // Calculate absolute position, ring-buffer style
      final absolutePosition = (_head + pos) % _positionLimit;

      // Determine the segment number and position within the segment
      final segmentNumber = absolutePosition ~/ DHTShortArray.maxElements;
      final segmentPos = absolutePosition % DHTShortArray.maxElements;

      // Get the segment shortArray
      final openedSegment = _openedSegments[segmentNumber];
      late final DHTShortArray shortArray;
      if (openedSegment != null) {
        openedSegment.openCount++;
        shortArray = openedSegment.shortArray;
      } else {
        final newShortArray = (_spineRecord.writer == null)
            ? await _openSegment(segmentNumber)
            : await _openOrCreateSegment(segmentNumber);
        if (newShortArray == null) {
          return null;
        }

        _openedSegments[segmentNumber] =
            _OpenedSegment._(shortArray: newShortArray);

        shortArray = newShortArray;
      }

      return _DHTLogPosition._(
          dhtLogSpine: this,
          shortArray: shortArray,
          pos: segmentPos,
          segmentNumber: segmentNumber);
    });
  }

  Future<void> _segmentClosed(int segmentNumber) async {
    assert(_spineMutex.isLocked, 'should be locked');
    await _spineCacheMutex.protect(() async {
      final os = _openedSegments[segmentNumber]!;
      os.openCount--;
      if (os.openCount == 0) {
        _openedSegments.remove(segmentNumber);
        await os.shortArray.close();
      }
    });
  }

  void allocateTail(int count) {
    assert(_spineMutex.isLocked, 'should be locked');

    final currentLength = length;
    if (count <= 0) {
      throw StateError('count should be > 0');
    }
    if (currentLength + count >= _positionLimit) {
      throw StateError('ring buffer overflow');
    }

    _tail = (_tail + count) % _positionLimit;
  }

  Future<void> releaseHead(int count) async {
    assert(_spineMutex.isLocked, 'should be locked');

    final currentLength = length;
    if (count <= 0) {
      throw StateError('count should be > 0');
    }
    if (count > currentLength) {
      throw StateError('ring buffer underflow');
    }

    final oldHead = _head;
    _head = (_head + count) % _positionLimit;
    final newHead = _head;
    await _purgeSegments(oldHead, newHead);
  }

  Future<void> _deleteSegmentsContiguous(int start, int end) async {
    assert(_spineMutex.isLocked, 'should be in mutex here');
    DHTRecordPool.instance
        .log('_deleteSegmentsContiguous: start=$start, end=$end');

    final startSegmentNumber = start ~/ DHTShortArray.maxElements;
    final startSegmentPos = start % DHTShortArray.maxElements;

    final endSegmentNumber = end ~/ DHTShortArray.maxElements;
    final endSegmentPos = end % DHTShortArray.maxElements;

    final firstDeleteSegment =
        (startSegmentPos == 0) ? startSegmentNumber : startSegmentNumber + 1;
    final lastDeleteSegment =
        (endSegmentPos == 0) ? endSegmentNumber - 1 : endSegmentNumber - 2;

    _SubkeyData? lastSubkeyData;
    for (var segmentNumber = firstDeleteSegment;
        segmentNumber <= lastDeleteSegment;
        segmentNumber++) {
      // Lookup what subkey and segment subrange has this position's segment
      // shortarray
      final l = _lookupSegment(segmentNumber);
      final subkey = l.subkey;
      final segment = l.segment;

      if (subkey != lastSubkeyData?.subkey) {
        // Flush subkey writes
        if (lastSubkeyData != null && lastSubkeyData.changed) {
          await _spineRecord.eventualWriteBytes(lastSubkeyData.data,
              subkey: lastSubkeyData.subkey);
        }

        // Get next subkey if available locally
        final data = await _spineRecord.get(
            subkey: subkey, refreshMode: DHTRecordRefreshMode.local);
        if (data != null) {
          lastSubkeyData = _SubkeyData(subkey: subkey, data: data);
        } else {
          lastSubkeyData = null;
          // If the subkey was not available locally we can go to the
          // last segment number at the end of this subkey
          segmentNumber = ((subkey + 1) * DHTLog.segmentsPerSubkey) - 1;
        }
      }
      if (lastSubkeyData != null) {
        final segmentKey = _getSegmentKey(lastSubkeyData.data, segment);
        if (segmentKey != null) {
          await DHTRecordPool.instance.deleteRecord(segmentKey);
          _setSegmentKey(lastSubkeyData.data, segment, null);
          lastSubkeyData.changed = true;
        }
      }
    }
    // Flush subkey writes
    if (lastSubkeyData != null) {
      await _spineRecord.eventualWriteBytes(lastSubkeyData.data,
          subkey: lastSubkeyData.subkey);
    }
  }

  Future<void> _purgeSegments(int from, int to) async {
    assert(_spineMutex.isLocked, 'should be in mutex here');
    if (from < to) {
      await _deleteSegmentsContiguous(from, to);
    } else if (from > to) {
      await _deleteSegmentsContiguous(from, _positionLimit);
      await _deleteSegmentsContiguous(0, to);
    }
  }

  /////////////////////////////////////////////////////////////////////////////
  // Watch For Updates

  // Watch head for changes
  Future<void> watch() async {
    // This will update any existing watches if necessary
    try {
      await _spineRecord.watch(subkeys: [ValueSubkeyRange.single(0)]);

      // Update changes to the head record
      // Don't watch for local changes because this class already handles
      // notifying listeners and knows when it makes local changes
      _subscription ??=
          await _spineRecord.listen(localChanges: false, _onSpineChanged);
    } on Exception {
      // If anything fails, try to cancel the watches
      await cancelWatch();
      rethrow;
    }
  }

  // Stop watching for changes to head and linked records
  Future<void> cancelWatch() async {
    await _spineRecord.cancelWatch();
    await _subscription?.cancel();
    _subscription = null;
  }

  // Called when the log changes online and we find out from a watch
  // but not when we make a change locally
  Future<void> _onSpineChanged(
      DHTRecord record, Uint8List? data, List<ValueSubkeyRange> subkeys) async {
    // If head record subkey zero changes, then the layout
    // of the dhtshortarray has changed
    if (data == null) {
      throw StateError('spine head changed without data');
    }
    if (record.key != _spineRecord.key ||
        subkeys.length != 1 ||
        subkeys[0] != ValueSubkeyRange.single(0)) {
      throw StateError('watch returning wrong subkey range');
    }

    // Decode updated head
    final headData = proto.DHTLog.fromBuffer(data);

    // Then update the head record
    await _spineMutex.protect(() async {
      final oldHead = _head;
      final oldTail = _tail;
      await _updateHead(headData);
      sendUpdate(oldHead, oldTail);
    });
  }

  ////////////////////////////////////////////////////////////////////////////

  TypedKey get recordKey => _spineRecord.key;
  OwnedDHTRecordPointer get recordPointer => _spineRecord.ownedDHTRecordPointer;
  int get length => _ringDistance(_tail, _head);

  bool get isOpen => _spineRecord.isOpen;

  // Ring buffer distance from old to new
  static int _ringDistance(int n, int o) =>
      (n < o) ? (_positionLimit - o) + n : n - o;

  static const _positionLimit = DHTLog.segmentsPerSubkey *
      DHTLog.spineSubkeys *
      DHTShortArray.maxElements;

  // Spine head mutex to ensure we keep the representation valid
  final Mutex _spineMutex = Mutex();
  // Subscription to head record internal changes
  StreamSubscription<DHTRecordWatchChange>? _subscription;
  // Notify closure for external spine head changes
  void Function(DHTLogUpdate)? onUpdatedSpine;

  // Spine DHT record
  final DHTRecord _spineRecord;
  // Segment stride to use for spine elements
  final int _segmentStride;

  // Position of the start of the log (oldest items)
  int _head;
  // Position of the end of the log (newest items) (exclusive)
  int _tail;

  // LRU cache of DHT spine elements accessed recently
  // Pair of position and associated shortarray segment
  final Mutex _spineCacheMutex = Mutex();
  final List<(int, DHTShortArray)> _spineCache;
  final Map<int, _OpenedSegment> _openedSegments;
  static const int _spineCacheLength = 3;
}
