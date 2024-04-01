import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:radix_colors/radix_colors.dart';

import '../tools/tools.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({super.key});

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await changeWindowSetup(
          TitleBarStyle.hidden, OrientationCapability.normal);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final monoTextStyle = textTheme.labelSmall!
        .copyWith(fontFamily: 'Source Code Pro', fontSize: 11);
    final emojiTextStyle = textTheme.labelSmall!
        .copyWith(fontFamily: 'Noto Color Emoji', fontSize: 11);

    return Scaffold(
        body: DecoratedBox(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
            RadixColors.dark.plum.step4,
            RadixColors.dark.plum.step2,
          ])),
      child: Center(
          child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Hack to preload fonts
                    Offstage(child: Text('🧱', style: emojiTextStyle)),
                    // Hack to preload fonts
                    Offstage(child: Text('A', style: monoTextStyle)),
                    // Splash Screen
                    Expanded(
                        flex: 2,
                        child: SvgPicture.asset(
                          'assets/images/icon.svg',
                        )),
                    Expanded(
                        child: SvgPicture.asset(
                      'assets/images/title.svg',
                    ))
                  ]))),
    ));
  }
}
