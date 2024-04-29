@Timeout(Duration(seconds: 60))

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'fixtures.dart';
import 'test_dht_record_pool.dart';
import 'test_dht_short_array.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final fixture = DefaultFixture();

  group('Started Tests', () {
    setUpAll(fixture.setUp);
    tearDownAll(fixture.tearDown);

    // group('Crypto Tests', () {
    //   test('best cryptosystem', testBestCryptoSystem);
    //   test('get cryptosystem', testGetCryptoSystem);
    //   test('get cryptosystem invalid', testGetCryptoSystemInvalid);
    //   test('hash and verify password', testHashAndVerifyPassword);
    // });

    group('Attached Tests', () {
      setUpAll(fixture.attach);
      tearDownAll(fixture.detach);

      group('DHT Support Tests', () {
        group('DHTRecordPool Tests', () {
          test('create pool', testDHTRecordPoolCreate);
        });
        group('DHTShortArray Tests', () {
          test('create shortarray', testDHTShortArrayCreate);
        });
      });
    });
  });
}
