import 'dart:async';
import 'dart:io';

import 'package:ansicolor/ansicolor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
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

  Future<void> mainFunc() async {
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

    // Run the app
    // Hot reloads will only restart this part, not Veilid
    runApp(LocalizedApp(localizationDelegate,
        VeilidChatApp(initialThemeData: initialThemeData)));
  }

  if (kDebugMode) {
    // In debug mode, run the app without catching exceptions for debugging
    await mainFunc();
  } else {
    // Catch errors in production without killing the app
    await runZonedGuarded(mainFunc, (error, stackTrace) {
      log.error('Dart Runtime: {$error}\n{$stackTrace}');
    });
  }
}
