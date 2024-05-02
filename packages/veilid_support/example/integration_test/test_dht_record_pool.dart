import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veilid_support/veilid_support.dart';

Future<void> testDHTRecordPoolCreate() async {
  await DHTRecordPool.init(logger: debugPrintSynchronously);
  final pool = DHTRecordPool.instance;
  await pool.tick();
  await DHTRecordPool.close();
}

Future<void> testDHTRecordCreateDelete() async {
  final pool = DHTRecordPool.instance;

  // Close before delete
  {
    final rec = await pool.createRecord(debugName: 'test_create_delete 1');
    expect(rec.isOpen, isTrue);
    await rec.close();
    expect(rec.isOpen, isFalse);
    await pool.deleteRecord(rec.key);
    // Set should fail
    await expectLater(() async => rec.tryWriteBytes(utf8.encode('test')),
        throwsA(isA<VeilidAPIException>()));
  }

  // Close after delete
  {
    final rec2 = await pool.createRecord(debugName: 'test_create_delete 2');
    expect(rec2.isOpen, isTrue);
    await pool.deleteRecord(rec2.key);
    expect(rec2.isOpen, isTrue);
    await rec2.close();
    expect(rec2.isOpen, isFalse);
    // Set should fail
    await expectLater(() async => rec2.tryWriteBytes(utf8.encode('test')),
        throwsA(isA<VeilidAPIException>()));
  }

  // Close after delete multiple
  // Okay to request delete multiple times before close
  {
    final rec3 = await pool.createRecord(debugName: 'test_create_delete 3');
    await pool.deleteRecord(rec3.key);
    await pool.deleteRecord(rec3.key);
    // Set should succeed still
    await rec3.tryWriteBytes(utf8.encode('test'));
    await rec3.close();
    await rec3.close();
    // Set should fail
    await expectLater(() async => rec3.tryWriteBytes(utf8.encode('test')),
        throwsA(isA<VeilidAPIException>()));
    // Delete already delete should fail
    await expectLater(() async => pool.deleteRecord(rec3.key),
        throwsA(isA<VeilidAPIException>()));
  }
}

Future<void> testDHTRecordScopes() async {
  final pool = DHTRecordPool.instance;

  // Delete scope with exception should propagate exception
  {
    final rec = await pool.createRecord(debugName: 'test_scope 1');
    await expectLater(
        () async => rec.deleteScope((recd) async {
              throw Exception();
            }),
        throwsA(isA<Exception>()));
    // Set should fail
    await expectLater(() async => rec.tryWriteBytes(utf8.encode('test')),
        throwsA(isA<VeilidAPIException>()));
  }

  // Delete scope without exception
  {
    final rec2 = await pool.createRecord(debugName: 'test_scope 2');
    try {
      await rec2.deleteScope((rec2d) async {
        //
      });
    } on Exception {
      assert(false, 'should not throw');
    }
    await rec2.close();
    await pool.deleteRecord(rec2.key);
  }

  // Close scope without exception
  {
    final rec3 = await pool.createRecord(debugName: 'test_scope 3');
    try {
      await rec3.scope((rec3d) async {
        //
      });
    } on Exception {
      assert(false, 'should not throw');
    }
    // Set should fail because scope closed it
    await expectLater(() async => rec3.tryWriteBytes(utf8.encode('test')),
        throwsA(isA<VeilidAPIException>()));
    await pool.deleteRecord(rec3.key);
  }
}

Future<void> testDHTRecordGetSet() async {
  final pool = DHTRecordPool.instance;
  final valdata = utf8.encode('test');

  // Test get without set
  {
    final rec = await pool.createRecord(debugName: 'test_get_set 1');
    final val = await rec.get();
    await pool.deleteRecord(rec.key);
    expect(val, isNull);
  }

  // Test set then get
  {
    final rec2 = await pool.createRecord(debugName: 'test_get_set 2');
    expect(await rec2.tryWriteBytes(valdata), isNull);
    expect(await rec2.get(), equals(valdata));
    // Invalid subkey should throw
    await expectLater(
        () async => rec2.get(subkey: 1), throwsA(isA<VeilidAPIException>()));
    await pool.deleteRecord(rec2.key);
  }

  // Test set then delete then open then get
  {
    final rec3 = await pool.createRecord(debugName: 'test_get_set 3');
    expect(await rec3.tryWriteBytes(valdata), isNull);
    expect(await rec3.get(), equals(valdata));
    await rec3.close();
    await pool.deleteRecord(rec3.key);
    final rec4 =
        await pool.openRecordRead(rec3.key, debugName: 'test_get_set 4');
    expect(await rec4.get(), equals(valdata));
    await rec4.close();
    await pool.deleteRecord(rec4.key);
  }
}

Future<void> testDHTRecordDeepCreateDelete() async {
  final pool = DHTRecordPool.instance;
  const numChildren = 20;
  const numIterations = 10;

  // Make root record
  final recroot = await pool.createRecord(debugName: 'test_deep_create_delete');

  for (var d = 0; d < numIterations; d++) {
    // Make child set 1
    var parent = recroot;
    final children = <DHTRecord>[];
    for (var n = 0; n < numChildren; n++) {
      final child =
          await pool.createRecord(debugName: 'deep $n', parent: parent.key);
      children.add(child);
      parent = child;
    }

    // Make child set 2
    final children2 = <DHTRecord>[];
    parent = recroot;
    for (var n = 0; n < numChildren; n++) {
      final child =
          await pool.createRecord(debugName: 'deep2 $n ', parent: parent.key);
      children2.add(child);
      parent = child;
    }
    // Should fail to delete root
    await expectLater(
        () async => pool.deleteRecord(recroot.key), throwsA(isA<StateError>()));

    // Close child set 1
    await children.map((c) => c.close()).wait;

    // Delete child set 1 in reverse order
    for (var n = numChildren - 1; n >= 0; n--) {
      await pool.deleteRecord(children[n].key);
    }

    // Should fail to delete root
    await expectLater(
        () async => pool.deleteRecord(recroot.key), throwsA(isA<StateError>()));

    // Close child set 1
    await children2.map((c) => c.close()).wait;

    // Delete child set 2 in reverse order
    for (var n = numChildren - 1; n >= 0; n--) {
      await pool.deleteRecord(children2[n].key);
    }
  }

  // Should be able to delete root now
  await pool.deleteRecord(recroot.key);
}
