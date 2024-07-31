import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';

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
    extends State<ContactInvitationListWidget>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 250), value: 1);
  late final _animation =
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  bool _expanded = true;

  @override
  // ignore: prefer_expression_function_bodies
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // final textTheme = theme.textTheme;
    final scale = theme.extension<ScaleScheme>()!;
    final scaleConfig = theme.extension<ScaleConfig>()!;

    return styledExpandingSliver(
        context: context,
        animation: _animation,
        expanded: _expanded,
        backgroundColor: scaleConfig.preferBorders
            ? scale.primaryScale.subtleBackground
            : scale.primaryScale.subtleBorder,
        onTap: () {
          setState(() {
            _expanded = !_expanded;
          });
          _controller.animateTo(_expanded ? 1 : 0);
        },
        title: translate('contacts_dialog.invitations'),
        sliver: SliverList.builder(
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
        ));
  }
}
