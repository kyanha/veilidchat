import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motion_toast/motion_toast.dart';

import '../../theme/theme.dart';
import '../notifications.dart';

class NotificationsWidget extends StatelessWidget {
  const NotificationsWidget({required Widget child, super.key})
      : _child = child;

  ////////////////////////////////////////////////////////////////////////////
  // Public API

  @override
  Widget build(BuildContext context) {
    final notificationsCubit = context.read<NotificationsCubit>();

    return BlocListener<NotificationsCubit, NotificationsState>(
        bloc: notificationsCubit,
        listener: (context, state) {
          if (state.queue.isNotEmpty) {
            final queue = notificationsCubit.popAll();
            for (final notificationItem in queue) {
              switch (notificationItem.type) {
                case NotificationType.info:
                  _info(
                      context: context,
                      text: notificationItem.text,
                      title: notificationItem.title);
                case NotificationType.error:
                  _error(
                      context: context,
                      text: notificationItem.text,
                      title: notificationItem.title);
              }
            }
          }
        },
        child: _child);
  }

  ////////////////////////////////////////////////////////////////////////////
  // Private Implementation

  void _info(
      {required BuildContext context, required String text, String? title}) {
    final theme = Theme.of(context);
    final scale = theme.extension<ScaleScheme>()!;
    final scaleConfig = theme.extension<ScaleConfig>()!;

    MotionToast(
      title: title != null ? Text(title) : null,
      description: Text(text),
      constraints: BoxConstraints.loose(const Size(400, 100)),
      contentPadding: const EdgeInsets.all(16),
      primaryColor: scale.tertiaryScale.elementBackground,
      secondaryColor: scale.tertiaryScale.calloutBackground,
      borderRadius: 12 * scaleConfig.borderRadiusScale,
      toastDuration: const Duration(seconds: 2),
      animationDuration: const Duration(milliseconds: 500),
      displayBorder: scaleConfig.useVisualIndicators,
      icon: Icons.info,
    ).show(context);
  }

  void _error(
      {required BuildContext context, required String text, String? title}) {
    final theme = Theme.of(context);
    final scale = theme.extension<ScaleScheme>()!;
    final scaleConfig = theme.extension<ScaleConfig>()!;

    MotionToast(
      title: title != null ? Text(title) : null,
      description: Text(text),
      constraints: BoxConstraints.loose(const Size(400, 100)),
      contentPadding: const EdgeInsets.all(16),
      primaryColor: scale.errorScale.elementBackground,
      secondaryColor: scale.errorScale.calloutBackground,
      borderRadius: 12 * scaleConfig.borderRadiusScale,
      toastDuration: const Duration(seconds: 4),
      animationDuration: const Duration(milliseconds: 1000),
      displayBorder: scaleConfig.useVisualIndicators,
      icon: Icons.error,
    ).show(context);
  }

  ////////////////////////////////////////////////////////////////////////////

  final Widget _child;
}
