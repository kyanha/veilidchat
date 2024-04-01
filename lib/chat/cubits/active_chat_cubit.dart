import 'package:bloc_tools/bloc_tools.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:veilid_support/veilid_support.dart';

class ActiveChatCubit extends Cubit<TypedKey?> with BlocTools {
  ActiveChatCubit(super.initialState);

  void setActiveChat(TypedKey? activeChatRemoteConversationRecordKey) {
    emit(activeChatRemoteConversationRecordKey);
  }
}
