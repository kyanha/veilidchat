import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:veilid_support/veilid_support.dart';

import 'account_manager/account_manager.dart';
import 'app.dart';
import 'tools/tools.dart';
import 'veilid_processor/veilid_processor.dart';

final Completer<void> eventualInitialized = Completer<void>();

// Initialize Veilid
Future<void> initializeVeilid() async {
  // Init Veilid
  Veilid.instance.initializeVeilidCore(
      getDefaultVeilidPlatformConfig(kIsWeb, VeilidChatApp.name));

  // Veilid logging
  initVeilidLog(kDebugMode);

  // Startup Veilid
  await ProcessorRepository.instance.startup();

  // DHT Record Pool
  await DHTRecordPool.init();
}

// Initialize repositories
Future<void> initializeRepositories() async {
  await AccountRepository.instance.init();
}

Future<void> initializeVeilidChat() async {
  log.info('Initializing Veilid');
  await initializeVeilid();
  log.info('Initializing Repositories');
  await initializeRepositories();

  eventualInitialized.complete();
}
