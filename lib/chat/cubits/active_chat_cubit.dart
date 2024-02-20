import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../tools/tools.dart';

class ActiveChatCubit extends Cubit<TypedKey?> with BlocTools {
  ActiveChatCubit(super.initialState);

  void setActiveChat(TypedKey? activeChatRemoteConversationRecordKey) {
    emit(activeChatRemoteConversationRecordKey);
  }
}
