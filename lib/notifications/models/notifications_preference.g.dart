// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifications_preference.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NotificationsPreferenceImpl _$$NotificationsPreferenceImplFromJson(
        Map<String, dynamic> json) =>
    _$NotificationsPreferenceImpl(
      displayBetaWarning: json['display_beta_warning'] as bool? ?? true,
      enableBadge: json['enable_badge'] as bool? ?? true,
      enableNotifications: json['enable_notifications'] as bool? ?? true,
      messageNotificationContent: json['message_notification_content'] == null
          ? MessageNotificationContent.nameAndContent
          : MessageNotificationContent.fromJson(
              json['message_notification_content']),
      onInvitationAcceptedMode: json['on_invitation_accepted_mode'] == null
          ? NotificationMode.inAppOrPush
          : NotificationMode.fromJson(json['on_invitation_accepted_mode']),
      onInvitationAcceptedSound: json['on_invitation_accepted_sound'] == null
          ? SoundEffect.beepBaDeep
          : SoundEffect.fromJson(json['on_invitation_accepted_sound']),
      onMessageReceivedMode: json['on_message_received_mode'] == null
          ? NotificationMode.inAppOrPush
          : NotificationMode.fromJson(json['on_message_received_mode']),
      onMessageReceivedSound: json['on_message_received_sound'] == null
          ? SoundEffect.boop
          : SoundEffect.fromJson(json['on_message_received_sound']),
      onMessageSentSound: json['on_message_sent_sound'] == null
          ? SoundEffect.bonk
          : SoundEffect.fromJson(json['on_message_sent_sound']),
    );

Map<String, dynamic> _$$NotificationsPreferenceImplToJson(
        _$NotificationsPreferenceImpl instance) =>
    <String, dynamic>{
      'display_beta_warning': instance.displayBetaWarning,
      'enable_badge': instance.enableBadge,
      'enable_notifications': instance.enableNotifications,
      'message_notification_content':
          instance.messageNotificationContent.toJson(),
      'on_invitation_accepted_mode': instance.onInvitationAcceptedMode.toJson(),
      'on_invitation_accepted_sound':
          instance.onInvitationAcceptedSound.toJson(),
      'on_message_received_mode': instance.onMessageReceivedMode.toJson(),
      'on_message_received_sound': instance.onMessageReceivedSound.toJson(),
      'on_message_sent_sound': instance.onMessageSentSound.toJson(),
    };
