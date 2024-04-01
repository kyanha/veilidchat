import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import 'account_manager/account_manager.dart';
import 'router/router.dart';
import 'settings/settings.dart';
import 'tick.dart';
import 'veilid_processor/veilid_processor.dart';

class VeilidChatApp extends StatelessWidget {
  const VeilidChatApp({
    required this.initialThemeData,
    super.key,
  });

  static const String name = 'VeilidChat';

  final ThemeData initialThemeData;

  @override
  Widget build(BuildContext context) {
    final localizationDelegate = LocalizedApp.of(context).delegate;

    return ThemeProvider(
        initTheme: initialThemeData,
        builder: (_, theme) => LocalizationProvider(
              state: LocalizationProvider.of(context).state,
              child: MultiBlocProvider(
                  providers: [
                    BlocProvider<ConnectionStateCubit>(
                        create: (context) =>
                            ConnectionStateCubit(ProcessorRepository.instance)),
                    BlocProvider<RouterCubit>(
                      create: (context) =>
                          RouterCubit(AccountRepository.instance),
                    ),
                    BlocProvider<LocalAccountsCubit>(
                      create: (context) =>
                          LocalAccountsCubit(AccountRepository.instance),
                    ),
                    BlocProvider<UserLoginsCubit>(
                      create: (context) =>
                          UserLoginsCubit(AccountRepository.instance),
                    ),
                    BlocProvider<ActiveLocalAccountCubit>(
                      create: (context) =>
                          ActiveLocalAccountCubit(AccountRepository.instance),
                    ),
                    BlocProvider<PreferencesCubit>(
                      create: (context) =>
                          PreferencesCubit(PreferencesRepository.instance),
                    )
                  ],
                  child: BackgroundTicker(
                    builder: (context) => MaterialApp.router(
                      debugShowCheckedModeBanner: false,
                      routerConfig: context.watch<RouterCubit>().router(),
                      title: translate('app.title'),
                      theme: theme,
                      localizationsDelegates: [
                        GlobalMaterialLocalizations.delegate,
                        GlobalWidgetsLocalizations.delegate,
                        FormBuilderLocalizations.delegate,
                        localizationDelegate
                      ],
                      supportedLocales: localizationDelegate.supportedLocales,
                      locale: localizationDelegate.currentLocale,
                    ),
                  )),
            ));
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
        .add(DiagnosticsProperty<ThemeData>('themeData', initialThemeData));
  }
}
