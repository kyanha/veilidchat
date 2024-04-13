import 'package:async_tools/async_tools.dart';
import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quickalert/quickalert.dart';
import 'package:signal_strength_indicator/signal_strength_indicator.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../theme/theme.dart';
import '../cubit/connection_state_cubit.dart';

class SignalStrengthMeterWidget extends StatelessWidget {
  const SignalStrengthMeterWidget({super.key});

  @override
  // ignore: prefer_expression_function_bodies
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scale = theme.extension<ScaleScheme>()!;

    const iconSize = 16.0;

    return BlocBuilder<ConnectionStateCubit,
        AsyncValue<ProcessorConnectionState>>(builder: (context, state) {
      late final Widget iconWidget;
      state.when(
          data: (connectionState) {
            late final double value;
            late final Color color;
            late final Color inactiveColor;

            switch (connectionState.attachment.state) {
              case AttachmentState.detached:
                iconWidget = Icon(Icons.signal_cellular_nodata,
                    size: iconSize, color: scale.primaryScale.primaryText);
                return;
              case AttachmentState.detaching:
                iconWidget = Icon(Icons.signal_cellular_off,
                    size: iconSize, color: scale.primaryScale.primaryText);
                return;
              case AttachmentState.attaching:
                value = 0;
                color = scale.primaryScale.primaryText;
              case AttachmentState.attachedWeak:
                value = 1;
                color = scale.primaryScale.primaryText;
              case AttachmentState.attachedStrong:
                value = 2;
                color = scale.primaryScale.primaryText;
              case AttachmentState.attachedGood:
                value = 3;
                color = scale.primaryScale.primaryText;
              case AttachmentState.fullyAttached:
                value = 4;
                color = scale.primaryScale.primaryText;
              case AttachmentState.overAttached:
                value = 4;
                color = scale.primaryScale.primaryText;
            }
            inactiveColor = scale.primaryScale.primaryText;

            iconWidget = SignalStrengthIndicator.bars(
                value: value,
                activeColor: color,
                inactiveColor: inactiveColor,
                size: iconSize,
                barCount: 4,
                spacing: 2);
          },
          loading: () => {iconWidget = const Icon(Icons.warning)},
          error: (e, st) => {
                iconWidget = const Icon(Icons.error).onTap(
                  () async => QuickAlert.show(
                      type: QuickAlertType.error,
                      context: context,
                      title: 'Error',
                      text: 'Error: {e}\n StackTrace: {st}'),
                )
              });

      return GestureDetector(
          onLongPress: () async {
            await GoRouterHelper(context).push('/developer');
          },
          child: iconWidget);
    });
  }
}
