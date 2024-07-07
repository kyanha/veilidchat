// ignore_for_file: always_put_required_named_parameters_first

import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';

import 'scale_scheme.dart';

ChatTheme makeChatTheme(
        ScaleScheme scale, ScaleConfig scaleConfig, TextTheme textTheme) =>
    DefaultChatTheme(
        primaryColor: scaleConfig.preferBorders
            ? scale.primaryScale.calloutText
            : scale.primaryScale.calloutBackground,
        secondaryColor: scaleConfig.preferBorders
            ? scale.secondaryScale.calloutText
            : scale.secondaryScale.calloutBackground,
        backgroundColor: scale.grayScale.appBackground,
        messageBorderRadius: scaleConfig.borderRadiusScale * 16,
        bubbleBorderSide: scaleConfig.preferBorders
            ? BorderSide(
                color: scale.primaryScale.calloutBackground,
                width: 2,
              )
            : null,
        sendButtonIcon: Image.asset(
          'assets/icon-send.png',
          color: scaleConfig.preferBorders
              ? scale.primaryScale.border
              : scale.primaryScale.borderText,
          package: 'flutter_chat_ui',
        ),
        inputBackgroundColor: Colors.blue,
        inputBorderRadius: BorderRadius.zero,
        inputTextDecoration: InputDecoration(
          filled: !scaleConfig.preferBorders,
          fillColor: scale.primaryScale.subtleBackground,
          isDense: true,
          contentPadding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
          disabledBorder: OutlineInputBorder(
              borderSide: scaleConfig.preferBorders
                  ? BorderSide(color: scale.grayScale.border, width: 2)
                  : BorderSide.none,
              borderRadius: BorderRadius.all(
                  Radius.circular(8 * scaleConfig.borderRadiusScale))),
          enabledBorder: OutlineInputBorder(
              borderSide: scaleConfig.preferBorders
                  ? BorderSide(color: scale.primaryScale.border, width: 2)
                  : BorderSide.none,
              borderRadius: BorderRadius.all(
                  Radius.circular(8 * scaleConfig.borderRadiusScale))),
          focusedBorder: OutlineInputBorder(
              borderSide: scaleConfig.preferBorders
                  ? BorderSide(color: scale.primaryScale.border, width: 2)
                  : BorderSide.none,
              borderRadius: BorderRadius.all(
                  Radius.circular(8 * scaleConfig.borderRadiusScale))),
        ),
        inputContainerDecoration: BoxDecoration(
            border: scaleConfig.preferBorders
                ? Border(
                    top: BorderSide(color: scale.primaryScale.border, width: 2))
                : null,
            color: scaleConfig.preferBorders
                ? scale.primaryScale.elementBackground
                : scale.primaryScale.border),
        inputPadding: const EdgeInsets.all(12),
        inputTextColor: !scaleConfig.preferBorders
            ? scale.primaryScale.appText
            : scale.primaryScale.border,
        attachmentButtonIcon: const Icon(Icons.attach_file),
        sentMessageBodyTextStyle: textTheme.bodyLarge!.copyWith(
          color: scaleConfig.preferBorders
              ? scale.primaryScale.calloutBackground
              : scale.primaryScale.calloutText,
        ),
        sentEmojiMessageTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 64,
        ),
        receivedMessageBodyTextStyle: TextStyle(
          color: scaleConfig.preferBorders
              ? scale.secondaryScale.calloutBackground
              : scale.secondaryScale.calloutText,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          height: 1.5,
        ),
        receivedEmojiMessageTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 64,
        ));

