@Timeout(Duration(seconds: 120))

library veilid_support_integration_test;

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:veilid_test/veilid_test.dart';

import 'fixtures/fixtures.dart';
import 'test_dht_record_pool.dart';
import 'test_dht_short_array.dart';

void main() {
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

  group('Started Tests', () {
    setUpAll(veilidFixture.setUp);
    tearDownAll(veilidFixture.tearDown);

    // group('Crypto Tests', () {
    //   test('best cryptosystem', testBestCryptoSystem);
    //   test('get cryptosystem', testGetCryptoSystem);
    //   test('get cryptosystem invalid', testGetCryptoSystemInvalid);
    //   test('hash and verify password', testHashAndVerifyPassword);
    // });

    group('Attached Tests', () {
      setUpAll(veilidFixture.attach);
      tearDownAll(veilidFixture.detach);

      group('DHT Support Tests', () {
        setUpAll(updateProcessorFixture.setUp);
        setUpAll(tickerFixture.setUp);
        tearDownAll(tickerFixture.tearDown);
        tearDownAll(updateProcessorFixture.tearDown);

        test('create pool', testDHTRecordPoolCreate);

        // group('DHTRecordPool Tests', () {
        //   setUpAll(dhtRecordPoolFixture.setUp);
        //   tearDownAll(dhtRecordPoolFixture.tearDown);

        //   test('create/delete record', testDHTRecordCreateDelete);
        //   test('record scopes', testDHTRecordScopes);
        //   test('create/delete deep record', testDHTRecordDeepCreateDelete);
        // });

        group('DHTShortArray Tests', () {
          setUpAll(dhtRecordPoolFixture.setUp);
          tearDownAll(dhtRecordPoolFixture.tearDown);

          // test('create shortarray', testDHTShortArrayCreateDelete);
          test('add shortarray', testDHTShortArrayAdd);
        });
      });
    });
  });
}
