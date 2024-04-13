import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';

import 'scale_scheme.dart';

ChatTheme makeChatTheme(ScaleScheme scale, TextTheme textTheme) =>
    DefaultChatTheme(
        primaryColor: scale.primaryScale.calloutBackground,
        secondaryColor: scale.secondaryScale.calloutBackground,
        backgroundColor: scale.grayScale.appBackground,
        sendButtonIcon: Image.asset(
          'assets/icon-send.png',
          color: scale.primaryScale.borderText,
          package: 'flutter_chat_ui',
        ),
        inputBackgroundColor: Colors.blue,
        inputBorderRadius: BorderRadius.zero,
        inputTextDecoration: InputDecoration(
          filled: true,
          fillColor: scale.primaryScale.elementBackground,
          isDense: true,
          contentPadding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
          border: const OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.all(Radius.circular(8))),
          focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.all(Radius.circular(8))),
        ),
        inputContainerDecoration:
            BoxDecoration(color: scale.primaryScale.border),
        inputPadding: const EdgeInsets.all(9),
        inputTextColor: scale.primaryScale.appText,
        attachmentButtonIcon: const Icon(Icons.attach_file),
        sentMessageBodyTextStyle: TextStyle(
          color: scale.primaryScale.calloutText,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          height: 1.5,
        ),
        sentEmojiMessageTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 64,
        ),
        receivedMessageBodyTextStyle: TextStyle(
          color: scale.secondaryScale.calloutText,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          height: 1.5,
        ),
        receivedEmojiMessageTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 64,
        ));