class EditedChatTheme extends ChatTheme {
  const EditedChatTheme({
    required super.attachmentButtonIcon,
    required super.attachmentButtonMargin,
    required super.backgroundColor,
    super.bubbleMargin,
    required super.dateDividerMargin,
    required super.dateDividerTextStyle,
    required super.deliveredIcon,
    required super.documentIcon,
    required super.emptyChatPlaceholderTextStyle,
    required super.errorColor,
    required super.errorIcon,
    required super.inputBackgroundColor,
    required super.inputSurfaceTintColor,
    required super.inputElevation,
    required super.inputBorderRadius,
    super.inputContainerDecoration,
    required super.inputMargin,
    required super.inputPadding,
    required super.inputTextColor,
    super.inputTextCursorColor,
    required super.inputTextDecoration,
    required super.inputTextStyle,
    required super.messageBorderRadius,
    required super.messageInsetsHorizontal,
    required super.messageInsetsVertical,
    required super.messageMaxWidth,
    required super.primaryColor,
    required super.receivedEmojiMessageTextStyle,
    super.receivedMessageBodyBoldTextStyle,
    super.receivedMessageBodyCodeTextStyle,
    super.receivedMessageBodyLinkTextStyle,
    required super.receivedMessageBodyTextStyle,
    required super.receivedMessageCaptionTextStyle,
    required super.receivedMessageDocumentIconColor,
    required super.receivedMessageLinkDescriptionTextStyle,
    required super.receivedMessageLinkTitleTextStyle,
    required super.secondaryColor,
    required super.seenIcon,
    required super.sendButtonIcon,
    required super.sendButtonMargin,
    required super.sendingIcon,
    required super.sentEmojiMessageTextStyle,
    super.sentMessageBodyBoldTextStyle,
    super.sentMessageBodyCodeTextStyle,
    super.sentMessageBodyLinkTextStyle,
    required super.sentMessageBodyTextStyle,
    required super.sentMessageCaptionTextStyle,
    required super.sentMessageDocumentIconColor,
    required super.sentMessageLinkDescriptionTextStyle,
    required super.sentMessageLinkTitleTextStyle,
    required super.statusIconPadding,
    required super.systemMessageTheme,
    required super.typingIndicatorTheme,
    required super.unreadHeaderTheme,
    required super.userAvatarImageBackgroundColor,
    required super.userAvatarNameColors,
    required super.userAvatarTextStyle,
    required super.userNameTextStyle,
    super.highlightMessageColor,
  });
}

class ChatThemeEditor {
  ChatThemeEditor(ChatTheme base)
      : attachmentButtonIcon = base.attachmentButtonIcon,
        attachmentButtonMargin = base.attachmentButtonMargin,
        backgroundColor = base.backgroundColor,
        bubbleMargin = base.bubbleMargin,
        dateDividerMargin = base.dateDividerMargin,
        dateDividerTextStyle = base.dateDividerTextStyle,
        deliveredIcon = base.deliveredIcon,
        documentIcon = base.documentIcon,
        emptyChatPlaceholderTextStyle = base.emptyChatPlaceholderTextStyle,
        errorColor = base.errorColor,
        errorIcon = base.errorIcon,
        inputBackgroundColor = base.inputBackgroundColor,
        inputSurfaceTintColor = base.inputSurfaceTintColor,
        inputElevation = base.inputElevation,
        inputBorderRadius = base.inputBorderRadius,
        inputContainerDecoration = base.inputContainerDecoration,
        inputMargin = base.inputMargin,
        inputPadding = base.inputPadding,
        inputTextColor = base.inputTextColor,
        inputTextCursorColor = base.inputTextCursorColor,
        inputTextDecoration = base.inputTextDecoration,
        inputTextStyle = base.inputTextStyle,
        messageBorderRadius = base.messageBorderRadius,
        messageInsetsHorizontal = base.messageInsetsHorizontal,
        messageInsetsVertical = base.messageInsetsVertical,
        messageMaxWidth = base.messageMaxWidth,
        primaryColor = base.primaryColor,
        receivedEmojiMessageTextStyle = base.receivedEmojiMessageTextStyle,
        receivedMessageBodyBoldTextStyle =
            base.receivedMessageBodyBoldTextStyle,
        receivedMessageBodyCodeTextStyle =
            base.receivedMessageBodyCodeTextStyle,
        receivedMessageBodyLinkTextStyle =
            base.receivedMessageBodyLinkTextStyle,
        receivedMessageBodyTextStyle = base.receivedMessageBodyTextStyle,
        receivedMessageCaptionTextStyle = base.receivedMessageCaptionTextStyle,
        receivedMessageDocumentIconColor =
            base.receivedMessageDocumentIconColor,
        receivedMessageLinkDescriptionTextStyle =
            base.receivedMessageLinkDescriptionTextStyle,
        receivedMessageLinkTitleTextStyle =
            base.receivedMessageLinkTitleTextStyle,
        secondaryColor = base.secondaryColor,
        seenIcon = base.seenIcon,
        sendButtonIcon = base.sendButtonIcon,
        sendButtonMargin = base.sendButtonMargin,
        sendingIcon = base.sendingIcon,
        sentEmojiMessageTextStyle = base.sentEmojiMessageTextStyle,
        sentMessageBodyBoldTextStyle = base.sentMessageBodyBoldTextStyle,
        sentMessageBodyCodeTextStyle = base.sentMessageBodyCodeTextStyle,
        sentMessageBodyLinkTextStyle = base.sentMessageBodyLinkTextStyle,
        sentMessageBodyTextStyle = base.sentMessageBodyTextStyle,
        sentMessageCaptionTextStyle = base.sentMessageCaptionTextStyle,
        sentMessageDocumentIconColor = base.sentMessageDocumentIconColor,
        sentMessageLinkDescriptionTextStyle =
            base.sentMessageLinkDescriptionTextStyle,
        sentMessageLinkTitleTextStyle = base.sentMessageLinkTitleTextStyle,
        statusIconPadding = base.statusIconPadding,
        systemMessageTheme = base.systemMessageTheme,
        typingIndicatorTheme = base.typingIndicatorTheme,
        unreadHeaderTheme = base.unreadHeaderTheme,
        userAvatarImageBackgroundColor = base.userAvatarImageBackgroundColor,
        userAvatarNameColors = base.userAvatarNameColors,
        userAvatarTextStyle = base.userAvatarTextStyle,
        userNameTextStyle = base.userNameTextStyle,
        highlightMessageColor = base.highlightMessageColor;

