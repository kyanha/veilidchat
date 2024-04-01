import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:searchable_listview/searchable_listview.dart';

import '../../proto/proto.dart' as proto;
import '../../theme/theme.dart';
import '../../tools/tools.dart';
import 'contact_item_widget.dart';
import 'empty_contact_list_widget.dart';

class ContactListWidget extends StatelessWidget {
  const ContactListWidget(
      {required this.contactList, required this.disabled, super.key});
  final IList<proto.Contact> contactList;
  final bool disabled;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(IterableProperty<proto.Contact>('contactList', contactList))
      ..add(DiagnosticsProperty<bool>('disabled', disabled));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    //final textTheme = theme.textTheme;
    final scale = theme.extension<ScaleScheme>()!;

    return SizedBox.expand(
        child: styledTitleContainer(
            context: context,
            title: translate('contact_list.title'),
            child: SizedBox.expand(
              child: (contactList.isEmpty)
                  ? const EmptyContactListWidget()
                  : SearchableList<proto.Contact>(
                      initialList: contactList.toList(),
                      builder: (l, i, c) =>
                          ContactItemWidget(contact: c, disabled: disabled),
                      filter: (value) {
                        final lowerValue = value.toLowerCase();
                        return contactList
                            .where((element) =>
                                element.editedProfile.name
                                    .toLowerCase()
                                    .contains(lowerValue) ||
                                element.editedProfile.pronouns
                                    .toLowerCase()
                                    .contains(lowerValue))
                            .toList();
                      },
                      spaceBetweenSearchAndList: 4,
                      inputDecoration: InputDecoration(
                        labelText: translate('contact_list.search'),
                        contentPadding: const EdgeInsets.all(2),
                        fillColor: scale.primaryScale.text,
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: scale.primaryScale.hoverBorder,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ).paddingAll(8),
            ))).paddingLTRB(8, 0, 8, 8);
  }
}
