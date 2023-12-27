import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import 'router/router.dart';
import 'tick.dart';

class VeilidChatApp extends StatelessWidget {
  const VeilidChatApp({
    required this.themeData,
    super.key,
  });

  final ThemeData themeData;

  @override
  Widget build(BuildContext context) {
    final localizationDelegate = LocalizedApp.of(context).delegate;

    return ThemeProvider(
        initTheme: themeData,
        builder: (_, theme) => LocalizationProvider(
              state: LocalizationProvider.of(context).state,
              child: BackgroundTicker(
                  builder: (context) => BlocProvider(
                        create: (context) => RouterCubit(),
                        child: MaterialApp.router(
                          debugShowCheckedModeBanner: false,
                          routerConfig: router(
                              routerCubit:
                                  BlocProvider.of<RouterCubit>(context)),
                          title: translate('app.title'),
                          theme: theme,
                          localizationsDelegates: [
                            GlobalMaterialLocalizations.delegate,
                            GlobalWidgetsLocalizations.delegate,
                            FormBuilderLocalizations.delegate,
                            localizationDelegate
                          ],
                          supportedLocales:
                              localizationDelegate.supportedLocales,
                          locale: localizationDelegate.currentLocale,
                        ),
                      )),
            ));
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ThemeData>('themeData', themeData));
  }
}
