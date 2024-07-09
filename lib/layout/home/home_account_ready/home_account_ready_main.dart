import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';

import '../../../account_manager/account_manager.dart';
import '../../../chat/chat.dart';
import '../../../proto/proto.dart' as proto;
import '../../../theme/theme.dart';
import 'main_pager/main_pager.dart';

class HomeAccountReadyMain extends StatefulWidget {
  const HomeAccountReadyMain({super.key});

  @override
  State<HomeAccountReadyMain> createState() => _HomeAccountReadyMainState();
}

class _HomeAccountReadyMainState extends State<HomeAccountReadyMain> {
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
    return ChatComponentWidget.builder(
        localConversationRecordKey: activeChatLocalConversationKey,
        key: ValueKey(activeChatLocalConversationKey));
  }

  @override
  Widget build(BuildContext context) {
    final isLarge = responsiveVisibility(
      context: context,
      phone: false,
    );

    final w = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);
    final scale = theme.extension<ScaleScheme>()!;
    final scaleConfig = theme.extension<ScaleConfig>()!;

    final activeChat = context.watch<ActiveChatCubit>().state;
    final hasActiveChat = activeChat != null;
    // if (hasActiveChat) {
    //   _chatAnimationController.forward();
    // } else {
    //   _chatAnimationController.reset();
    // }

    late final bool offstageLeft;
    late final bool offstageRight;
    late final double leftWidth;
    late final double rightWidth;
    if (isLarge) {
      leftWidth = 300;
      rightWidth = w - 300 - 2;
      offstageLeft = false;
      offstageRight = false;
    } else {
      leftWidth = w;
      rightWidth = w;
      if (hasActiveChat) {
        offstageLeft = true;
        offstageRight = false;
      } else {
        offstageLeft = false;
        offstageRight = true;
      }
    }

    return Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Offstage(
          offstage: offstageLeft,
          child: ConstrainedBox(
              constraints:
                  BoxConstraints(minWidth: leftWidth, maxWidth: leftWidth),
              child: buildLeftPane(context))),
      Offstage(
          offstage: offstageLeft || offstageRight,
          child: SizedBox(
              width: 2,
              height: double.infinity,
              child: ColoredBox(
                  color: scaleConfig.preferBorders
                      ? scale.primaryScale.subtleBorder
                      : scale.primaryScale.subtleBackground))),
      Offstage(
          offstage: offstageRight,
          child: ConstrainedBox(
            constraints:
                BoxConstraints(minWidth: rightWidth, maxWidth: rightWidth),
            child: buildRightPane(context),
          )),
    ]);
  }

  ////////////////////////////////////////////////////////////////////////////
  final _mainPagerKey = GlobalKey(debugLabel: '_mainPagerKey');
}
