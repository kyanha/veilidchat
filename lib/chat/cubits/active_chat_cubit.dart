import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../router/router.dart';

// XXX: if we ever want to have more than one chat 'open', we should put the
// operations and state for that here.

class ActiveChatCubit extends Cubit<TypedKey?> {
  ActiveChatCubit(super.initialState, {required RouterCubit routerCubit})
      : _routerCubit = routerCubit;

  void setActiveChat(TypedKey? activeChatLocalConversationRecordKey) {
    emit(activeChatLocalConversationRecordKey);
    _routerCubit.setHasActiveChat(activeChatLocalConversationRecordKey != null);
  }

  final RouterCubit _routerCubit;
}
