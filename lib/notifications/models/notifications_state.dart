import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'notifications_state.freezed.dart';

enum NotificationType {
  info,
  error,
}

@freezed
class NotificationItem with _$NotificationItem {
  const factory NotificationItem(
      {required NotificationType type,
      required String text,
      String? title}) = _NotificationItem;
}

@freezed
class NotificationsState with _$NotificationsState {
  const factory NotificationsState({required IList<NotificationItem> queue}) =
      _NotificationsState;
}