  EditedChatTheme commit() => EditedChatTheme(
        attachmentButtonIcon: attachmentButtonIcon,
        attachmentButtonMargin: attachmentButtonMargin,
        backgroundColor: backgroundColor,
        bubbleMargin: bubbleMargin,
        dateDividerMargin: dateDividerMargin,
        dateDividerTextStyle: dateDividerTextStyle,
        deliveredIcon: deliveredIcon,
        documentIcon: documentIcon,
        emptyChatPlaceholderTextStyle: emptyChatPlaceholderTextStyle,
        errorColor: errorColor,
        errorIcon: errorIcon,
        inputBackgroundColor: inputBackgroundColor,
        inputSurfaceTintColor: inputSurfaceTintColor,
        inputElevation: inputElevation,
        inputBorderRadius: inputBorderRadius,
        inputContainerDecoration: inputContainerDecoration,
        inputMargin: inputMargin,
        inputPadding: inputPadding,
        inputTextColor: inputTextColor,
        inputTextCursorColor: inputTextCursorColor,
        inputTextDecoration: inputTextDecoration,
        inputTextStyle: inputTextStyle,
        messageBorderRadius: messageBorderRadius,
        messageInsetsHorizontal: messageInsetsHorizontal,
        messageInsetsVertical: messageInsetsVertical,
        messageMaxWidth: messageMaxWidth,
        primaryColor: primaryColor,
        receivedEmojiMessageTextStyle: receivedEmojiMessageTextStyle,
        receivedMessageBodyBoldTextStyle: receivedMessageBodyBoldTextStyle,
        receivedMessageBodyCodeTextStyle: receivedMessageBodyCodeTextStyle,
        receivedMessageBodyLinkTextStyle: receivedMessageBodyLinkTextStyle,
        receivedMessageBodyTextStyle: receivedMessageBodyTextStyle,
        receivedMessageCaptionTextStyle: receivedMessageCaptionTextStyle,
        receivedMessageDocumentIconColor: receivedMessageDocumentIconColor,
        receivedMessageLinkDescriptionTextStyle:
            receivedMessageLinkDescriptionTextStyle,
        receivedMessageLinkTitleTextStyle: receivedMessageLinkTitleTextStyle,
        secondaryColor: secondaryColor,
        seenIcon: seenIcon,
        sendButtonIcon: sendButtonIcon,
        sendButtonMargin: sendButtonMargin,
        sendingIcon: sendingIcon,
        sentEmojiMessageTextStyle: sentEmojiMessageTextStyle,
        sentMessageBodyBoldTextStyle: sentMessageBodyBoldTextStyle,
        sentMessageBodyCodeTextStyle: sentMessageBodyCodeTextStyle,
        sentMessageBodyLinkTextStyle: sentMessageBodyLinkTextStyle,
        sentMessageBodyTextStyle: sentMessageBodyTextStyle,
        sentMessageCaptionTextStyle: sentMessageCaptionTextStyle,
        sentMessageDocumentIconColor: sentMessageDocumentIconColor,
        sentMessageLinkDescriptionTextStyle:
            sentMessageLinkDescriptionTextStyle,
        sentMessageLinkTitleTextStyle: sentMessageLinkTitleTextStyle,
        statusIconPadding: statusIconPadding,
        systemMessageTheme: systemMessageTheme,
        typingIndicatorTheme: typingIndicatorTheme,
        unreadHeaderTheme: unreadHeaderTheme,
        userAvatarImageBackgroundColor: userAvatarImageBackgroundColor,
        userAvatarNameColors: userAvatarNameColors,
        userAvatarTextStyle: userAvatarTextStyle,
        userNameTextStyle: userNameTextStyle,
        highlightMessageColor: highlightMessageColor,
      );

