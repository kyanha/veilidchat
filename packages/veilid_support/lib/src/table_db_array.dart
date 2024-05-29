import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:async_tools/async_tools.dart';
import 'package:charcode/charcode.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:protobuf/protobuf.dart';

import '../veilid_support.dart';

@immutable
class TableDBArrayUpdate extends Equatable {
  const TableDBArrayUpdate(
      {required this.headDelta, required this.tailDelta, required this.length})
      : assert(length >= 0, 'should never have negative length');
  final int headDelta;
  final int tailDelta;
  final int length;

  @override
  List<Object?> get props => [headDelta, tailDelta, length];
}

class TableDBArray {
  TableDBArray({
    required String table,
    required VeilidCrypto crypto,
  })  : _table = table,
        _crypto = crypto {
    _initWait.add(_init);
  }

  static Future<TableDBArray> make({
    required String table,
    required VeilidCrypto crypto,
  }) async {
    final out = TableDBArray(table: table, crypto: crypto);
    await out._initWait();
    return out;
  }

  Future<void> initWait() async {
    await _initWait();
  }

  Future<void> _init() async {
    // Load the array details
    await _mutex.protect(() async {
      _tableDB = await Veilid.instance.openTableDB(_table, 1);
      await _loadHead();
      _initDone = true;
    });
  }

  Future<void> close({bool delete = false}) async {
    // Ensure the init finished
    await _initWait();

    // Allow multiple attempts to close
    if (_open) {
      await _mutex.protect(() async {
        await _changeStream.close();
        _tableDB.close();
        _open = false;
      });
    }
    if (delete) {
      await Veilid.instance.deleteTableDB(_table);
    }
  }

  Future<void> delete() async {
    await _initWait();
    if (_open) {
      throw StateError('should be closed first');
    }
    await Veilid.instance.deleteTableDB(_table);
  }

  Future<StreamSubscription<void>> listen(
          void Function(TableDBArrayUpdate) onChanged) async =>
      _changeStream.stream.listen(onChanged);

  ////////////////////////////////////////////////////////////
  // Public interface

  int get length {
    if (!_open) {
      throw StateError('not open');
    }
    if (!_initDone) {
      throw StateError('not initialized');
    }

    return _length;
  }

  bool get isOpen => _open;

  Future<void> add(Uint8List value) async {
    await _initWait();
    return _writeTransaction((t) async => _addInner(t, value));
  }

  Future<void> addAll(List<Uint8List> values) async {
    await _initWait();
    return _writeTransaction((t) async => _addAllInner(t, values));
  }

  Future<void> insert(int pos, Uint8List value) async {
    await _initWait();
    return _writeTransaction((t) async => _insertInner(t, pos, value));
  }

  Future<void> insertAll(int pos, List<Uint8List> values) async {
    await _initWait();
    return _writeTransaction((t) async => _insertAllInner(t, pos, values));
  }

  Future<Uint8List> get(int pos) async {
    await _initWait();
    return _mutex.protect(() async {
      if (!_open) {
        throw StateError('not open');
      }
      return _getInner(pos);
    });
  }

  Future<List<Uint8List>> getRange(int start, [int? end]) async {
    await _initWait();
    return _mutex.protect(() async {
      if (!_open) {
        throw StateError('not open');
      }
      return _getRangeInner(start, end ?? _length);
    });
  }

  Future<void> remove(int pos, {Output<Uint8List>? out}) async {
    await _initWait();
    return _writeTransaction((t) async => _removeInner(t, pos, out: out));
  }

  Future<void> removeRange(int start, int end,
      {Output<List<Uint8List>>? out}) async {
    await _initWait();
    return _writeTransaction(
        (t) async => _removeRangeInner(t, start, end, out: out));
  }

  Future<void> clear() async {
    await _initWait();
    return _writeTransaction((t) async {
      final keys = await _tableDB.getKeys(0);
      for (final key in keys) {
        await t.delete(0, key);
      }
      _length = 0;
      _nextFree = 0;
      _maxEntry = 0;
      _dirtyChunks.clear();
      _chunkCache.clear();
    });
  }

