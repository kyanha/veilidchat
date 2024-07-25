import 'package:flutter/widgets.dart';

import '../../notifications/notifications.dart';

class RouterShell extends StatelessWidget {
  const RouterShell({required Widget child, super.key}) : _child = child;

  @override
  Widget build(BuildContext context) => NotificationsWidget(child: _child);

  final Widget _child;
}
