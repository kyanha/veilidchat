import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:searchable_listview/searchable_listview.dart';

import '../../proto/proto.dart' as proto;
import '../../theme/theme.dart';
import 'contact_item_widget.dart';
import 'empty_contact_list_widget.dart';

class ContactListWidget extends StatefulWidget {
  const ContactListWidget(
      {required this.contactList, required this.disabled, super.key});
  final IList<proto.Contact>? contactList;
  final bool disabled;

  @override
  State<ContactListWidget> createState() => _ContactListWidgetState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(IterableProperty<proto.Contact>('contactList', contactList))
      ..add(DiagnosticsProperty<bool>('disabled', disabled));
  }
}

class _ContactListWidgetState extends State<ContactListWidget>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    //final textTheme = theme.textTheme;
    final scale = theme.extension<ScaleScheme>()!;
    final scaleConfig = theme.extension<ScaleConfig>()!;

    return SliverLayoutBuilder(
        builder: (context, constraints) => styledHeaderSliver(
            context: context,
            backgroundColor: scaleConfig.preferBorders
                ? scale.primaryScale.subtleBackground
                : scale.primaryScale.subtleBorder,
            title: translate('contacts_page.contacts'),
            sliver: SliverFillRemaining(
              child: SearchableList<proto.Contact>.sliver(
                initialList: widget.contactList == null
                    ? []
                    : widget.contactList!.toList(),
                itemBuilder: (c) =>
                    ContactItemWidget(contact: c, disabled: widget.disabled)
                        .paddingLTRB(0, 4, 0, 0),
                filter: (value) {
                  final lowerValue = value.toLowerCase();
                  if (widget.contactList == null) {
                    return [];
                  }
                  return widget.contactList!
                      .where((element) =>
                          element.nickname.toLowerCase().contains(lowerValue) ||
                          element.profile.name
                              .toLowerCase()
                              .contains(lowerValue) ||
                          element.profile.pronouns
                              .toLowerCase()
                              .contains(lowerValue))
                      .toList();
                },
                searchFieldHeight: 40,
                spaceBetweenSearchAndList: 4,
                emptyWidget: widget.contactList == null
                    ? waitingPage(
                        text: translate('contacts_page.loading_contacts'))
                    : const EmptyContactListWidget(),
                defaultSuffixIconColor: scale.primaryScale.border,
                closeKeyboardWhenScrolling: true,
                searchFieldEnabled: widget.contactList != null,
                inputDecoration: InputDecoration(
                  labelText: translate('contact_list.search'),
                ),
              ),
            )));
  }
}