  ////////////////////////////////////////////////////////////
  // Inner interface

  Future<void> _addInner(VeilidTableDBTransaction t, Uint8List value) async {
    // Allocate an entry to store the value
    final entry = await _allocateEntry();
    await _storeEntry(t, entry, value);

    // Put the entry in the index
    final pos = _length;
    _length++;
    _tailDelta++;
    await _setIndexEntry(pos, entry);
  }

  Future<void> _addAllInner(
      VeilidTableDBTransaction t, List<Uint8List> values) async {
    var pos = _length;
    _length += values.length;
    _tailDelta += values.length;
    for (final value in values) {
      // Allocate an entry to store the value
      final entry = await _allocateEntry();
      await _storeEntry(t, entry, value);

      // Put the entry in the index
      await _setIndexEntry(pos, entry);
      pos++;
    }
  }

  Future<void> _insertInner(
      VeilidTableDBTransaction t, int pos, Uint8List value) async {
    if (pos == _length) {
      return _addInner(t, value);
    }
    if (pos < 0 || pos >= _length) {
      throw IndexError.withLength(pos, _length);
    }
    // Allocate an entry to store the value
    final entry = await _allocateEntry();
    await _storeEntry(t, entry, value);

    // Put the entry in the index
    await _insertIndexEntry(pos);
    await _setIndexEntry(pos, entry);
  }

  Future<void> _insertAllInner(
      VeilidTableDBTransaction t, int pos, List<Uint8List> values) async {
    if (pos == _length) {
      return _addAllInner(t, values);
    }
    if (pos < 0 || pos >= _length) {
      throw IndexError.withLength(pos, _length);
    }
    await _insertIndexEntries(pos, values.length);
    for (final value in values) {
      // Allocate an entry to store the value
      final entry = await _allocateEntry();
      await _storeEntry(t, entry, value);

      // Put the entry in the index
      await _setIndexEntry(pos, entry);
      pos++;
    }
  }

  Future<Uint8List> _getInner(int pos) async {
    if (pos < 0 || pos >= _length) {
      throw IndexError.withLength(pos, _length);
    }
    final entry = await _getIndexEntry(pos);
    return (await _loadEntry(entry))!;
  }

  Future<List<Uint8List>> _getRangeInner(int start, int end) async {
    final length = end - start;
    if (length < 0) {
      throw StateError('length should not be negative');
    }
    if (start < 0 || start >= _length) {
      throw IndexError.withLength(start, _length);
    }
    if (end > _length) {
      throw IndexError.withLength(end, _length);
    }

    final out = <Uint8List>[];
    const batchSize = 16;

    for (var pos = start; pos < end;) {
      var batchLen = min(batchSize, end - pos);
      final dws = DelayedWaitSet<Uint8List>();
      while (batchLen > 0) {
        final entry = await _getIndexEntry(pos);
        dws.add(() async => (await _loadEntry(entry))!);
        pos++;
        batchLen--;
      }
      final batchOut = await dws();
      out.addAll(batchOut);
    }

    return out;
  }

  Future<void> _removeInner(VeilidTableDBTransaction t, int pos,
      {Output<Uint8List>? out}) async {
    if (pos < 0 || pos >= _length) {
      throw IndexError.withLength(pos, _length);
    }

    final entry = await _getIndexEntry(pos);
    if (out != null) {
      final value = (await _loadEntry(entry))!;
      out.save(value);
    }

    await _freeEntry(t, entry);
    await _removeIndexEntry(pos);
  }

  Future<void> _removeRangeInner(VeilidTableDBTransaction t, int start, int end,
      {Output<List<Uint8List>>? out}) async {
    final length = end - start;
    if (length < 0) {
      throw StateError('length should not be negative');
    }
    if (start < 0) {
      throw IndexError.withLength(start, _length);
    }
    if (end > _length) {
      throw IndexError.withLength(end, _length);
    }

    final outList = <Uint8List>[];
    for (var pos = start; pos < end; pos++) {
      final entry = await _getIndexEntry(pos);
      if (out != null) {
        final value = (await _loadEntry(entry))!;
        outList.add(value);
      }
      await _freeEntry(t, entry);
    }
    if (out != null) {
      out.save(outList);
    }

    await _removeIndexEntries(start, length);
  }

