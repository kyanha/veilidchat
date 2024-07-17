import 'dart:async';

import 'package:ansicolor/ansicolor.dart';
import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:cool_dropdown/cool_dropdown.dart';
import 'package:cool_dropdown/models/cool_dropdown_item.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:go_router/go_router.dart';
import 'package:loggy/loggy.dart';
import 'package:quickalert/quickalert.dart';
import 'package:veilid_support/veilid_support.dart';
import 'package:xterm/xterm.dart';

import '../../layout/layout.dart';
import '../../theme/theme.dart';
import '../../tools/tools.dart';
import 'history_text_editing_controller.dart';

final globalDebugTerminal = Terminal(
  maxLines: 50000,
);

const kDefaultTerminalStyle = TerminalStyle(
    fontSize: 11,
    // height: 1.2,
    fontFamily: 'Source Code Pro');

class DeveloperPage extends StatefulWidget {
  const DeveloperPage({super.key});

  @override
  State<DeveloperPage> createState() => _DeveloperPageState();
}

class _DeveloperPageState extends State<DeveloperPage> {
  @override
  void initState() {
    super.initState();

    _historyController = HistoryTextEditingController(setState: setState);

    _terminalController.addListener(() {
      setState(() {});
    });

    for (var i = 0; i < logLevels.length; i++) {
      _logLevelDropdownItems.add(CoolDropdownItem<LogLevel>(
          label: logLevelName(logLevels[i]),
          icon: Text(logLevelEmoji(logLevels[i])),
          value: logLevels[i]));
    }
  }

  void _debugOut(String out) {
    final pen = AnsiPen()..cyan(bold: true);
    final colorOut = pen(out);
    debugPrint(colorOut);
    globalDebugTerminal.write(colorOut.replaceAll('\n', '\r\n'));
  }

  Future<bool> _sendDebugCommand(String debugCommand) async {
    try {
      setState(() {
        _busy = true;
      });

      if (debugCommand == 'pool allocations') {
        try {
          DHTRecordPool.instance.debugPrintAllocations();
        } on Exception catch (e, st) {
          _debugOut('<<< ERROR\n$e\n<<< STACK\n$st');
          return false;
        }
        return true;
      }

      if (debugCommand == 'pool opened') {
        try {
          DHTRecordPool.instance.debugPrintOpened();
        } on Exception catch (e, st) {
          _debugOut('<<< ERROR\n$e\n<<< STACK\n$st');
          return false;
        }
        return true;
      }

      if (debugCommand.startsWith('change_log_ignore ')) {
        final args = debugCommand.split(' ');
        if (args.length < 3) {
          _debugOut('Incorrect number of arguments');
          return false;
        }
        final layer = args[1];
        final changes = args[2].split(',');
        try {
          Veilid.instance.changeLogIgnore(layer, changes);
        } on Exception catch (e, st) {
          _debugOut('<<< ERROR\n$e\n<<< STACK\n$st');
          return false;
        }

        return true;
      }

      if (debugCommand == 'ellet') {
        setState(() {
          _showEllet = !_showEllet;
        });
        return true;
      }

      _debugOut('DEBUG >>>\n$debugCommand\n');
      try {
        final out = await Veilid.instance.debug(debugCommand);
        _debugOut('<<< DEBUG\n$out\n');
      } on Exception catch (e, st) {
        _debugOut('<<< ERROR\n$e\n<<< STACK\n$st');
        return false;
      }

      return true;
    } finally {
      setState(() {
        _busy = false;
      });
    }
  }

  Future<void> clear(BuildContext context) async {
    globalDebugTerminal.buffer.clear();
    if (context.mounted) {
      showInfoToast(context, translate('developer.cleared'));
    }
  }