  /////////////////////////////////////////////////////////////////////////////

  /// Icon for select attachment button.
  Widget? attachmentButtonIcon;

  /// Margin of attachment button.
  EdgeInsets? attachmentButtonMargin;

  /// Used as a background color of a chat widget.
  Color backgroundColor;

  // Margin around the message bubble.
  EdgeInsetsGeometry? bubbleMargin;

  /// Margin around date dividers.
  EdgeInsets dateDividerMargin;

  /// Text style of the date dividers.
  TextStyle dateDividerTextStyle;

  /// Icon for message's `delivered` status. For the best look use size of 16.
  Widget? deliveredIcon;

  /// Icon inside file message.
  Widget? documentIcon;

  /// Text style of the empty chat placeholder.
  TextStyle emptyChatPlaceholderTextStyle;

  /// Color to indicate something bad happened (usually - shades of red).
  Color errorColor;

  /// Icon for message's `error` status. For the best look use size of 16.
  Widget? errorIcon;

  /// Color of the bottom bar where text field is.
  Color inputBackgroundColor;

  /// Surface Tint Color of the bottom bar where text field is.
  Color inputSurfaceTintColor;

  double inputElevation;

  /// Top border radius of the bottom bar where text field is.
  BorderRadius inputBorderRadius;

  /// Decoration of the container wrapping the text field.
  Decoration? inputContainerDecoration;

  /// Outer insets of the bottom bar where text field is.
  EdgeInsets inputMargin;

  /// Inner insets of the bottom bar where text field is.
  EdgeInsets inputPadding;

  /// Color of the text field's text and attachment/send buttons.
  Color inputTextColor;

  /// Color of the text field's cursor.
  Color? inputTextCursorColor;

  /// Decoration of the input text field.
  InputDecoration inputTextDecoration;

  /// Text style of the message input. To change the color use [inputTextColor].
  TextStyle inputTextStyle;

  /// Border radius of message container.
  double messageBorderRadius;

  /// Horizontal message bubble insets.
  double messageInsetsHorizontal;

  /// Vertical message bubble insets.
  double messageInsetsVertical;

  /// Message bubble max width. set to [double.infinity] adaptive screen.
  double messageMaxWidth;

  /// Primary color of the chat used as a background of sent messages
  /// and statuses.
  Color primaryColor;

  /// Text style used for displaying emojis on text messages.
  TextStyle receivedEmojiMessageTextStyle;

