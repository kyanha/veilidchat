import 'package:async_tools/async_tools.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '../../proto/proto.dart' as proto;
import '../../theme/theme.dart';

const _kOnTap = 'onTap';
const _kOnDelete = 'onDelete';

class ContactItemWidget extends StatelessWidget {
  const ContactItemWidget(
      {required proto.Contact contact,
      required bool disabled,
      required bool selected,
      Future<void> Function(proto.Contact)? onTap,
      Future<void> Function(proto.Contact)? onDoubleTap,
      Future<void> Function(proto.Contact)? onDelete,
      super.key})
      : _disabled = disabled,
        _selected = selected,
        _contact = contact,
        _onTap = onTap,
        _onDoubleTap = onDoubleTap,
        _onDelete = onDelete;

  @override
  // ignore: prefer_expression_function_bodies
  Widget build(
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    final scale = theme.extension<ScaleScheme>()!;
    final scaleConfig = theme.extension<ScaleConfig>()!;

    final name = _contact.nameOrNickname;
    final title = _contact.displayName;
    final subtitle = _contact.profile.status;

    final avatar = AvatarWidget(
      name: name,
      size: 34,
      borderColor: _disabled
          ? scale.grayScale.primaryText
          : scale.primaryScale.primaryText,
      foregroundColor: _disabled
          ? scale.grayScale.primaryText
          : scale.primaryScale.primaryText,
      backgroundColor:
          _disabled ? scale.grayScale.primary : scale.primaryScale.primary,
      scaleConfig: scaleConfig,
      textStyle: theme.textTheme.titleLarge!,
    );

    return SliderTile(
      key: ObjectKey(_contact),
      disabled: _disabled,
      selected: _selected,
      tileScale: ScaleKind.primary,
      title: title,
      subtitle: subtitle,
      leading: avatar,
      onDoubleTap: _onDoubleTap == null
          ? null
          : () => singleFuture<void>((this, _kOnTap), () async {
                await _onDoubleTap(_contact);
              }),
      onTap: _onTap == null
          ? null
          : () => singleFuture<void>((this, _kOnTap), () async {
                await _onTap(_contact);
              }),
      endActions: [
        if (_onDelete != null)
          SliderTileAction(
            icon: Icons.delete,
            label: translate('button.delete'),
            actionScale: ScaleKind.tertiary,
            onPressed: (_context) =>
                singleFuture<void>((this, _kOnDelete), () async {
              await _onDelete(_contact);
            }),
          ),
      ],
    );
  }

  ////////////////////////////////////////////////////////////////////////////

  final proto.Contact _contact;
  final bool _disabled;
  final bool _selected;
  final Future<void> Function(proto.Contact contact)? _onTap;
  final Future<void> Function(proto.Contact contact)? _onDoubleTap;
  final Future<void> Function(proto.Contact contact)? _onDelete;
}
