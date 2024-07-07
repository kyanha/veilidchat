import 'dart:async';

import 'package:animated_bottom_navigation_bar/'
    'animated_bottom_navigation_bar.dart';
import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:provider/provider.dart';

import '../../../../chat/chat.dart';
import '../../../../contact_invitation/contact_invitation.dart';
import '../../../../theme/theme.dart';
import 'account_page.dart';
import 'bottom_sheet_action_button.dart';
import 'chats_page.dart';

class MainPager extends StatefulWidget {
  const MainPager({super.key});

  @override
  MainPagerState createState() => MainPagerState();

  static MainPagerState? of(BuildContext context) =>
      context.findAncestorStateOfType<MainPagerState>();
}

class MainPagerState extends State<MainPager> with TickerProviderStateMixin {
  //////////////////////////////////////////////////////////////////

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification is UserScrollNotification &&
        notification.metrics.axis == Axis.vertical) {
      switch (notification.direction) {
        case ScrollDirection.forward:
          // _hideBottomBarAnimationController.reverse();
          // _fabAnimationController.forward(from: 0);
          break;
        case ScrollDirection.reverse:
          // _hideBottomBarAnimationController.forward();
          // _fabAnimationController.reverse(from: 1);
          break;
        case ScrollDirection.idle:
          break;
      }
    }
    return false;
  }

  Future<void> scanContactInvitationDialog(BuildContext context) async {
    await showDialog<void>(
        context: context,
        // ignore: prefer_expression_function_bodies
        builder: (context) {
          return AlertDialog(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              contentPadding: const EdgeInsets.only(
                top: 10,
              ),
              title: const Text(
                'Scan Contact Invite',
                style: TextStyle(fontSize: 24),
              ),
              content: ScanInvitationDialog(
                locator: context.read,
              ));
        });
  }

  Widget _buildBottomBarItem(int index, bool isActive) {
    final theme = Theme.of(context);
    final scale = theme.extension<ScaleScheme>()!;
    final scaleConfig = theme.extension<ScaleConfig>()!;

    final color = scaleConfig.useVisualIndicators
        ? (scaleConfig.preferBorders
            ? scale.primaryScale.border
            : scale.primaryScale.borderText)
        : (isActive
            ? (scaleConfig.preferBorders
                ? scale.primaryScale.border
                : scale.primaryScale.borderText)
            : (scaleConfig.preferBorders
                ? scale.primaryScale.subtleBorder
                : scale.primaryScale.borderText.withAlpha(0x80)));

    final item = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          _selectedIconList[index],
          size: 24,
          color: color,
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            _bottomLabelList[index],
            style: theme.textTheme.labelLarge!.copyWith(
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: color),
          ),
        )
      ],
    );

    if (scaleConfig.useVisualIndicators && isActive) {
      return DecoratedBox(
              decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          14 * scaleConfig.borderRadiusScale),
                      side: BorderSide(
                          width: 2,
                          color: scaleConfig.preferBorders
                              ? scale.primaryScale.border
                              : scale.primaryScale.borderText))),
              child: item)
          .paddingLTRB(8, 0, 8, 6);
    }

    return item;
  }

  Widget _bottomSheetBuilder(BuildContext sheetContext, BuildContext context) {
    if (currentPage == 0) {
      // New contact invitation
      return newContactBottomSheetBuilder(sheetContext, context);
    } else if (currentPage == 1) {
      // New chat
      return newChatBottomSheetBuilder(sheetContext, context);
    } else {
      // Unknown error
      return debugPage('unknown page');
    }
  }

  @override
  // ignore: prefer_expression_function_bodies
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scale = theme.extension<ScaleScheme>()!;
    final scaleConfig = theme.extension<ScaleConfig>()!;

    return Scaffold(
      //extendBody: true,
      backgroundColor: Colors.transparent,
      body: NotificationListener<ScrollNotification>(
          onNotification: _onScrollNotification,
          child: PreloadPageView(
              key: _pageViewKey,
              controller: pageController,
              preloadPagesCount: 2,
              onPageChanged: (index) {
                setState(() {
                  currentPage = index;
                });
              },
              children: const [
                AccountPage(),
                ChatsPage(),
              ])),
      // appBar: AppBar(
      //   toolbarHeight: 24,
      //   title: Text(
      //     'C',
      //     style: Theme.of(context).textTheme.headlineSmall,
      //   ),
      // ),
      bottomNavigationBar: AnimatedBottomNavigationBar.builder(
        itemCount: 2,
        height: 64,
        tabBuilder: _buildBottomBarItem,
        activeIndex: currentPage,
        gapLocation: GapLocation.end,
        gapWidth: 90,
        notchSmoothness: NotchSmoothness.defaultEdge,
        notchMargin: 4,
        backgroundColor: scaleConfig.preferBorders
            ? scale.primaryScale.hoverElementBackground
            : scale.primaryScale.hoverBorder,
        elevation: 0,
        onTap: (index) async {
          await pageController.animateToPage(index,
              duration: 250.ms, curve: Curves.easeInOut);
        },
      ),
      floatingActionButton: BottomSheetActionButton(
          shape: CircleBorder(
            side: !scaleConfig.useVisualIndicators
                ? BorderSide.none
                : BorderSide(
                    strokeAlign: BorderSide.strokeAlignCenter,
                    color: scaleConfig.preferBorders
                        ? scale.secondaryScale.border
                        : scale.secondaryScale.borderText,
                    width: 2),
          ),
          foregroundColor: scaleConfig.preferBorders
              ? scale.secondaryScale.border
              : scale.secondaryScale.borderText,
          backgroundColor: scaleConfig.preferBorders
              ? scale.secondaryScale.hoverElementBackground
              : scale.secondaryScale.hoverBorder,
          builder: (context) => Icon(
                _fabIconList[currentPage],
                color: scaleConfig.preferBorders
                    ? scale.secondaryScale.border
                    : scale.secondaryScale.borderText,
              ),
          bottomSheetBuilder: (sheetContext) =>
              _bottomSheetBuilder(sheetContext, context)),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }

  //////////////////////////////////////////////////////////////////

  final _selectedIconList = <IconData>[Icons.person, Icons.chat];
  // final _unselectedIconList = <IconData>[
  //   Icons.chat_outlined,
  //   Icons.person_outlined
  // ];
  final _fabIconList = <IconData>[
    Icons.person_add_sharp,
    Icons.add_comment_sharp,
  ];
  final _bottomLabelList = <String>[
    translate('pager.contacts'),
    translate('pager.chats'),
  ];
  final _pageViewKey = GlobalKey(debugLabel: '_pageViewKey');

  // key-accessible controller
  int currentPage = 0;
  final pageController = PreloadPageController();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(IntProperty('currentPage', currentPage))
      ..add(DiagnosticsProperty<PreloadPageController>(
          'pageController', pageController));
  }
}