  ////////////////////////////////////////////////////////////
  // Private implementation

  static final Uint8List _headKey = Uint8List.fromList([$_, $H, $E, $A, $D]);
  static Uint8List _entryKey(int k) =>
      (ByteData(4)..setUint32(0, k)).buffer.asUint8List();
  static Uint8List _chunkKey(int n) =>
      (ByteData(2)..setUint16(0, n)).buffer.asUint8List();

  Future<T> _writeTransaction<T>(
          Future<T> Function(VeilidTableDBTransaction) closure) async =>
      _mutex.protect(() async {
        if (!_open) {
          throw StateError('not open');
        }

        final _oldLength = _length;
        final _oldNextFree = _nextFree;
        final _oldMaxEntry = _maxEntry;
        final _oldHeadDelta = _headDelta;
        final _oldTailDelta = _tailDelta;
        try {
          final out = await transactionScope(_tableDB, (t) async {
            final out = await closure(t);
            await _saveHead(t);
            await _flushDirtyChunks(t);
            // Send change
            _changeStream.add(TableDBArrayUpdate(
                headDelta: _headDelta, tailDelta: _tailDelta, length: _length));
            _headDelta = 0;
            _tailDelta = 0;
            return out;
          });

          return out;
        } on Exception {
          // restore head
          _length = _oldLength;
          _nextFree = _oldNextFree;
          _maxEntry = _oldMaxEntry;
          _headDelta = _oldHeadDelta;
          _tailDelta = _oldTailDelta;
          // invalidate caches because they could have been written to
          _chunkCache.clear();
          _dirtyChunks.clear();
          // propagate exception
          rethrow;
        }
      });

  Future<void> _storeEntry(
          VeilidTableDBTransaction t, int entry, Uint8List value) async =>
      t.store(0, _entryKey(entry), await _crypto.encrypt(value));

  Future<Uint8List?> _loadEntry(int entry) async {
    final encryptedValue = await _tableDB.load(0, _entryKey(entry));
    return (encryptedValue == null) ? null : _crypto.decrypt(encryptedValue);
  }

  Future<int> _getIndexEntry(int pos) async {
    if (pos < 0 || pos >= _length) {
      throw IndexError.withLength(pos, _length);
    }
    final chunkNumber = pos ~/ _indexStride;
    final chunkOffset = pos % _indexStride;

    final chunk = await _loadIndexChunk(chunkNumber);

    return chunk.buffer.asByteData().getUint32(chunkOffset * 4);
  }

  Future<void> _setIndexEntry(int pos, int entry) async {
    if (pos < 0 || pos >= _length) {
      throw IndexError.withLength(pos, _length);
    }

    final chunkNumber = pos ~/ _indexStride;
    final chunkOffset = pos % _indexStride;

    final chunk = await _loadIndexChunk(chunkNumber);
    chunk.buffer.asByteData().setUint32(chunkOffset * 4, entry);

    _dirtyChunks[chunkNumber] = chunk;
  }

  Future<void> _insertIndexEntry(int pos) async => _insertIndexEntries(pos, 1);

