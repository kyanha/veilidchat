import 'dart:async';
import 'dart:io';

import 'package:ansicolor/ansicolor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'init.dart';
import 'settings/preferences_repository.dart';
import 'theme/theme.dart';
import 'tools/tools.dart';

void main() async {
  // Disable all debugprints in release mode
  if (kReleaseMode) {
    debugPrint = (message, {wrapWidth}) {};
  }

  // Print our PID for debugging
  if (!kIsWeb) {
    debugPrint('VeilidChat PID: $pid');
  }

  // Ansi colors
  ansiColorDisabled = false;

  // Catch errors
  await runZonedGuarded(() async {
    // Logs
    initLoggy();

    // Prepare preferences from SharedPreferences and theme
    WidgetsFlutterBinding.ensureInitialized();
    await PreferencesRepository.instance.init();
    final initialThemeData =
        PreferencesRepository.instance.value.themePreferences.themeData();

    // Manage window on desktop platforms
    await initializeWindowControl();

    // Make localization delegate
    final localizationDelegate = await LocalizationDelegate.create(
        fallbackLocale: 'en_US', supportedLocales: ['en_US']);
    await initializeDateFormatting();

    // Start up Veilid and Veilid processor in the background
    unawaited(initializeVeilidChat());

    // Run the app
    // Hot reloads will only restart this part, not Veilid
    runApp(LocalizedApp(localizationDelegate,
        VeilidChatApp(initialThemeData: initialThemeData)));
  }, (error, stackTrace) {
    log.error('Dart Runtime: {$error}\n{$stackTrace}');
  });
}
