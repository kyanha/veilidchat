import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_translate/flutter_translate.dart';

import '../../settings/settings.dart';
import '../../theme/theme.dart';
import '../notifications.dart';

const String formFieldDisplayBetaWarning = 'displayBetaWarning';
const String formFieldEnableBadge = 'enableBadge';
const String formFieldEnableNotifications = 'enableNotifications';
const String formFieldMessageNotificationContent = 'messageNotificationContent';
const String formFieldInvitationAcceptMode = 'invitationAcceptMode';
const String formFieldInvitationAcceptSound = 'invitationAcceptSound';
const String formFieldMessageReceivedMode = 'messageReceivedMode';
const String formFieldMessageReceivedSound = 'messageReceivedSound';
const String formFieldMessageSentSound = 'messageSentSound';

Widget buildSettingsPageNotificationPreferences(
    {required BuildContext context, required void Function() onChanged}) {
  final theme = Theme.of(context);
  final scale = theme.extension<ScaleScheme>()!;
  final scaleConfig = theme.extension<ScaleConfig>()!;
  final textTheme = theme.textTheme;

  final preferencesRepository = PreferencesRepository.instance;
  final notificationsPreference =
      preferencesRepository.value.notificationsPreference;

  Future<void> updatePreferences(
      NotificationsPreference newNotificationsPreference) async {
    final newPrefs = preferencesRepository.value
        .copyWith(notificationsPreference: newNotificationsPreference);
    await preferencesRepository.set(newPrefs);
    onChanged();
  }

  List<DropdownMenuItem<NotificationMode>> notificationModeItems() {
    final out = <DropdownMenuItem<NotificationMode>>[];
    final items = [
      (NotificationMode.none, true, translate('settings_page.none')),
      (NotificationMode.inApp, true, translate('settings_page.in_app')),
      (NotificationMode.push, false, translate('settings_page.push')),
      (
        NotificationMode.inAppOrPush,
        true,
        translate('settings_page.in_app_or_push')
      ),
    ];
    for (final x in items) {
      out.add(DropdownMenuItem(
          value: x.$1,
          enabled: x.$2,
          child: Text(x.$3, style: textTheme.labelSmall)));
    }
    return out;
  }

  List<DropdownMenuItem<SoundEffect>> soundEffectItems() {
    final out = <DropdownMenuItem<SoundEffect>>[];
    final items = [
      (SoundEffect.none, true, translate('settings_page.none')),
      (SoundEffect.bonk, true, translate('settings_page.bonk')),
      (SoundEffect.boop, true, translate('settings_page.boop')),
      (SoundEffect.baDeep, true, translate('settings_page.badeep')),
      (SoundEffect.beepBaDeep, true, translate('settings_page.beep_badeep')),
      (SoundEffect.custom, false, translate('settings_page.custom')),
    ];
    for (final x in items) {
      out.add(DropdownMenuItem(
          value: x.$1,
          enabled: x.$2,
          child: Text(x.$3, style: textTheme.labelSmall)));
    }
    return out;
  }

  List<DropdownMenuItem<MessageNotificationContent>>
      messageNotificationContentItems() {
    final out = <DropdownMenuItem<MessageNotificationContent>>[];
    final items = [
      (
        MessageNotificationContent.nameAndContent,
        true,
        translate('settings_page.name_and_content')
      ),
      (
        MessageNotificationContent.nameOnly,
        true,
        translate('settings_page.name_only')
      ),
      (
        MessageNotificationContent.nothing,
        true,
        translate('settings_page.nothing')
      ),
    ];
    for (final x in items) {
      out.add(DropdownMenuItem(
          value: x.$1,
          enabled: x.$2,
          child: Text(x.$3, style: textTheme.labelSmall)));
    }
    return out;
  }

  return DecoratedBox(
    decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
            side: BorderSide(width: 2, color: scale.primaryScale.border),
            borderRadius:
                BorderRadius.circular(8 * scaleConfig.borderRadiusScale))),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      // Display Beta Warning
      FormBuilderCheckbox(
          name: formFieldDisplayBetaWarning,
          side: BorderSide(color: scale.primaryScale.border, width: 2),
          title: Text(translate('settings_page.display_beta_warning'),
              style: textTheme.labelMedium),
          initialValue: notificationsPreference.displayBetaWarning,
          onChanged: (value) async {
            if (value == null) {
              return;
            }
            final newNotificationsPreference =
                notificationsPreference.copyWith(displayBetaWarning: value);

            await updatePreferences(newNotificationsPreference);
          }),
      // Enable Badge
      FormBuilderCheckbox(
          name: formFieldEnableBadge,
          side: BorderSide(color: scale.primaryScale.border, width: 2),
          title: Text(translate('settings_page.enable_badge'),
              style: textTheme.labelMedium),
          initialValue: notificationsPreference.enableBadge,
          onChanged: (value) async {
            if (value == null) {
              return;
            }
            final newNotificationsPreference =
                notificationsPreference.copyWith(enableBadge: value);
            await updatePreferences(newNotificationsPreference);
          }),
      // Enable Notifications
      FormBuilderCheckbox(
          name: formFieldEnableNotifications,
          side: BorderSide(color: scale.primaryScale.border, width: 2),
          title: Text(translate('settings_page.enable_notifications'),
              style: textTheme.labelMedium),
          initialValue: notificationsPreference.enableNotifications,
          onChanged: (value) async {
            if (value == null) {
              return;
            }
            final newNotificationsPreference =
                notificationsPreference.copyWith(enableNotifications: value);
            await updatePreferences(newNotificationsPreference);
          }),

      FormBuilderDropdown(
        name: formFieldMessageNotificationContent,
        isDense: false,
        decoration: InputDecoration(
            labelText: translate('settings_page.message_notification_content')),
        enabled: notificationsPreference.enableNotifications,
        initialValue: notificationsPreference.messageNotificationContent,
        onChanged: (value) async {
          if (value == null) {
            return;
          }
          final newNotificationsPreference = notificationsPreference.copyWith(
              messageNotificationContent: value);
          await updatePreferences(newNotificationsPreference);
        },
        items: messageNotificationContentItems(),
      ).paddingAll(8),

      // Notifications
      Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            TableRow(children: [
              // Invitation accepted
              Text(
                      textAlign: TextAlign.right,
                      translate('settings_page.invitation_accepted'))
                  .paddingAll(8),
              FormBuilderDropdown(
                name: formFieldInvitationAcceptMode,
                isDense: false,
                enabled: notificationsPreference.enableNotifications,
                initialValue: notificationsPreference.onInvitationAcceptedMode,
                onChanged: (value) async {
                  if (value == null) {
                    return;
                  }
                  final newNotificationsPreference = notificationsPreference
                      .copyWith(onInvitationAcceptedMode: value);
                  await updatePreferences(newNotificationsPreference);
                },
                items: notificationModeItems(),
              ).paddingAll(4),
              FormBuilderDropdown(
                name: formFieldInvitationAcceptSound,
                isDense: false,
                enabled: notificationsPreference.enableNotifications,
                initialValue: notificationsPreference.onInvitationAcceptedSound,
                onChanged: (value) async {
                  if (value == null) {
                    return;
                  }
                  final newNotificationsPreference = notificationsPreference
                      .copyWith(onInvitationAcceptedSound: value);
                  await updatePreferences(newNotificationsPreference);
                },
                items: soundEffectItems(),
              ).paddingAll(4)
            ]),
            // Message received
            TableRow(children: [
              Text(
                      textAlign: TextAlign.right,
                      translate('settings_page.message_received'))
                  .paddingAll(8),
              FormBuilderDropdown(
                name: formFieldMessageReceivedMode,
                isDense: false,
                enabled: notificationsPreference.enableNotifications,
                initialValue: notificationsPreference.onMessageReceivedMode,
                onChanged: (value) async {
                  if (value == null) {
                    return;
                  }
                  final newNotificationsPreference = notificationsPreference
                      .copyWith(onMessageReceivedMode: value);
                  await updatePreferences(newNotificationsPreference);
                },
                items: notificationModeItems(),
              ).paddingAll(4),
              FormBuilderDropdown(
                name: formFieldMessageReceivedSound,
                isDense: false,
                enabled: notificationsPreference.enableNotifications,
                initialValue: notificationsPreference.onMessageReceivedSound,
                onChanged: (value) async {
                  if (value == null) {
                    return;
                  }
                  final newNotificationsPreference = notificationsPreference
                      .copyWith(onMessageReceivedSound: value);
                  await updatePreferences(newNotificationsPreference);
                },
                items: soundEffectItems(),
              ).paddingAll(4)
            ]),

            // Message sent
            TableRow(children: [
              Text(
                      textAlign: TextAlign.right,
                      translate('settings_page.message_sent'))
                  .paddingAll(8),
              const SizedBox.shrink(),
              FormBuilderDropdown(
                name: formFieldMessageSentSound,
                isDense: false,
                enabled: notificationsPreference.enableNotifications,
                initialValue: notificationsPreference.onMessageSentSound,
                onChanged: (value) async {
                  if (value == null) {
                    return;
                  }
                  final newNotificationsPreference = notificationsPreference
                      .copyWith(onMessageSentSound: value);
                  await updatePreferences(newNotificationsPreference);
                },
                items: soundEffectItems(),
              ).paddingAll(4)
            ]),
          ]).paddingAll(8)
    ]).paddingAll(8),
  );
}