  /// Body text style used for displaying bold text on received text messages.
  /// Default to a bold version of [receivedMessageBodyTextStyle].
  TextStyle? receivedMessageBodyBoldTextStyle;

  /// Body text style used for displaying code text on received text messages.
  /// Defaults to a mono version of [receivedMessageBodyTextStyle].
  TextStyle? receivedMessageBodyCodeTextStyle;

  /// Text style used for displaying link text on received text messages.
  /// Defaults to [receivedMessageBodyTextStyle].
  TextStyle? receivedMessageBodyLinkTextStyle;

  /// Body text style used for displaying text on different types
  /// of received messages.
  TextStyle receivedMessageBodyTextStyle;

  /// Caption text style used for displaying secondary info (e.g. file size) on
  /// different types of received messages.
  TextStyle receivedMessageCaptionTextStyle;

  /// Color of the document icon on received messages. Has no effect when
  /// [documentIcon] is used.
  Color receivedMessageDocumentIconColor;

  /// Text style used for displaying link description on received messages.
  TextStyle receivedMessageLinkDescriptionTextStyle;

  /// Text style used for displaying link title on received messages.
  TextStyle receivedMessageLinkTitleTextStyle;

  /// Secondary color, used as a background of received messages.
  Color secondaryColor;

  /// Icon for message's `seen` status. For the best look use size of 16.
  Widget? seenIcon;

  /// Icon for send button.
  Widget? sendButtonIcon;

  /// Margin of send button.
  EdgeInsets? sendButtonMargin;

  /// Icon for message's `sending` status. For the best look use size of 10.
  Widget? sendingIcon;

  /// Text style used for displaying emojis on text messages.
  TextStyle sentEmojiMessageTextStyle;

  /// Body text style used for displaying bold text on sent text messages.
  /// Defaults to a bold version of [sentMessageBodyTextStyle].
  TextStyle? sentMessageBodyBoldTextStyle;

  /// Body text style used for displaying code text on sent text messages.
  /// Defaults to a mono version of [sentMessageBodyTextStyle].
  TextStyle? sentMessageBodyCodeTextStyle;

  /// Text style used for displaying link text on sent text messages.
  /// Defaults to [sentMessageBodyTextStyle].
  TextStyle? sentMessageBodyLinkTextStyle;

  /// Body text style used for displaying text on different types
  /// of sent messages.
  TextStyle sentMessageBodyTextStyle;

  /// Caption text style used for displaying secondary info (e.g. file size) on
  /// different types of sent messages.
  TextStyle sentMessageCaptionTextStyle;

  /// Color of the document icon on sent messages. Has no effect when
  /// [documentIcon] is used.
  Color sentMessageDocumentIconColor;

  /// Text style used for displaying link description on sent messages.
  TextStyle sentMessageLinkDescriptionTextStyle;

  /// Text style used for displaying link title on sent messages.
  TextStyle sentMessageLinkTitleTextStyle;

  /// Padding around status icons.
  EdgeInsets statusIconPadding;

  /// Theme for the system message. Will not have an effect if a custom builder
  /// is provided.
  SystemMessageTheme systemMessageTheme;

  /// Theme for typing indicator. See [TypingIndicator].
  TypingIndicatorTheme typingIndicatorTheme;

  /// Theme for the unread header.
  UnreadHeaderTheme unreadHeaderTheme;

  /// Color used as a background for user avatar if an image is provided.
  /// Visible if the image has some transparent parts.
  Color userAvatarImageBackgroundColor;

  /// Colors used as backgrounds for user avatars with no image and so,
  /// corresponding user names.
  /// Calculated based on a user ID, so unique across the whole app.
  List<Color> userAvatarNameColors;

  /// Text style used for displaying initials on user avatar if no
  /// image is provided.
  TextStyle userAvatarTextStyle;

  /// User names text style. Color will be overwritten
  /// with [userAvatarNameColors].
  TextStyle userNameTextStyle;

  /// Color used as background of message row on highligth.
  Color? highlightMessageColor;
}
