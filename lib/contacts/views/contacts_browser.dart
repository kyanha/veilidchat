import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:searchable_listview/searchable_listview.dart';
import 'package:star_menu/star_menu.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../chat_list/chat_list.dart';
import '../../contact_invitation/contact_invitation.dart';
import '../../proto/proto.dart' as proto;
import '../../theme/theme.dart';
import '../cubits/cubits.dart';
import 'contact_item_widget.dart';
import 'empty_contact_list_widget.dart';

enum ContactsBrowserElementKind {
  invitation,
  contact,
}

class ContactsBrowserElement {
  ContactsBrowserElement.invitation(proto.ContactInvitationRecord i)
      : kind = ContactsBrowserElementKind.invitation,
        contact = null,
        invitation = i;
  ContactsBrowserElement.contact(proto.Contact c)
      : kind = ContactsBrowserElementKind.contact,
        invitation = null,
        contact = c;

  final ContactsBrowserElementKind kind;
  final proto.ContactInvitationRecord? invitation;
  final proto.Contact? contact;
}

class ContactsBrowser extends StatefulWidget {
  const ContactsBrowser(
      {required this.onContactSelected,
      required this.onChatStarted,
      this.selectedContactRecordKey,
      super.key});
  @override
  State<ContactsBrowser> createState() => _ContactsBrowserState();

  final Future<void> Function(proto.Contact? contact) onContactSelected;
  final Future<void> Function(proto.Contact contact) onChatStarted;
  final TypedKey? selectedContactRecordKey;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<TypedKey?>(
          'selectedContactRecordKey', selectedContactRecordKey))
      ..add(
          ObjectFlagProperty<Future<void> Function(proto.Contact? contact)>.has(
              'onContactSelected', onContactSelected))
      ..add(
          ObjectFlagProperty<Future<void> Function(proto.Contact contact)>.has(
              'onChatStarted', onChatStarted));
  }
}

