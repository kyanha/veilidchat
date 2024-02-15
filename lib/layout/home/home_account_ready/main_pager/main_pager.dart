import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:stylish_bottom_bar/model/bar_items.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';

import '../../../../contact_invitation/contact_invitation.dart';
import '../../../../theme/theme.dart';
import '../../../../tools/tools.dart';
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

  final _unfocusNode = FocusNode();

  var _currentPage = 0;
  final pageController = PreloadPageController();

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
    translate('pager.account'),
    translate('pager.chats'),
  ];

  //////////////////////////////////////////////////////////////////

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _unfocusNode.dispose();
    pageController.dispose();
    super.dispose();
  }

  bool onScrollNotification(ScrollNotification notification) {
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

  BottomBarItem buildBottomBarItem(int index) {
    final theme = Theme.of(context);
    final scale = theme.extension<ScaleScheme>()!;
    return BottomBarItem(
      title: Text(_bottomLabelList[index]),
      icon: Icon(_selectedIconList[index], color: scale.primaryScale.text),
      selectedIcon:
          Icon(_selectedIconList[index], color: scale.primaryScale.text),
      backgroundColor: scale.primaryScale.text,
      //unSelectedColor: theme.colorScheme.primaryContainer,
      //selectedColor: theme.colorScheme.primary,
      //badge: const Text('9+'),
      //showBadge: true,
    );
  }

  List<BottomBarItem> _buildBottomBarItems() {
    final bottomBarItems = List<BottomBarItem>.empty(growable: true);
    for (var index = 0; index < _bottomLabelList.length; index++) {
      final item = buildBottomBarItem(index);
      bottomBarItems.add(item);
    }
    return bottomBarItems;
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
              content: ScanInviteDialog(
                modalContext: context,
              ));
        });
  }

  Widget _onNewChatBottomSheetBuilder(
          BuildContext sheetContext, BuildContext context) =>
      const SizedBox(
          height: 200,
          child: Center(
              child: Text(
                  'Group and custom chat functionality is not available yet')));

  Widget _bottomSheetBuilder(BuildContext sheetContext, BuildContext context) {
    if (_currentPage == 0) {
      // New contact invitation
      return newContactInvitationBottomSheetBuilder(sheetContext, context);
    } else if (_currentPage == 1) {
      // New chat
      return _onNewChatBottomSheetBuilder(sheetContext, context);
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

    return Scaffold(
      //extendBody: true,
      backgroundColor: Colors.transparent,
      body: NotificationListener<ScrollNotification>(
          onNotification: onScrollNotification,
          child: PreloadPageView(
              controller: pageController,
              preloadPagesCount: 2,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
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
      bottomNavigationBar: StylishBottomBar(
        backgroundColor: scale.primaryScale.hoverBorder,
        // gradient: LinearGradient(
        //     begin: Alignment.topCenter,
        //     end: Alignment.bottomCenter,
        //     colors: <Color>[
        //       theme.colorScheme.primary,
        //       theme.colorScheme.primaryContainer,
        //     ]),
        //borderRadius: BorderRadius.all(Radius.circular(16)),
        option: AnimatedBarOptions(
          // iconSize: 32,
          //barAnimation: BarAnimation.fade,
          iconStyle: IconStyle.animated,
          inkEffect: true,
          inkColor: scale.primaryScale.hoverBackground,
          //opacity: 0.3,
        ),
        items: _buildBottomBarItems(),
        hasNotch: true,
        fabLocation: StylishBarFabLocation.end,
        currentIndex: _currentPage,
        onTap: (index) async {
          await pageController.animateToPage(index,
              duration: 250.ms, curve: Curves.easeInOut);
        },
      ),

      floatingActionButton: BottomSheetActionButton(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(14))),
          foregroundColor: scale.secondaryScale.text,
          backgroundColor: scale.secondaryScale.hoverBorder,
          builder: (context) => Icon(
                _fabIconList[_currentPage],
                color: scale.secondaryScale.text,
              ),
          bottomSheetBuilder: (sheetContext) =>
              _bottomSheetBuilder(sheetContext, context)),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<PreloadPageController>(
        'pageController', pageController));
  }
}
