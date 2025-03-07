import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../theme.dart';

class SliderTileAction {
  const SliderTileAction({
    required this.actionScale,
    required this.onPressed,
    this.key,
    this.icon,
    this.label,
  });

  final Key? key;
  final ScaleKind actionScale;
  final String? label;
  final IconData? icon;
  final SlidableActionCallback? onPressed;
}

class SliderTile extends StatelessWidget {
  const SliderTile(
      {required this.disabled,
      required this.selected,
      required this.tileScale,
      required this.title,
      this.subtitle = '',
      this.endActions = const [],
      this.startActions = const [],
      this.onTap,
      this.onDoubleTap,
      this.leading,
      this.trailing,
      super.key});

  final bool disabled;
  final bool selected;
  final ScaleKind tileScale;
  final List<SliderTileAction> endActions;
  final List<SliderTileAction> startActions;
  final GestureTapCallback? onTap;
  final GestureTapCallback? onDoubleTap;
  final Widget? leading;
  final Widget? trailing;
  final String title;
  final String subtitle;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<bool>('disabled', disabled))
      ..add(DiagnosticsProperty<bool>('selected', selected))
      ..add(DiagnosticsProperty<ScaleKind>('tileScale', tileScale))
      ..add(IterableProperty<SliderTileAction>('endActions', endActions))
      ..add(IterableProperty<SliderTileAction>('startActions', startActions))
      ..add(ObjectFlagProperty<GestureTapCallback?>.has('onTap', onTap))
      ..add(DiagnosticsProperty<Widget?>('leading', leading))
      ..add(StringProperty('title', title))
      ..add(StringProperty('subtitle', subtitle))
      ..add(ObjectFlagProperty<GestureTapCallback?>.has(
          'onDoubleTap', onDoubleTap))
      ..add(DiagnosticsProperty<Widget?>('trailing', trailing));
  }

  @override
  // ignore: prefer_expression_function_bodies
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scale = theme.extension<ScaleScheme>()!;
    final tileColor = scale.scale(!disabled ? tileScale : ScaleKind.gray);
    final scaleConfig = theme.extension<ScaleConfig>()!;

    final borderColor = selected ? tileColor.hoverBorder : tileColor.border;
    final backgroundColor = scaleConfig.useVisualIndicators && !selected
        ? tileColor.borderText
        : borderColor;
    final textColor = scaleConfig.useVisualIndicators && !selected
        ? borderColor
        : tileColor.borderText;

    return Container(
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
            color: backgroundColor,
            shape: RoundedRectangleBorder(
              side: scaleConfig.useVisualIndicators
                  ? BorderSide(width: 2, color: borderColor, strokeAlign: 0)
                  : BorderSide.none,
              borderRadius:
                  BorderRadius.circular(8 * scaleConfig.borderRadiusScale),
            )),
        child: Slidable(
            // Specify a key if the Slidable is dismissible.
            key: key,
            endActionPane: endActions.isEmpty
                ? null
                : ActionPane(
                    motion: const DrawerMotion(),
                    children: endActions
                        .map(
                          (a) => SlidableAction(
                              onPressed: disabled ? null : a.onPressed,
                              backgroundColor: scaleConfig.useVisualIndicators
                                  ? (selected
                                      ? tileColor.borderText
                                      : tileColor.border)
                                  : scale.scale(a.actionScale).primary,
                              foregroundColor: scaleConfig.useVisualIndicators
                                  ? (selected
                                      ? tileColor.border
                                      : tileColor.borderText)
                                  : scale.scale(a.actionScale).primaryText,
                              icon: subtitle.isEmpty ? a.icon : null,
                              label: a.label,
                              padding: const EdgeInsets.all(2)),
                        )
                        .toList()),
            startActionPane: startActions.isEmpty
                ? null
                : ActionPane(
                    motion: const DrawerMotion(),
                    children: startActions
                        .map(
                          (a) => SlidableAction(
                              onPressed: disabled ? null : a.onPressed,
                              backgroundColor: scaleConfig.useVisualIndicators
                                  ? (selected
                                      ? tileColor.borderText
                                      : tileColor.border)
                                  : scale.scale(a.actionScale).primary,
                              foregroundColor: scaleConfig.useVisualIndicators
                                  ? (selected
                                      ? tileColor.border
                                      : tileColor.borderText)
                                  : scale.scale(a.actionScale).primaryText,
                              icon: subtitle.isEmpty ? a.icon : null,
                              label: a.label,
                              padding: const EdgeInsets.all(2)),
                        )
                        .toList()),
            child: Padding(
                padding: scaleConfig.useVisualIndicators
                    ? EdgeInsets.zero
                    : const EdgeInsets.fromLTRB(0, 2, 0, 2),
                child: GestureDetector(
                    onDoubleTap: onDoubleTap,
                    child: ListTile(
                        onTap: onTap,
                        dense: true,
                        visualDensity: const VisualDensity(vertical: -4),
                        title: Text(
                          title,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                        ),
                        subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
                        iconColor: textColor,
                        textColor: textColor,
                        leading: FittedBox(child: leading),
                        trailing: FittedBox(child: trailing))))));
  }
}
