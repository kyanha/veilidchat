import 'package:veilid/veilid.dart';
import 'package:flutter/foundation.dart';
import 'processor.dart';

Future<String> getVeilidVersion() async {
  String veilidVersion;
  try {
    veilidVersion = Veilid.instance.veilidVersionString();
  } on Exception {
    veilidVersion = 'Failed to get veilid version.';
  }
  return veilidVersion;
}

// Initialize Veilid
// Call only once.
void _init() {
  if (kIsWeb) {
    var platformConfig = VeilidWASMConfig(
        logging: VeilidWASMConfigLogging(
            performance: VeilidWASMConfigLoggingPerformance(
                enabled: true,
                level: VeilidConfigLogLevel.debug,
                logsInTimings: true,
                logsInConsole: false),
            api: VeilidWASMConfigLoggingApi(
                enabled: true, level: VeilidConfigLogLevel.info)));
    Veilid.instance.initializeVeilidCore(platformConfig.json);
  } else {
    var platformConfig = VeilidFFIConfig(
        logging: VeilidFFIConfigLogging(
            terminal: VeilidFFIConfigLoggingTerminal(
              enabled: false,
              level: VeilidConfigLogLevel.debug,
            ),
            otlp: VeilidFFIConfigLoggingOtlp(
                enabled: false,
                level: VeilidConfigLogLevel.trace,
                grpcEndpoint: "localhost:4317",
                serviceName: "VeilidChat"),
            api: VeilidFFIConfigLoggingApi(
                enabled: true, level: VeilidConfigLogLevel.info)));
    Veilid.instance.initializeVeilidCore(platformConfig.json);
  }
}

// Called from FlutterFlow stub initialize() function upon Main page load
bool initialized = false;
Processor processor = Processor();

Future<void> initializeVeilid() async {
  if (initialized) {
    return;
  }

  // Init Veilid
  _init();

  // Startup Veilid
  await processor.startup();

  initialized = true;
}
