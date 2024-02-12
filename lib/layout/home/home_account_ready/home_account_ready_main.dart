import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:go_router/go_router.dart';

import '../../../account_manager/account_manager.dart';
import '../../../chat/chat.dart';
import '../../../theme/theme.dart';
import '../../../tools/tools.dart';
import 'main_pager/main_pager.dart';

class HomeAccountReadyMain extends StatelessWidget {
  const HomeAccountReadyMain({super.key});

  Widget buildUserPanel() => Builder(builder: (context) {
        final account = context.watch<AccountRecordCubit>().state;
        final theme = Theme.of(context);
        final scale = theme.extension<ScaleScheme>()!;

        return Column(children: <Widget>[
          Row(children: [
            IconButton(
                icon: const Icon(Icons.settings),
                color: scale.secondaryScale.text,
                constraints: const BoxConstraints.expand(height: 64, width: 64),
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(scale.secondaryScale.border),
                    shape: MaterialStateProperty.all(
                        const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(16))))),
                tooltip: translate('app_bar.settings_tooltip'),
                onPressed: () async {
                  await GoRouterHelper(context).push('/settings');
                }).paddingLTRB(0, 0, 8, 0),
            asyncValueBuilder(account,
                    (_, account) => ProfileWidget(profile: account.profile))
                .expanded(),
          ]).paddingAll(8),
          const MainPager().expanded()
        ]);
      });

  Widget buildPhone(BuildContext context) =>
      Material(color: Colors.transparent, child: buildUserPanel());

  Widget buildTabletLeftPane(BuildContext context) => Builder(
      builder: (context) =>
          Material(color: Colors.transparent, child: buildUserPanel()));

  Widget buildTabletRightPane(BuildContext context) {
    final activeChatRemoteConversationKey =
        context.watch<ActiveChatCubit>().state;
    if (activeChatRemoteConversationKey == null) {
      return const EmptyChatWidget();
    }
    return ChatComponent.builder(
        remoteConversationRecordKey: activeChatRemoteConversationKey);
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
}
