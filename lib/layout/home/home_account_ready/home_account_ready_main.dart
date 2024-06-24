import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';

import '../../../account_manager/account_manager.dart';
import '../../../chat/chat.dart';
import '../../../proto/proto.dart' as proto;
import '../../../theme/theme.dart';
import '../../../tools/tools.dart';
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

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await changeWindowSetup(
          TitleBarStyle.normal, OrientationCapability.normal);
    });
  }

  Widget buildUserPanel() => Builder(builder: (context) {
        final profile = context.select<AccountRecordCubit, proto.Profile>(
            (c) => c.state.asData!.value.profile);
        final theme = Theme.of(context);
        final scale = theme.extension<ScaleScheme>()!;

        return ColoredBox(
            color: scale.primaryScale.subtleBorder,
            child: Column(children: <Widget>[
              Row(children: [
                IconButton(
                    icon: const Icon(Icons.menu),
                    color: scale.secondaryScale.borderText,
                    constraints:
                        const BoxConstraints.expand(height: 64, width: 64),
                    style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                            scale.primaryScale.hoverBorder),
                        shape: WidgetStateProperty.all(
                            const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(16))))),
                    tooltip: translate('menu.settings_tooltip'),
                    onPressed: () async {
                      final ctrl = context.read<ZoomDrawerController>();
                      await ctrl.toggle?.call();
                      //await GoRouterHelper(context).push('/settings');
                    }).paddingLTRB(0, 0, 8, 0),
                ProfileWidget(profile: profile).expanded(),
              ]).paddingAll(8),
              MainPager(key: _mainPagerKey).expanded()
            ]));
      });

  Widget buildPhone(BuildContext context) =>
      Material(color: Colors.transparent, child: buildUserPanel());

  Widget buildTabletLeftPane(BuildContext context) => Builder(
      builder: (context) =>
          Material(color: Colors.transparent, child: buildUserPanel()));

  Widget buildTabletRightPane(BuildContext context) {
    final activeChatLocalConversationKey =
        context.watch<ActiveChatCubit>().state;
    if (activeChatLocalConversationKey == null) {
      return const NoConversationWidget();
    }
    return ChatComponentWidget.builder(
        localConversationRecordKey: activeChatLocalConversationKey,
        key: ValueKey(activeChatLocalConversationKey));
  }

  // ignore: prefer_expression_function_bodies
  Widget buildTablet(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);
    final scale = theme.extension<ScaleScheme>()!;

    final children = [
      ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 300, maxWidth: 300),
          child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: w / 2),
              child: buildTabletLeftPane(context))),
      SizedBox(
          width: 2,
          height: double.infinity,
          child: ColoredBox(color: scale.primaryScale.hoverBorder)),
      Expanded(child: buildTabletRightPane(context)),
    ];

    return Row(
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) => responsiveVisibility(
        context: context,
        phone: false,
      )
          ? buildTablet(context)
          : buildPhone(context);

  ////////////////////////////////////////////////////////////////////////////
  final _mainPagerKey = GlobalKey(debugLabel: '_mainPagerKey');
}
