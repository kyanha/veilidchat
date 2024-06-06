import 'package:async_tools/async_tools.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' show Message, User;
import 'package:flutter_chat_ui/flutter_chat_ui.dart' show ChatState;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:veilid_support/veilid_support.dart';

import 'window_state.dart';

part 'chat_component_state.freezed.dart';

@freezed
class ChatComponentState with _$ChatComponentState {
  const factory ChatComponentState(
      {
      // GlobalKey for the chat
      required GlobalKey<ChatState> chatKey,
      // ScrollController for the chat
      required AutoScrollController scrollController,
      // Local user
      required User localUser,
      // Remote users
      required IMap<TypedKey, User> remoteUsers,
      // Messages state
      required AsyncValue<WindowState<Message>> messageWindow,
      // Title of the chat
      required String title}) = _ChatComponentState;
}

extension ChatComponentStateExt on ChatComponentState {
  //
}
