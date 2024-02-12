import 'package:flutter/material.dart';

import '../../theme/theme.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({required this.child, super.key});

  @override
  HomeShellState createState() => HomeShellState();

  final Widget child;
}

class HomeShellState extends State<HomeShell> {
  final _unfocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _unfocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scale = theme.extension<ScaleScheme>()!;

    // XXX: eventually write account switcher here
    return SafeArea(
        child: GestureDetector(
            onTap: () => FocusScope.of(context).requestFocus(_unfocusNode),
            child: DecoratedBox(
                decoration: BoxDecoration(
                    color: scale.primaryScale.activeElementBackground),
                child: widget.child)));
  }
}
