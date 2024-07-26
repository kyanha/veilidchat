import 'package:change_case/change_case.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'notifications_preference.freezed.dart';
part 'notifications_preference.g.dart';

@freezed
class NotificationsPreference with _$NotificationsPreference {
  const factory NotificationsPreference({
    @Default(true) bool displayBetaWarning,
    @Default(true) bool enableBadge,
    @Default(true) bool enableNotifications,
    @Default(MessageNotificationContent.nameAndContent)
    MessageNotificationContent messageNotificationContent,
    @Default(NotificationMode.inAppOrPush)
    NotificationMode onInvitationAcceptedMode,
    @Default(SoundEffect.beepBaDeep) SoundEffect onInvitationAcceptedSound,
    @Default(NotificationMode.inAppOrPush)
    NotificationMode onMessageReceivedMode,
    @Default(SoundEffect.boop) SoundEffect onMessageReceivedSound,
    @Default(SoundEffect.bonk) SoundEffect onMessageSentSound,
  }) = _NotificationsPreference;

  factory NotificationsPreference.fromJson(dynamic json) =>
      _$NotificationsPreferenceFromJson(json as Map<String, dynamic>);

  static const NotificationsPreference defaults = NotificationsPreference();
}

enum NotificationMode {
  none,
  inApp,
  push,
  inAppOrPush;

  factory NotificationMode.fromJson(dynamic j) =>
      NotificationMode.values.byName((j as String).toCamelCase());
  String toJson() => name.toPascalCase();

  static const NotificationMode defaults = NotificationMode.none;
}

enum MessageNotificationContent {
  nothing,
  nameOnly,
  nameAndContent;

  factory MessageNotificationContent.fromJson(dynamic j) =>
      MessageNotificationContent.values.byName((j as String).toCamelCase());
  String toJson() => name.toPascalCase();

  static const MessageNotificationContent defaults =
      MessageNotificationContent.nothing;
}

enum SoundEffect {
  none,
  bonk,
  boop,
  baDeep,
  beepBaDeep,
  custom;

  factory SoundEffect.fromJson(dynamic j) =>
      SoundEffect.values.byName((j as String).toCamelCase());
  String toJson() => name.toPascalCase();

  static const SoundEffect defaults = SoundEffect.none;
}
