import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:veilid_support/veilid_support.dart';

Future<void> Function() makeTestDHTShortArrayCreateDelete(
        {required int stride}) =>
    () async {
      // Close before delete
      {
        final arr = await DHTShortArray.create(
            debugName: 'sa_create_delete 1 stride $stride', stride: stride);
        expect(await arr.operate((r) async => r.length), isZero);
        expect(arr.isOpen, isTrue);
        await arr.close();
        expect(arr.isOpen, isFalse);
        await arr.delete();
        // Operate should fail
        await expectLater(() async => arr.operate((r) async => r.length),
            throwsA(isA<StateError>()));
      }

      // Close after delete
      {
        final arr = await DHTShortArray.create(
            debugName: 'sa_create_delete 2 stride $stride', stride: stride);
        await arr.delete();
        // Operate should still succeed because things aren't closed
        expect(await arr.operate((r) async => r.length), isZero);
        await arr.close();
        // Operate should fail
        await expectLater(() async => arr.operate((r) async => r.length),
            throwsA(isA<StateError>()));
      }

      // Close after delete multiple
      // Okay to request delete multiple times before close
      {
        final arr = await DHTShortArray.create(
            debugName: 'sa_create_delete 3 stride $stride', stride: stride);
        await arr.delete();
        await arr.delete();
        // Operate should still succeed because things aren't closed
        expect(await arr.operate((r) async => r.length), isZero);
        await arr.close();
        await arr.close();
        // Operate should fail
        await expectLater(() async => arr.operate((r) async => r.length),
            throwsA(isA<StateError>()));
      }
    };

Future<void> Function() makeTestDHTShortArrayAdd({required int stride}) =>
    () async {
      final startTime = DateTime.now();

      final arr = await DHTShortArray.create(
          debugName: 'sa_add 1 stride $stride', stride: stride);

      final dataset = Iterable<int>.generate(256)
          .map((n) => utf8.encode('elem $n'))
          .toList();

      print('adding\n');
      {
        final (res, ok) = await arr.operateWrite((w) async {
          for (var n = 0; n < dataset.length; n++) {
            print('$n ');
            final success = await w.tryAddItem(dataset[n]);
            expect(success, isTrue);
          }
        });
        expect(res, isNull);
        expect(ok, isTrue);
      }

      //print('get all\n');
      {
        final dataset2 = await arr.operate((r) async => r.getAllItems());
        expect(dataset2, equals(dataset));
      }

      //print('clear\n');
      {
        final (res, ok) = await arr.operateWrite((w) async => w.tryClear());
        expect(res, isTrue);
        expect(ok, isTrue);
      }

      //print('get all\n');
      {
        final dataset3 = await arr.operate((r) async => r.getAllItems());
        expect(dataset3, isEmpty);
      }

      await arr.delete();
      await arr.close();

      final endTime = DateTime.now();
      print('Duration: ${endTime.difference(startTime)}');
    };
