import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../proto/proto.dart' as proto;
import '../../theme/theme.dart';
import 'contact_invitation_item_widget.dart';

class ContactInvitationListWidget extends StatefulWidget {
  const ContactInvitationListWidget({
    required this.contactInvitationRecordList,
    required this.disabled,
    super.key,
  });

  final IList<proto.ContactInvitationRecord> contactInvitationRecordList;
  final bool disabled;

  @override
  ContactInvitationListWidgetState createState() =>
      ContactInvitationListWidgetState();
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(IterableProperty<proto.ContactInvitationRecord>(
          'contactInvitationRecordList', contactInvitationRecordList))
      ..add(DiagnosticsProperty<bool>('disabled', disabled));
  }
}

class ContactInvitationListWidgetState
    extends State<ContactInvitationListWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  // ignore: prefer_expression_function_bodies
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    //final textTheme = theme.textTheme;
    final scale = theme.extension<ScaleScheme>()!;
    final scaleConfig = theme.extension<ScaleConfig>()!;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(4, 0, 4, 4),
      decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16 * scaleConfig.borderRadiusScale),
      )),
      constraints: const BoxConstraints(maxHeight: 100),
      child: Container(
          width: double.infinity,
          decoration: ShapeDecoration(
              color: scale.primaryScale.subtleBackground,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(16 * scaleConfig.borderRadiusScale),
              )),
          child: ListView.builder(
            shrinkWrap: true,
            controller: _scrollController,
            itemCount: widget.contactInvitationRecordList.length,
            itemBuilder: (context, index) {
              if (index < 0 ||
                  index >= widget.contactInvitationRecordList.length) {
                return null;
              }
              return ContactInvitationItemWidget(
                      contactInvitationRecord:
                          widget.contactInvitationRecordList[index],
                      disabled: widget.disabled,
                      key: ObjectKey(widget.contactInvitationRecordList[index]))
                  .paddingLTRB(4, 2, 4, 2);
            },
            findChildIndexCallback: (key) {
              final index = widget.contactInvitationRecordList.indexOf(
                  (key as ObjectKey).value! as proto.ContactInvitationRecord);
              if (index == -1) {
                return null;
              }
              return index;
            },
          ).paddingLTRB(4, 6, 4, 6)),
    );
  }
}
