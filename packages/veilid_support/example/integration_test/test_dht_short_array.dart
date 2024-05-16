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

      print('adding singles\n');
      {
        final res = await arr.operateWrite((w) async {
          for (var n = 4; n < 8; n++) {
            print('$n ');
            final success = await w.tryAddItem(dataset[n]);
            expect(success, isTrue);
          }
        });
        expect(res, isNull);
      }

      print('adding batch\n');
      {
        final res = await arr.operateWrite((w) async {
          print('${dataset.length ~/ 2}-${dataset.length}');
          final success = await w.tryAddItems(
              dataset.sublist(dataset.length ~/ 2, dataset.length));
          expect(success, isTrue);
        });
        expect(res, isNull);
      }

      print('inserting singles\n');
      {
        final res = await arr.operateWrite((w) async {
          for (var n = 0; n < 4; n++) {
            print('$n ');
            final success = await w.tryInsertItem(n, dataset[n]);
            expect(success, isTrue);
          }
        });
        expect(res, isNull);
      }

      print('inserting batch\n');
      {
        final res = await arr.operateWrite((w) async {
          print('8-${dataset.length ~/ 2}');
          final success = await w.tryInsertItems(
              8, dataset.sublist(8, dataset.length ~/ 2));
          expect(success, isTrue);
        });
        expect(res, isNull);
      }

      //print('get all\n');
      {
        final dataset2 = await arr.operate((r) async => r.getItemRange(0));
        expect(dataset2, equals(dataset));
      }
      {
        final dataset3 =
            await arr.operate((r) async => r.getItemRange(64, length: 128));
        expect(dataset3, equals(dataset.sublist(64, 64 + 128)));
      }

      //print('clear\n');
      {
        await arr.operateWrite((w) async => w.clear());
      }

      //print('get all\n');
      {
        final dataset4 = await arr.operate((r) async => r.getItemRange(0));
        expect(dataset4, isEmpty);
      }

      await arr.delete();
      await arr.close();

      final endTime = DateTime.now();
      print('Duration: ${endTime.difference(startTime)}');
    };