  Future<void> _insertIndexEntries(int start, int length) async {
    if (length == 0) {
      return;
    }
    if (length < 0) {
      throw StateError('length should not be negative');
    }
    if (start < 0 || start >= _length) {
      throw IndexError.withLength(start, _length);
    }

    // Slide everything over in reverse
    var src = _length - 1;
    var dest = src + length;

    (int, Uint8List)? lastSrcChunk;
    (int, Uint8List)? lastDestChunk;
    while (src >= start) {
      final remaining = (src - start) + 1;
      final srcChunkNumber = src ~/ _indexStride;
      final srcIndex = src % _indexStride;
      final srcLength = min(remaining, srcIndex + 1);

      final srcChunk =
          (lastSrcChunk != null && (lastSrcChunk.$1 == srcChunkNumber))
              ? lastSrcChunk.$2
              : await _loadIndexChunk(srcChunkNumber);
      _dirtyChunks[srcChunkNumber] = srcChunk;
      lastSrcChunk = (srcChunkNumber, srcChunk);

      final destChunkNumber = dest ~/ _indexStride;
      final destIndex = dest % _indexStride;
      final destLength = min(remaining, destIndex + 1);

      final destChunk =
          (lastDestChunk != null && (lastDestChunk.$1 == destChunkNumber))
              ? lastDestChunk.$2
              : await _loadIndexChunk(destChunkNumber);
      _dirtyChunks[destChunkNumber] = destChunk;
      lastDestChunk = (destChunkNumber, destChunk);

      final toCopy = min(srcLength, destLength);
      destChunk.setRange((destIndex - (toCopy - 1)) * 4, (destIndex + 1) * 4,
          srcChunk, (srcIndex - (toCopy - 1)) * 4);

      dest -= toCopy;
      src -= toCopy;
    }

    // Then add to length
    _length += length;
    if (start == 0) {
      _headDelta += length;
    }
    _tailDelta += length;
  }

  Future<void> _removeIndexEntry(int pos) async => _removeIndexEntries(pos, 1);

  Future<void> _removeIndexEntries(int start, int length) async {
    if (length == 0) {
      return;
    }
    if (length < 0) {
      throw StateError('length should not be negative');
    }
    if (start < 0 || start >= _length) {
      throw IndexError.withLength(start, _length);
    }
    final end = start + length - 1;
    if (end < 0 || end >= _length) {
      throw IndexError.withLength(end, _length);
    }

    // Slide everything over
    var dest = start;
    var src = end + 1;
    (int, Uint8List)? lastSrcChunk;
    (int, Uint8List)? lastDestChunk;
    while (src < _length) {
      final srcChunkNumber = src ~/ _indexStride;
      final srcIndex = src % _indexStride;
      final srcLength = _indexStride - srcIndex;

      final srcChunk =
          (lastSrcChunk != null && (lastSrcChunk.$1 == srcChunkNumber))
              ? lastSrcChunk.$2
              : await _loadIndexChunk(srcChunkNumber);
      _dirtyChunks[srcChunkNumber] = srcChunk;
      lastSrcChunk = (srcChunkNumber, srcChunk);

      final destChunkNumber = dest ~/ _indexStride;
      final destIndex = dest % _indexStride;
      final destLength = _indexStride - destIndex;

      final destChunk =
          (lastDestChunk != null && (lastDestChunk.$1 == destChunkNumber))
              ? lastDestChunk.$2
              : await _loadIndexChunk(destChunkNumber);
      _dirtyChunks[destChunkNumber] = destChunk;
      lastDestChunk = (destChunkNumber, destChunk);

      final toCopy = min(srcLength, destLength);
      destChunk.setRange(
          destIndex * 4, (destIndex + toCopy) * 4, srcChunk, srcIndex * 4);

      dest += toCopy;
      src += toCopy;
    }

    // Then truncate
    _length -= length;
    if (start == 0) {
      _headDelta -= length;
    }
    _tailDelta -= length;
  }

  Future<Uint8List> _loadIndexChunk(int chunkNumber) async {
    // Get it from the dirty chunks if we have it
    final dirtyChunk = _dirtyChunks[chunkNumber];
    if (dirtyChunk != null) {
      return dirtyChunk;
    }

    // Get from cache if we have it
    for (var i = 0; i < _chunkCache.length; i++) {
      if (_chunkCache[i].$1 == chunkNumber) {
        // Touch the element
        final x = _chunkCache.removeAt(i);
        _chunkCache.add(x);
        // Return the chunk for this position
        return x.$2;
      }
    }

    // Get chunk from disk
    var chunk = await _tableDB.load(0, _chunkKey(chunkNumber));
    chunk ??= Uint8List(_indexStride * 4);

    // Cache the chunk
    _chunkCache.add((chunkNumber, chunk));
    if (_chunkCache.length > _chunkCacheLength) {
      // Trim the LRU cache
      final (_, _) = _chunkCache.removeAt(0);
    }

    return chunk;
  }

