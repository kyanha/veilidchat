import 'dart:async';

import 'package:async_tools/async_tools.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';

import '../theme/views/responsive.dart';
import 'tools.dart';

export 'package:window_manager/window_manager.dart' show TitleBarStyle;

enum OrientationCapability {
  normal,
  portraitOnly,
  landscapeOnly,
}

// Window Control
Future<void> initializeWindowControl() async {
  if (isDesktop) {
    await windowManager.ensureInitialized();

    const windowOptions = WindowOptions(
      size: Size(768, 1024),
      minimumSize: Size(400, 500),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
    );
    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await _asyncChangeWindowSetup(
          TitleBarStyle.hidden, OrientationCapability.normal);
      await windowManager.show();
      await windowManager.focus();
    });
  }
}

const kWindowSetup = '__windowSetup';

Future<void> _asyncChangeWindowSetup(TitleBarStyle titleBarStyle,
    OrientationCapability orientationCapability) async {
  if (isDesktop) {
    await windowManager.setTitleBarStyle(titleBarStyle);
  } else {
    switch (orientationCapability) {
      case OrientationCapability.normal:
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      case OrientationCapability.portraitOnly:
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
        ]);
      case OrientationCapability.landscapeOnly:
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
    }
  }
}

void changeWindowSetup(
    TitleBarStyle titleBarStyle, OrientationCapability orientationCapability) {
  singleFuture<void>(
      kWindowSetup,
      () async =>
          _asyncChangeWindowSetup(titleBarStyle, orientationCapability));
}

abstract class WindowSetupState<T extends StatefulWidget> extends State<T> {
  WindowSetupState(
      {required this.titleBarStyle, required this.orientationCapability});

  @override
  void initState() {
    changeWindowSetup(this.titleBarStyle, this.orientationCapability);
    super.initState();
  }

  @override
  void activate() {
    changeWindowSetup(this.titleBarStyle, this.orientationCapability);
    super.activate();
  }

  @override
  void deactivate() {
    changeWindowSetup(TitleBarStyle.normal, OrientationCapability.normal);
    super.deactivate();
  }

  ////////////////////////////////////////////////////////////////////////////
  final TitleBarStyle titleBarStyle;
  final OrientationCapability orientationCapability;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(EnumProperty<TitleBarStyle>('titleBarStyle', titleBarStyle))
      ..add(EnumProperty<OrientationCapability>(
          'orientationCapability', orientationCapability));
  }
}
