import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';

import '../../account_manager/account_manager.dart';
import '../../chat/chat.dart';
import '../../proto/proto.dart' as proto;
import '../../theme/theme.dart';
import 'main_pager/main_pager.dart';

class HomeAccountReady extends StatefulWidget {
  const HomeAccountReady({super.key});

  @override
  State<HomeAccountReady> createState() => _HomeAccountReadyState();
}

class _HomeAccountReadyState extends State<HomeAccountReady> {
  @override
  void initState() {
    super.initState();
  }

  Widget buildUserPanel() => Builder(builder: (context) {
        final profile = context.select<AccountRecordCubit, proto.Profile>(
            (c) => c.state.asData!.value.profile);
        final theme = Theme.of(context);
        final scale = theme.extension<ScaleScheme>()!;
        final scaleConfig = theme.extension<ScaleConfig>()!;

        return ColoredBox(
            color: scaleConfig.preferBorders
                ? scale.primaryScale.subtleBackground
                : scale.primaryScale.subtleBorder,
            child: Column(children: <Widget>[
              Row(children: [
                IconButton(
                    icon: const Icon(Icons.menu),
                    color: scaleConfig.preferBorders
                        ? scale.primaryScale.border
                        : scale.primaryScale.borderText,
                    constraints:
                        const BoxConstraints.expand(height: 48, width: 48),
                    style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                            scaleConfig.preferBorders
                                ? scale.primaryScale.hoverElementBackground
                                : scale.primaryScale.hoverBorder),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                              side: !scaleConfig.useVisualIndicators
                                  ? BorderSide.none
                                  : BorderSide(
                                      strokeAlign: BorderSide.strokeAlignCenter,
                                      color: scaleConfig.preferBorders
                                          ? scale.primaryScale.border
                                          : scale.primaryScale.borderText,
                                      width: 2),
                              borderRadius: BorderRadius.all(Radius.circular(
                                  12 * scaleConfig.borderRadiusScale))),
                        )),
                    tooltip: translate('menu.settings_tooltip'),
                    onPressed: () async {
                      final ctrl = context.read<ZoomDrawerController>();
                      await ctrl.toggle?.call();
                      //await GoRouterHelper(context).push('/settings');
                    }).paddingLTRB(0, 0, 8, 0),
                ProfileWidget(
                  profile: profile,
                  showPronouns: false,
                ).expanded(),
              ]).paddingAll(8),
              MainPager(key: _mainPagerKey).expanded()
            ]));
      });

  Widget buildLeftPane(BuildContext context) => Builder(
      builder: (context) =>
          Material(color: Colors.transparent, child: buildUserPanel()));

  Widget buildRightPane(BuildContext context) {
    final activeChatLocalConversationKey =
        context.watch<ActiveChatCubit>().state;
    if (activeChatLocalConversationKey == null) {
      return const NoConversationWidget();
    }
    return ChatComponentWidget(
        localConversationRecordKey: activeChatLocalConversationKey,
        key: ValueKey(activeChatLocalConversationKey));
  }

  @override
  Widget build(BuildContext context) {
    final isLarge = responsiveVisibility(
      context: context,
      phone: false,
    );

    final theme = Theme.of(context);
    final scale = theme.extension<ScaleScheme>()!;
    final scaleConfig = theme.extension<ScaleConfig>()!;

    final activeChat = context.watch<ActiveChatCubit>().state;
    final hasActiveChat = activeChat != null;

    return LayoutBuilder(builder: (context, constraints) {
      const leftColumnSize = 300.0;

      late final bool visibleLeft;
      late final bool visibleRight;
      late final double leftWidth;
      late final double rightWidth;
      if (isLarge) {
        visibleLeft = true;
        visibleRight = true;
        leftWidth = leftColumnSize;
        rightWidth = constraints.maxWidth - leftColumnSize - 2;
      } else {
        if (hasActiveChat) {
          visibleLeft = false;
          visibleRight = true;
          leftWidth = leftColumnSize;
          rightWidth = constraints.maxWidth;
        } else {
          visibleLeft = true;
          visibleRight = false;
          leftWidth = constraints.maxWidth;
          rightWidth = 400; // whatever
        }
      }

      return Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Offstage(
            offstage: !visibleLeft,
            child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: leftWidth),
                child: buildLeftPane(context))),
        Offstage(
            offstage: !(visibleLeft && visibleRight),
            child: SizedBox(
                width: 2,
                height: double.infinity,
                child: ColoredBox(
                    color: scaleConfig.preferBorders
                        ? scale.primaryScale.subtleBorder
                        : scale.primaryScale.subtleBackground))),
        Offstage(
            offstage: !visibleRight,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  maxHeight: constraints.maxHeight, maxWidth: rightWidth),
              child: buildRightPane(context),
            )),
      ]);
    });
  }

  ////////////////////////////////////////////////////////////////////////////
  final _mainPagerKey = GlobalKey(debugLabel: '_mainPagerKey');
}