class _ContactsBrowserState extends State<ContactsBrowser>
    with SingleTickerProviderStateMixin {
  Widget buildInvitationBar(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final scale = theme.extension<ScaleScheme>()!;
    final scaleConfig = theme.extension<ScaleConfig>()!;

    final menuIconColor = scaleConfig.preferBorders
        ? scale.primaryScale.hoverBorder
        : scale.primaryScale.borderText;
    final menuBackgroundColor = scaleConfig.preferBorders
        ? scale.primaryScale.elementBackground
        : scale.primaryScale.border;
    // final menuHoverColor = scaleConfig.preferBorders
    //     ? scale.primaryScale.hoverElementBackground
    //     : scale.primaryScale.hoverBorder;

    final menuBorderColor = scale.primaryScale.hoverBorder;

    final menuParams = StarMenuParameters(
        shape: MenuShape.grid,
        checkItemsScreenBoundaries: true,
        centerOffset: const Offset(0, 64),
        backgroundParams:
            BackgroundParams(backgroundColor: theme.shadowColor.withAlpha(128)),
        boundaryBackground: BoundaryBackground(
            color: menuBackgroundColor,
            decoration: ShapeDecoration(
                color: menuBackgroundColor,
                shape: RoundedRectangleBorder(
                    side: scaleConfig.useVisualIndicators
                        ? BorderSide(
                            width: 2, color: menuBorderColor, strokeAlign: 0)
                        : BorderSide.none,
                    borderRadius: BorderRadius.circular(
                        8 * scaleConfig.borderRadiusScale)))));

    final receiveInviteMenuItems = [
      Column(mainAxisSize: MainAxisSize.min, children: [
        IconButton(
          onPressed: () async {
            _receiveInviteMenuController.closeMenu!();
            await ScanInvitationDialog.show(context);
          },
          iconSize: 32,
          icon: Icon(
            Icons.qr_code_scanner,
            size: 32,
            color: menuIconColor,
          ),
        ),
        Text(translate('add_contact_sheet.scan_invite'),
            maxLines: 2,
            textAlign: TextAlign.center,
            style: textTheme.labelSmall!.copyWith(color: menuIconColor))
      ]).paddingAll(4),
      Column(mainAxisSize: MainAxisSize.min, children: [
        IconButton(
          onPressed: () async {
            _receiveInviteMenuController.closeMenu!();
            await PasteInvitationDialog.show(context);
          },
          iconSize: 32,
          icon: Icon(
            Icons.paste,
            size: 32,
            color: menuIconColor,
          ),
        ),
        Text(translate('add_contact_sheet.paste_invite'),
            maxLines: 2,
            textAlign: TextAlign.center,
            style: textTheme.labelSmall!.copyWith(color: menuIconColor))
      ]).paddingAll(4)
    ];

    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      Column(mainAxisSize: MainAxisSize.min, children: [
        IconButton(
          onPressed: () async {
            await CreateInvitationDialog.show(context);
          },
          iconSize: 32,
          icon: const Icon(Icons.contact_page),
          color: scale.primaryScale.hoverBorder,
        ),
        Text(translate('add_contact_sheet.create_invite'),
            maxLines: 2,
            textAlign: TextAlign.center,
            style: textTheme.labelSmall!
                .copyWith(color: scale.primaryScale.hoverBorder))
      ]),
      StarMenu(
        items: receiveInviteMenuItems,
        onItemTapped: (_index, controller) {
          controller.closeMenu!();
        },
        controller: _receiveInviteMenuController,
        params: menuParams,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          IconButton(
              onPressed: () {},
              iconSize: 32,
              icon: ImageIcon(
                const AssetImage('assets/images/handshake.png'),
                size: 32,
                color: scale.primaryScale.hoverBorder,
              )),
          Text(translate('add_contact_sheet.receive_invite'),
              maxLines: 2,
              textAlign: TextAlign.center,
              style: textTheme.labelSmall!
                  .copyWith(color: scale.primaryScale.hoverBorder))
        ]),
      ),
    ]).paddingAll(16);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final scale = theme.extension<ScaleScheme>()!;
    //final scaleConfig = theme.extension<ScaleConfig>()!;

    final cilState = context.watch<ContactInvitationListCubit>().state;
    final cilBusy = cilState.busy;
    final contactInvitationRecordList =
        cilState.state.asData?.value.map((x) => x.value).toIList() ??
            const IListConst([]);

    final ciState = context.watch<ContactListCubit>().state;
    final ciBusy = ciState.busy;
    final contactList =
        ciState.state.asData?.value.map((x) => x.value).toIList();

    final expansionListData =
        <ContactsBrowserElementKind, List<ContactsBrowserElement>>{};
    if (contactInvitationRecordList.isNotEmpty) {
      expansionListData[ContactsBrowserElementKind.invitation] =
          contactInvitationRecordList
              .toList()
              .map(ContactsBrowserElement.invitation)
              .toList();
    }
    if (contactList != null) {
      expansionListData[ContactsBrowserElementKind.contact] =
          contactList.toList().map(ContactsBrowserElement.contact).toList();
    }

    return Column(children: [
      buildInvitationBar(context),
      SearchableList<ContactsBrowserElement>.expansion(
        expansionListData: expansionListData,
        expansionTitleBuilder: (k) {
          final kind = k as ContactsBrowserElementKind;
          late final String title;
          switch (kind) {
            case ContactsBrowserElementKind.contact:
              title = translate('contacts_dialog.contacts');
            case ContactsBrowserElementKind.invitation:
              title = translate('contacts_dialog.invitations');
          }

          return Center(
            child: Text(title, style: textTheme.titleSmall),
          );
        },
        expansionInitiallyExpanded: (k) => true,
        expansionListBuilder: (_index, element) {
          switch (element.kind) {
            case ContactsBrowserElementKind.contact:
              final contact = element.contact!;
              return ContactItemWidget(
                      contact: contact,
                      selected: widget.selectedContactRecordKey ==
                          contact.localConversationRecordKey.toVeilid(),
                      disabled: ciBusy,
                      onTap: _onTapContact,
                      onDoubleTap: _onStartChat,
                      onDelete: _onDeleteContact)
                  .paddingLTRB(0, 4, 0, 0);
            case ContactsBrowserElementKind.invitation:
              final invitation = element.invitation!;
              return ContactInvitationItemWidget(
                      contactInvitationRecord: invitation, disabled: cilBusy)
                  .paddingLTRB(0, 4, 0, 0);
          }
        },
        filterExpansionData: (value) {
          final lowerValue = value.toLowerCase();
          final filteredMap = {
            for (final entry in expansionListData.entries)
              entry.key: (expansionListData[entry.key] ?? []).where((element) {
                switch (element.kind) {
                  case ContactsBrowserElementKind.contact:
                    final contact = element.contact!;
                    return contact.nickname
                            .toLowerCase()
                            .contains(lowerValue) ||
                        contact.profile.name
                            .toLowerCase()
                            .contains(lowerValue) ||
                        contact.profile.pronouns
                            .toLowerCase()
                            .contains(lowerValue);
                  case ContactsBrowserElementKind.invitation:
                    final invitation = element.invitation!;
                    return invitation.message
                        .toLowerCase()
                        .contains(lowerValue);
                }
              }).toList()
          };
          return filteredMap;
        },
        hideEmptyExpansionItems: true,
        searchFieldHeight: 40,
        listViewPadding: const EdgeInsets.all(4),
        spaceBetweenSearchAndList: 4,
        emptyWidget: contactList == null
            ? waitingPage(text: translate('contact_list.loading_contacts'))
            : const EmptyContactListWidget(),
        defaultSuffixIconColor: scale.primaryScale.border,
        closeKeyboardWhenScrolling: true,
        searchFieldEnabled: contactList != null,
        inputDecoration:
            InputDecoration(labelText: translate('contact_list.search')),
      ).expanded()
    ]);
  }

  Future<void> _onTapContact(proto.Contact contact) async {
    await widget.onContactSelected(contact);
  }

  Future<void> _onStartChat(proto.Contact contact) async {
    await widget.onChatStarted(contact);
  }

  Future<void> _onDeleteContact(proto.Contact contact) async {
    final localConversationRecordKey =
        contact.localConversationRecordKey.toVeilid();

    final contactListCubit = context.read<ContactListCubit>();
    final chatListCubit = context.read<ChatListCubit>();

    // Delete the contact itself
    await contactListCubit.deleteContact(
        localConversationRecordKey: localConversationRecordKey);

    // Remove any chats for this contact
    await chatListCubit.deleteChat(
        localConversationRecordKey: localConversationRecordKey);
  }

  ////////////////////////////////////////////////////////////////////////////
  final _receiveInviteMenuController = StarMenuController();
}
