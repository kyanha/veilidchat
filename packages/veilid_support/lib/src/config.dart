import 'package:veilid/veilid.dart';

Map<String, dynamic> getDefaultVeilidPlatformConfig(
    bool isWeb, String appName) {
  if (isWeb) {
    return const VeilidWASMConfig(
            logging: VeilidWASMConfigLogging(
                performance: VeilidWASMConfigLoggingPerformance(
                    enabled: true,
                    level: VeilidConfigLogLevel.debug,
                    logsInTimings: true,
                    logsInConsole: false),
                api: VeilidWASMConfigLoggingApi(
                    enabled: true, level: VeilidConfigLogLevel.info)))
        .toJson();
  }
  return VeilidFFIConfig(
          logging: VeilidFFIConfigLogging(
              terminal: const VeilidFFIConfigLoggingTerminal(
                enabled: false,
                level: VeilidConfigLogLevel.debug,
              ),
              otlp: VeilidFFIConfigLoggingOtlp(
                  enabled: false,
                  level: VeilidConfigLogLevel.trace,
                  grpcEndpoint: '127.0.0.1:4317',
                  serviceName: appName),
              api: const VeilidFFIConfigLoggingApi(
                  enabled: true, level: VeilidConfigLogLevel.info)))
      .toJson();
}

Future<VeilidConfig> getVeilidConfig(bool isWeb, String appName) async {
  var config = await getDefaultVeilidConfig(appName);
  // ignore: do_not_use_environment
  if (const String.fromEnvironment('DELETE_TABLE_STORE') == '1') {
    config =
        config.copyWith(tableStore: config.tableStore.copyWith(delete: true));
  }
  // ignore: do_not_use_environment
  if (const String.fromEnvironment('DELETE_PROTECTED_STORE') == '1') {
    config = config.copyWith(
        protectedStore: config.protectedStore.copyWith(delete: true));
  }
  // ignore: do_not_use_environment
  if (const String.fromEnvironment('DELETE_BLOCK_STORE') == '1') {
    config =
        config.copyWith(blockStore: config.blockStore.copyWith(delete: true));
  }

  // ignore: do_not_use_environment
  const envNetwork = String.fromEnvironment('NETWORK');
  if (envNetwork.isNotEmpty) {
    final bootstrap = isWeb
        ? ['ws://bootstrap.$envNetwork.veilid.net:5150/ws']
        : ['bootstrap.$envNetwork.veilid.net'];
    config = config.copyWith(
        network: config.network.copyWith(
            routingTable:
                config.network.routingTable.copyWith(bootstrap: bootstrap)));
  }

  // ignore: do_not_use_environment
  const envNetworkKey = String.fromEnvironment('NETWORK_KEY');
  if (envNetworkKey.isNotEmpty) {
    config = config.copyWith(
        network: config.network.copyWith(networkKeyPassword: envNetworkKey));
  }

  // ignore: do_not_use_environment
  const envBootstrap = String.fromEnvironment('BOOTSTRAP');
  if (envBootstrap.isNotEmpty) {
    final bootstrap = envBootstrap.split(',').map((e) => e.trim()).toList();
    config = config.copyWith(
        network: config.network.copyWith(
            routingTable:
                config.network.routingTable.copyWith(bootstrap: bootstrap)));
  }

  return config.copyWith(
    capabilities:
        // XXX: Remove DHTV and DHTW when we get background sync implemented
        const VeilidConfigCapabilities(disable: ['DHTV', 'DHTW', 'TUNL']),
    protectedStore: config.protectedStore.copyWith(allowInsecureFallback: true),
    // network: config.network.copyWith(
    //         dht: config.network.dht.copyWith(
    //             getValueCount: 3,
    //             getValueFanout: 8,
    //             getValueTimeoutMs: 5000,
    //             setValueCount: 4,
    //             setValueFanout: 10,
    //             setValueTimeoutMs: 5000))
  );
}
