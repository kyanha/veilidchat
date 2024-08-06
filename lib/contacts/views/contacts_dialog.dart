import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:provider/provider.dart';

import '../../chat/chat.dart';
import '../../chat_list/chat_list.dart';
import '../../layout/layout.dart';
import '../../proto/proto.dart' as proto;
import '../../theme/theme.dart';
import '../contacts.dart';

class ContactsDialog extends StatefulWidget {
  const ContactsDialog._({required this.modalContext});

  @override
  State<ContactsDialog> createState() => _ContactsDialogState();

  static Future<void> show(BuildContext modalContext) async {
    await showDialog<void>(
        context: modalContext,
        barrierDismissible: false,
        useRootNavigator: false,
        builder: (context) => ContactsDialog._(modalContext: modalContext));
  }

  final BuildContext modalContext;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
        .add(DiagnosticsProperty<BuildContext>('modalContext', modalContext));
  }
}

class _ContactsDialogState extends State<ContactsDialog> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // final textTheme = theme.textTheme;
    final scale = theme.extension<ScaleScheme>()!;
    // final scaleConfig = theme.extension<ScaleConfig>()!;

    final enableSplit = !isMobileWidth(context);
    final enableLeft = enableSplit || _selectedContact == null;
    final enableRight = enableSplit || _selectedContact != null;

    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: StyledScaffold(
            appBar: DefaultAppBar(
                title: Text(!enableSplit && enableRight
                    ? translate('contacts_dialog.edit_contact')
                    : translate('contacts_dialog.contacts')),
                leading: Navigator.canPop(context)
                    ? IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          if (!enableSplit && enableRight) {
                            setState(() {
                              _selectedContact = null;
                            });
                          } else {
                            Navigator.pop(context);
                          }
                        },
                      )
                    : null,
                actions: [
                  if (_selectedContact != null)
                    FittedBox(
                        fit: BoxFit.scaleDown,
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                          IconButton(
                              icon: const Icon(Icons.chat_bubble),
                              tooltip: translate('contacts_dialog.new_chat'),
                              onPressed: () async {
                                await onChatStarted(_selectedContact!);
                              }),
                          Text(translate('contacts_dialog.new_chat'),
                              style: theme.textTheme.labelSmall!.copyWith(
                                  color: scale.primaryScale.borderText)),
                        ])).paddingLTRB(8, 0, 8, 0),
                  if (enableSplit && _selectedContact != null)
                    FittedBox(
                        fit: BoxFit.scaleDown,
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                          IconButton(
                              icon: const Icon(Icons.close),
                              tooltip:
                                  translate('contacts_dialog.close_contact'),
                              onPressed: () async {
                                await onContactSelected(null);
                              }),
                          Text(translate('contacts_dialog.close_contact'),
                              style: theme.textTheme.labelSmall!.copyWith(
                                  color: scale.primaryScale.borderText)),
                        ])).paddingLTRB(8, 0, 8, 0),
                ]),
            body: LayoutBuilder(builder: (context, constraint) {
              final maxWidth = constraint.maxWidth;

              return Row(children: [
                Offstage(
                    offstage: !enableLeft,
                    child: SizedBox(
                        width: enableLeft && !enableRight
                            ? maxWidth
                            : (maxWidth / 3).clamp(200, 500),
                        child: DecoratedBox(
                            decoration: BoxDecoration(
                                color: scale.primaryScale.subtleBackground),
                            child: ContactsBrowser(
                              selectedContactRecordKey: _selectedContact
                                  ?.localConversationRecordKey
                                  .toVeilid(),
                              onContactSelected: onContactSelected,
                              onChatStarted: onChatStarted,
                            ).paddingLTRB(8, 0, 8, 8)))),
                if (enableRight)
                  if (_selectedContact == null)
                    const NoContactWidget().expanded()
                  else
                    ContactDetailsWidget(contact: _selectedContact!)
                        .paddingAll(8)
                        .expanded(),
              ]);
            })));
  }

  Future<void> onContactSelected(proto.Contact? contact) async {
    setState(() {
      _selectedContact = contact;
    });
  }

  Future<void> onChatStarted(proto.Contact contact) async {
    final chatListCubit = context.read<ChatListCubit>();
    await chatListCubit.getOrCreateChatSingleContact(contact: contact);

    if (mounted) {
      context
          .read<ActiveChatCubit>()
          .setActiveChat(contact.localConversationRecordKey.toVeilid());

      Navigator.pop(context);
    }
  }

  proto.Contact? _selectedContact;
}
