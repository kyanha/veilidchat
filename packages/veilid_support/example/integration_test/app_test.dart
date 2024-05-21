import 'package:flutter/foundation.dart';
import 'package:integration_test/integration_test.dart';
import 'package:test/test.dart';
import 'package:veilid_test/veilid_test.dart';

import 'fixtures/fixtures.dart';
import 'test_dht_log.dart';
import 'test_dht_record_pool.dart';
import 'test_dht_short_array.dart';

void main() {
  final startTime = DateTime.now();

  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final veilidFixture =
      DefaultVeilidFixture(programName: 'veilid_support integration test');
  final updateProcessorFixture =
      UpdateProcessorFixture(veilidFixture: veilidFixture);
  final tickerFixture =
      TickerFixture(updateProcessorFixture: updateProcessorFixture);
  final dhtRecordPoolFixture = DHTRecordPoolFixture(
      tickerFixture: tickerFixture,
      updateProcessorFixture: updateProcessorFixture);

  group(timeout: const Timeout(Duration(seconds: 240)), 'Started Tests', () {
    setUpAll(veilidFixture.setUp);
    tearDownAll(veilidFixture.tearDown);
    tearDownAll(() {
      final endTime = DateTime.now();
      debugPrintSynchronously('Duration: ${endTime.difference(startTime)}');
    });

    group('Attached Tests', () {
      setUpAll(veilidFixture.attach);
      tearDownAll(veilidFixture.detach);

      group('DHT Support Tests', () {
        setUpAll(updateProcessorFixture.setUp);
        setUpAll(tickerFixture.setUp);
        tearDownAll(tickerFixture.tearDown);
        tearDownAll(updateProcessorFixture.tearDown);

        test('create pool', testDHTRecordPoolCreate);

        group('DHTRecordPool Tests', () {
          setUpAll(dhtRecordPoolFixture.setUp);
          tearDownAll(dhtRecordPoolFixture.tearDown);

          test('create/delete record', testDHTRecordCreateDelete);
          test('record scopes', testDHTRecordScopes);
          test('create/delete deep record', testDHTRecordDeepCreateDelete);
        });

        group('DHTShortArray Tests', () {
          setUpAll(dhtRecordPoolFixture.setUp);
          tearDownAll(dhtRecordPoolFixture.tearDown);

          for (final stride in [256, 16 /*64, 32, 16, 8, 4, 2, 1 */]) {
            test('create shortarray stride=$stride',
                makeTestDHTShortArrayCreateDelete(stride: stride));
            test('add shortarray stride=$stride',
                makeTestDHTShortArrayAdd(stride: stride));
          }
        });

        group('DHTLog Tests', () {
          setUpAll(dhtRecordPoolFixture.setUp);
          tearDownAll(dhtRecordPoolFixture.tearDown);

          for (final stride in [256, 16 /*64, 32, 16, 8, 4, 2, 1 */]) {
            test('create log stride=$stride',
                makeTestDHTLogCreateDelete(stride: stride));
            test(
              timeout: const Timeout(Duration(seconds: 480)),
              'add/truncate log stride=$stride',
              makeTestDHTLogAddTruncate(stride: stride),
            );
          }
        });
      });
    });
  });
}
