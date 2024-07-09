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
  final IList<proto.Contact> contactList;
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

class _ContactListWidgetState extends State<ContactListWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scale = theme.extension<ScaleScheme>()!;

    return styledTitleContainer(
      context: context,
      title: translate('contact_list.title'),
      child: SearchableList<proto.Contact>(
        shrinkWrap: true,
        initialList: widget.contactList.toList(),
        itemBuilder: (c) =>
            ContactItemWidget(contact: c, disabled: widget.disabled)
                .paddingLTRB(0, 4, 0, 0),
        filter: (value) {
          final lowerValue = value.toLowerCase();
          return widget.contactList
              .where((element) =>
                  element.nickname.toLowerCase().contains(lowerValue) ||
                  element.profile.name.toLowerCase().contains(lowerValue) ||
                  element.profile.pronouns.toLowerCase().contains(lowerValue))
              .toList();
        },
        searchFieldHeight: 40,
        spaceBetweenSearchAndList: 4,
        emptyWidget: const EmptyContactListWidget(),
        defaultSuffixIconColor: scale.primaryScale.border,
        closeKeyboardWhenScrolling: true,
        inputDecoration: InputDecoration(
          labelText: translate('contact_list.search'),
        ),
      ).paddingAll(8),
    ).paddingLTRB(8, 0, 8, 8);
  }
}
