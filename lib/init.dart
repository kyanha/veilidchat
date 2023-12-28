import 'dart:async';

import 'app.dart';
import 'local_account_manager/account_manager.dart';
import 'processor.dart';
import 'tools/tools.dart';
import '../packages/veilid_support/veilid_support.dart';

final Completer<Veilid> eventualVeilid = Completer<Veilid>();
final Processor processor = Processor();

final Completer<void> eventualInitialized = Completer<void>();

// Initialize Veilid
Future<void> initializeVeilid() async {
  // Ensure this runs only once
  if (eventualVeilid.isCompleted) {
    return;
  }

  // Init Veilid
  Veilid.instance
      .initializeVeilidCore(getDefaultVeilidPlatformConfig(VeilidChatApp.name));

  // Veilid logging
  initVeilidLog();

  // Startup Veilid
  await processor.startup();

  // Share the initialized veilid instance to the rest of the app
  eventualVeilid.complete(Veilid.instance);
}

// Initialize repositories
Future<void> initializeRepositories() async {
  await AccountRepository.instance.init();
}

Future<void> initializeVeilidChat() async {
  log.info("Initializing Veilid");
  await initializeVeilid();
  log.info("Initializing Repositories");
  await initializeRepositories();

  eventualInitialized.complete();
}
