import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../notifications.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit(super.initialState);

  void info({required String text, String? title}) {
    emit(state.copyWith(
        queue: state.queue.add(NotificationItem(
            type: NotificationType.info, text: text, title: title))));
  }

  void error({required String text, String? title}) {
    emit(state.copyWith(
        queue: state.queue.add(NotificationItem(
            type: NotificationType.info, text: text, title: title))));
  }

  IList<NotificationItem> popAll() {
    final out = state.queue;
    emit(state.copyWith(queue: state.queue.clear()));
    return out;
  }
}