  Future<void> copySelection(BuildContext context) async {
    final selection = _terminalController.selection;
    if (selection != null) {
      final text = globalDebugTerminal.buffer.getText(selection);
      _terminalController.clearSelection();
      await Clipboard.setData(ClipboardData(text: text));
      if (context.mounted) {
        showInfoToast(context, translate('developer.copied'));
      }
    }
  }

  Future<void> copyAll(BuildContext context) async {
    final text = globalDebugTerminal.buffer.getText();
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      showInfoToast(context, translate('developer.copied_all'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final scale = theme.extension<ScaleScheme>()!;
    final scaleConfig = theme.extension<ScaleConfig>()!;

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (!_isScrolling && _wantsBottom) {
    //     _scrollToBottom();
    //   }
    // });

    return Scaffold(
        backgroundColor: scale.primaryScale.primary,
        appBar: DefaultAppBar(
          title: Text(translate('developer.title')),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: scale.primaryScale.primaryText),
            onPressed: () => GoRouterHelper(context).pop(),
          ),
          actions: [
            IconButton(
                icon: const Icon(Icons.copy),
                color: scale.primaryScale.primaryText,
                disabledColor: scale.primaryScale.primaryText.withAlpha(0x3F),
                onPressed: _terminalController.selection == null
                    ? null
                    : () async {
                        await copySelection(context);
                      }),
            IconButton(
                icon: const Icon(Icons.copy_all),
                color: scale.primaryScale.primaryText,
                disabledColor: scale.primaryScale.primaryText.withAlpha(0x3F),
                onPressed: () async {
                  await copyAll(context);
                }),
            IconButton(
                icon: const Icon(Icons.clear_all),
                color: scale.primaryScale.primaryText,
                disabledColor: scale.primaryScale.primaryText.withAlpha(0x3F),
                onPressed: () async {
                  await QuickAlert.show(
                      context: context,
                      type: QuickAlertType.confirm,
                      title: translate('developer.are_you_sure_clear'),
                      titleColor: scale.primaryScale.appText,
                      textColor: scale.primaryScale.subtleText,
                      confirmBtnColor: scale.primaryScale.primary,
                      cancelBtnTextStyle: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: scale.primaryScale.appText),
                      backgroundColor: scale.primaryScale.appBackground,
                      headerBackgroundColor: scale.primaryScale.primary,
                      confirmBtnText: translate('button.ok'),
                      cancelBtnText: translate('button.cancel'),
                      onConfirmBtnTap: () async {
                        Navigator.pop(context);
                        if (context.mounted) {
                          await clear(context);
                        }
                      });
                }),
            CoolDropdown<LogLevel>(
              controller: _logLevelController,
              defaultItem: _logLevelDropdownItems
                  .singleWhere((x) => x.value == _logLevelDropDown),
              onChange: (value) {
                setState(() {
                  _logLevelDropDown = value;
                  Loggy('').level = getLogOptions(value);
                  setVeilidLogLevel(value);
                  _logLevelController.close();
                });
              },
              resultOptions: ResultOptions(
                width: 64,
                height: 40,
                render: ResultRender.icon,
                icon: SizedBox(
                    width: 10,
                    height: 10,
                    child: CustomPaint(
                        painter: DropdownArrowPainter(
                            color: scale.primaryScale.primaryText))),
                textStyle: textTheme.labelMedium!
                    .copyWith(color: scale.primaryScale.primaryText),
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                openBoxDecoration: BoxDecoration(
                  //color: scale.primaryScale.border,
                  border: Border.all(
                      color: scaleConfig.useVisualIndicators
                          ? scale.primaryScale.hoverBorder
                          : scale.primaryScale.borderText),
                  borderRadius:
                      BorderRadius.circular(8 * scaleConfig.borderRadiusScale),
                ),
                boxDecoration: BoxDecoration(
                  //color: scale.primaryScale.hoverBorder,
                  border: Border.all(
                      color: scaleConfig.useVisualIndicators
                          ? scale.primaryScale.hoverBorder
                          : scale.primaryScale.borderText),
                  borderRadius:
                      BorderRadius.circular(8 * scaleConfig.borderRadiusScale),
                ),
              ),
              dropdownOptions: DropdownOptions(
                width: 160,
                align: DropdownAlign.right,
                duration: 150.ms,
                color: scale.primaryScale.elementBackground,
                borderSide: BorderSide(color: scale.primaryScale.border),
                borderRadius:
                    BorderRadius.circular(8 * scaleConfig.borderRadiusScale),
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
              ),
              dropdownTriangleOptions: const DropdownTriangleOptions(
                  align: DropdownTriangleAlign.right),
              dropdownItemOptions: DropdownItemOptions(
                  selectedTextStyle: textTheme.labelMedium!
                      .copyWith(color: scale.primaryScale.appText),
                  textStyle: textTheme.labelMedium!
                      .copyWith(color: scale.primaryScale.appText),
                  selectedBoxDecoration: BoxDecoration(
                      color: scale.primaryScale.activeElementBackground),
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                  selectedPadding: const EdgeInsets.fromLTRB(8, 4, 8, 4)),
              dropdownList: _logLevelDropdownItems,
            ).paddingLTRB(0, 0, 8, 0)
          ],
        ),
        body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SafeArea(
                child: Column(children: [
              Stack(alignment: AlignmentDirectional.center, children: [
                Image.asset('assets/images/ellet.png'),
                TerminalView(globalDebugTerminal,
                    textStyle: kDefaultTerminalStyle,
                    controller: _terminalController,
                    keyboardType: TextInputType.none,
                    //autofocus: true,
                    backgroundOpacity: _showEllet ? 0.75 : 1.0,
                    onSecondaryTapDown: (details, offset) async {
                  await copySelection(context);
                })
              ]).expanded(),
              TextField(
                enabled: !_busy,
                controller: _historyController.controller,
                focusNode: _historyController.focusNode,
                onTapOutside: (event) {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                decoration: InputDecoration(
                    filled: true,
                    contentPadding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            8 * scaleConfig.borderRadiusScale),
                        borderSide: BorderSide.none),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                          8 * scaleConfig.borderRadiusScale),
                    ),
                    fillColor: scale.primaryScale.subtleBackground,
                    hintText: translate('developer.command'),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.send,
                          color: _historyController.controller.text.isEmpty
                              ? scale.primaryScale.primary.withAlpha(0x3F)
                              : scale.primaryScale.primary),
                      onPressed:
                          (_historyController.controller.text.isEmpty || _busy)
                              ? null
                              : () async {
                                  final debugCommand =
                                      _historyController.controller.text;
                                  _historyController.controller.clear();
                                  await _sendDebugCommand(debugCommand);
                                },
                    )),
                onChanged: (_) {
                  setState(() => {});
                },
                onEditingComplete: () {
                  // part of the default action if onEditingComplete is null
                  _historyController.controller.clearComposing();
                  // don't give up focus though
                },
                onSubmitted: (debugCommand) async {
                  if (debugCommand.isEmpty) {
                    return;
                  }

                  final ok = await _sendDebugCommand(debugCommand);
                  if (ok) {
                    setState(() {
                      _historyController.submit(debugCommand);
                    });
                  }
                },
              ).paddingAll(4)
            ]))));
  }

  ////////////////////////////////////////////////////////////////////////////

  final _terminalController = TerminalController();
  late final HistoryTextEditingController _historyController;

  final _logLevelController = DropdownController(duration: 250.ms);
  final List<CoolDropdownItem<LogLevel>> _logLevelDropdownItems = [];
  var _logLevelDropDown = log.level.logLevel;
  var _showEllet = false;
  var _busy = false;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<TerminalController>(
          'terminalController', _terminalController))
      ..add(
          DiagnosticsProperty<LogLevel>('logLevelDropDown', _logLevelDropDown));
  }
}
