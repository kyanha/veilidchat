part of 'dht_log.dart';

class DHTLogPositionLookup {
  const DHTLogPositionLookup({required this.shortArray, required this.pos});
  final DHTShortArray shortArray;
  final int pos;
}

class _DHTLogSegmentLookup extends Equatable {
  const _DHTLogSegmentLookup({required this.subkey, required this.segment});
  final int subkey;
  final int segment;

  @override
  List<Object?> get props => [subkey, segment];
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
        subkey: 0, refreshMode: DHTRecordRefreshMode.refresh);
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
    });
  }

  Future<void> delete() async {
    await _spineMutex.protect(() async {
      final pool = DHTRecordPool.instance;
      final futures = <Future<void>>[pool.deleteRecord(_spineRecord.key)];
      for (final (_, sc) in _spineCache) {
        futures.add(sc.delete());
      }
      await Future.wait(futures);
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
          if (!await writeSpineHead()) {
            // Failed to write head means head got overwritten so write should
            // be considered failed
            throw DHTExceptionTryAgain();
          }

          onUpdatedSpine?.call();
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
        } while (!await writeSpineHead());

        onUpdatedSpine?.call();
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
  Future<bool> writeSpineHead() async {
    assert(_spineMutex.isLocked, 'should be in mutex here');

    final headBuffer = _toProto().writeToBuffer();

    final existingData = await _spineRecord.tryWriteBytes(headBuffer);
    if (existingData != null) {
      // Head write failed, incorporate update
      await _updateHead(proto.DHTLog.fromBuffer(existingData));
      return false;
    }

    return true;
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
        decodedLength * segment, (decodedLength + 1) * segment);
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
    subkeyData.setRange(decodedLength * segment, (decodedLength + 1) * segment,
        segmentKeyBytes);
  }

  Future<DHTShortArray> _getOrCreateSegmentInner(int segmentNumber) async {
    assert(_spineMutex.isLocked, 'should be in mutex here');
    assert(_spineRecord.writer != null, 'should be writable');

    // Lookup what subkey and segment subrange has this position's segment
    // shortarray
    final l = lookupSegment(segmentNumber);
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

  Future<DHTShortArray?> _getSegmentInner(int segmentNumber) async {
    assert(_spineMutex.isLocked, 'should be in mutex here');

    // Lookup what subkey and segment subrange has this position's segment
    // shortarray
    final l = lookupSegment(segmentNumber);
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

  Future<DHTShortArray> getOrCreateSegment(int segmentNumber) async {
    assert(_spineMutex.isLocked, 'should be in mutex here');

    // See if we already have this in the cache
    for (var i = 0; i < _spineCache.length; i++) {
      if (_spineCache[i].$1 == segmentNumber) {
        // Touch the element
        final x = _spineCache.removeAt(i);
        _spineCache.add(x);
        // Return the shortarray for this position
        return x.$2;
      }
    }

    // If we don't have it in the cache, get/create it and then cache it
    final segment = await _getOrCreateSegmentInner(segmentNumber);
    _spineCache.add((segmentNumber, segment));
    if (_spineCache.length > _spineCacheLength) {
      // Trim the LRU cache
      _spineCache.removeAt(0);
    }
    return segment;
  }

  Future<DHTShortArray?> getSegment(int segmentNumber) async {
    assert(_spineMutex.isLocked, 'should be in mutex here');

    // See if we already have this in the cache
    for (var i = 0; i < _spineCache.length; i++) {
      if (_spineCache[i].$1 == segmentNumber) {
        // Touch the element
        final x = _spineCache.removeAt(i);
        _spineCache.add(x);
        // Return the shortarray for this position
        return x.$2;
      }
    }

    // If we don't have it in the cache, get it and then cache it
    final segment = await _getSegmentInner(segmentNumber);
    if (segment == null) {
      return null;
    }
    _spineCache.add((segmentNumber, segment));
    if (_spineCache.length > _spineCacheLength) {
      // Trim the LRU cache
      _spineCache.removeAt(0);
    }
    return segment;
  }

  _DHTLogSegmentLookup lookupSegment(int segmentNumber) {
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

  Future<DHTLogPositionLookup?> lookupPosition(int pos) async {
    assert(_spineMutex.isLocked, 'should be locked');

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
    final shortArray = (_spineRecord.writer == null)
        ? await getSegment(segmentNumber)
        : await getOrCreateSegment(segmentNumber);
    if (shortArray == null) {
      return null;
    }
    return DHTLogPositionLookup(shortArray: shortArray, pos: segmentPos);
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

  void releaseHead(int count) {
    assert(_spineMutex.isLocked, 'should be locked');

    final currentLength = length;
    if (count <= 0) {
      throw StateError('count should be > 0');
    }
    if (count > currentLength) {
      throw StateError('ring buffer underflow');
    }

    _head = (_head + count) % _positionLimit;
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
      await _updateHead(headData);
      onUpdatedSpine?.call();
    });
  }

  ////////////////////////////////////////////////////////////////////////////

  TypedKey get recordKey => _spineRecord.key;
  OwnedDHTRecordPointer get recordPointer => _spineRecord.ownedDHTRecordPointer;
  int get length =>
      (_tail < _head) ? (_positionLimit - _head) + _tail : _tail - _head;
  bool get isOpen => _spineRecord.isOpen;

  static const _positionLimit = DHTLog.segmentsPerSubkey *
      DHTLog.spineSubkeys *
      DHTShortArray.maxElements;

  // Spine head mutex to ensure we keep the representation valid
  final Mutex _spineMutex = Mutex();
  // Subscription to head record internal changes
  StreamSubscription<DHTRecordWatchChange>? _subscription;
  // Notify closure for external spine head changes
  void Function()? onUpdatedSpine;

  // Spine DHT record
  final DHTRecord _spineRecord;

  // Position of the start of the log (oldest items)
  int _head;
  // Position of the end of the log (newest items)
  int _tail;

  // LRU cache of DHT spine elements accessed recently
  // Pair of position and associated shortarray segment
  final List<(int, DHTShortArray)> _spineCache;
  static const int _spineCacheLength = 3;
  // Segment stride to use for spine elements
  final int _segmentStride;
}
