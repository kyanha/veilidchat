import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:veilid_support/veilid_support.dart';

// XXX: if we ever want to have more than one chat 'open', we should put the
// operations and state for that here.

class ActiveChatCubit extends Cubit<TypedKey?> {
  ActiveChatCubit(super.initialState);

  void setActiveChat(TypedKey? activeChatLocalConversationRecordKey) {
    emit(activeChatLocalConversationRecordKey);
  }
}