  Future<void> _flushDirtyChunks(VeilidTableDBTransaction t) async {
    for (final ec in _dirtyChunks.entries) {
      await t.store(0, _chunkKey(ec.key), ec.value);
    }
    _dirtyChunks.clear();
  }

  Future<void> _loadHead() async {
    assert(_mutex.isLocked, 'should be locked');
    final headBytes = await _tableDB.load(0, _headKey);
    if (headBytes == null) {
      _length = 0;
      _nextFree = 0;
      _maxEntry = 0;
    } else {
      final b = headBytes.buffer.asByteData();
      _length = b.getUint32(0);
      _nextFree = b.getUint32(4);
      _maxEntry = b.getUint32(8);
    }
  }

  Future<void> _saveHead(VeilidTableDBTransaction t) async {
    assert(_mutex.isLocked, 'should be locked');
    final b = ByteData(12)
      ..setUint32(0, _length)
      ..setUint32(4, _nextFree)
      ..setUint32(8, _maxEntry);
    await t.store(0, _headKey, b.buffer.asUint8List());
  }

  Future<int> _allocateEntry() async {
    assert(_mutex.isLocked, 'should be locked');
    if (_nextFree == 0) {
      return _maxEntry++;
    }
    // pop endogenous free list
    final free = _nextFree;
    final nextFreeBytes = await _tableDB.load(0, _entryKey(free));
    _nextFree = nextFreeBytes!.buffer.asByteData().getUint8(0);
    return free;
  }

  Future<void> _freeEntry(VeilidTableDBTransaction t, int entry) async {
    assert(_mutex.isLocked, 'should be locked');
    // push endogenous free list
    final b = ByteData(4)..setUint32(0, _nextFree);
    await t.store(0, _entryKey(entry), b.buffer.asUint8List());
    _nextFree = entry;
  }

  final String _table;
  late final VeilidTableDB _tableDB;
  var _open = true;
  var _initDone = false;
  final VeilidCrypto _crypto;
  final WaitSet<void> _initWait = WaitSet();
  final Mutex _mutex = Mutex();

  // Change tracking
  int _headDelta = 0;
  int _tailDelta = 0;

  // Head state
  int _length = 0;
  int _nextFree = 0;
  int _maxEntry = 0;
  static const int _indexStride = 16384;
  final List<(int, Uint8List)> _chunkCache = [];
  final Map<int, Uint8List> _dirtyChunks = {};
  static const int _chunkCacheLength = 3;

  final StreamController<TableDBArrayUpdate> _changeStream =
      StreamController.broadcast();
}

extension TableDBArrayExt on TableDBArray {
  /// Convenience function:
  /// Like get but also parses the returned element as JSON
  Future<T?> getJson<T>(
    T Function(dynamic) fromJson,
    int pos,
  ) =>
      get(
        pos,
      ).then((out) => jsonDecodeOptBytes(fromJson, out));

  /// Convenience function:
  /// Like getRange but also parses the returned elements as JSON
  Future<List<T>?> getRangeJson<T>(T Function(dynamic) fromJson, int start,
          [int? end]) =>
      getRange(start, end ?? _length).then((out) => out.map(fromJson).toList());

  /// Convenience function:
  /// Like get but also parses the returned element as a protobuf object
  Future<T?> getProtobuf<T extends GeneratedMessage>(
    T Function(List<int>) fromBuffer,
    int pos,
  ) =>
      get(pos).then(fromBuffer);

  /// Convenience function:
  /// Like getRange but also parses the returned elements as protobuf objects
  Future<List<T>?> getRangeProtobuf<T extends GeneratedMessage>(
          T Function(List<int>) fromBuffer, int start, [int? end]) =>
      getRange(start, end ?? _length)
          .then((out) => out.map(fromBuffer).toList());
}
