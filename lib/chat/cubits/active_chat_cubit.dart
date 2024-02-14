import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:veilid_support/veilid_support.dart';

class ActiveChatCubit extends Cubit<TypedKey?> {
  ActiveChatCubit(super.initialState, this.setHasActiveChat);

  void setActiveChat(TypedKey? activeChatRemoteConversationRecordKey) {
    setHasActiveChat(activeChatRemoteConversationRecordKey != null);
    emit(activeChatRemoteConversationRecordKey);
  }

  void Function(bool) setHasActiveChat;
}
