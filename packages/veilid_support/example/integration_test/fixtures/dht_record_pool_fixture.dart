import 'dart:async';

import 'package:async_tools/async_tools.dart';
import 'package:veilid_support/veilid_support.dart';
import 'package:veilid_test/veilid_test.dart';

class DHTRecordPoolFixture implements TickerFixtureTickable {
  DHTRecordPoolFixture(
      {required this.tickerFixture, required this.updateProcessorFixture});

  static final _fixtureMutex = Mutex();
  UpdateProcessorFixture updateProcessorFixture;
  TickerFixture tickerFixture;

  Future<void> setUp() async {
    await _fixtureMutex.acquire();
    await DHTRecordPool.init();
    tickerFixture.register(this);
  }

  Future<void> tearDown() async {
    assert(_fixtureMutex.isLocked, 'should not tearDown without setUp');
    tickerFixture.unregister(this);
    await DHTRecordPool.close();
    _fixtureMutex.release();
  }

  @override
  Future<void> onTick() async {
    if (!updateProcessorFixture
        .processorConnectionState.isPublicInternetReady) {
      return;
    }
    await DHTRecordPool.instance.tick();
  }
}
