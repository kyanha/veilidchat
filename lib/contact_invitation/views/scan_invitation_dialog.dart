import 'dart:async';
import 'dart:typed_data';

import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:image/image.dart' as img;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:provider/provider.dart';
import 'package:zxing2/qrcode.dart';

import '../../notifications/notifications.dart';
import '../../theme/theme.dart';
import 'invitation_dialog.dart';

// class BarcodeOverlay extends CustomPainter {
//   BarcodeOverlay({
//     required this.barcode,
//     required this.boxFit,
//     required this.capture,
//     required this.size,
//   });

//   final BarcodeCapture capture;
//   final Barcode barcode;
//   final BoxFit boxFit;
//   final Size size;

//   @override
//   void paint(Canvas canvas, Size size) {
//     final adjustedSize = applyBoxFit(boxFit, size, size);

//     var verticalPadding = size.height - adjustedSize.destination.height;
//     var horizontalPadding = size.width - adjustedSize.destination.width;
//     if (verticalPadding > 0) {
//       verticalPadding = verticalPadding / 2;
//     } else {
//       verticalPadding = 0;
//     }

//     if (horizontalPadding > 0) {
//       horizontalPadding = horizontalPadding / 2;
//     } else {
//       horizontalPadding = 0;
//     }

//     final ratioWidth = (Platform.isIOS ? capture.size.width : size.width) /
//         adjustedSize.destination.width;
//     final ratioHeight = (Platform.isIOS ? capture.size.height : size.height) /
//         adjustedSize.destination.height;

//     final adjustedOffset = <Offset>[];
//     for (final offset in barcode.corners) {
//       adjustedOffset.add(
//         Offset(
//           offset.dx / ratioWidth + horizontalPadding,
//           offset.dy / ratioHeight + verticalPadding,
//         ),
//       );
//     }
//     final cutoutPath = Path()..addPolygon(adjustedOffset, true);

//     final backgroundPaint = Paint()
//       ..color = Colors.red.withOpacity(0.3)
//       ..style = PaintingStyle.fill
//       ..blendMode = BlendMode.dstOut;

//     canvas.drawPath(cutoutPath, backgroundPaint);
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }

class ScannerOverlay extends CustomPainter {
  ScannerOverlay(this.scanWindow);

  final Rect scanWindow;

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPath = Path()..addRect(Rect.largest);
    final cutoutPath = Path()..addRect(scanWindow);

    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.dstOut;

    final backgroundWithCutout = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );
    canvas.drawPath(backgroundWithCutout, backgroundPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ScanInvitationDialog extends StatefulWidget {
  const ScanInvitationDialog({required Locator locator, super.key})
      : _locator = locator;

  @override
  ScanInvitationDialogState createState() => ScanInvitationDialogState();

  static Future<void> show(BuildContext context) async {
    final locator = context.read;
    await showPopControlDialog<void>(
        context: context,
        builder: (context) => StyledDialog(
            title: translate('scan_invitation_dialog.title'),
            child: ScanInvitationDialog(locator: locator)));
  }

  final Locator _locator;
}

class ScanInvitationDialogState extends State<ScanInvitationDialog> {
  bool scanned = false;

  @override
  void initState() {
    super.initState();
  }

  void onValidationCancelled() {
    setState(() {
      scanned = false;
    });
  }

  void onValidationSuccess() {}
  void onValidationFailed() {
    setState(() {
      scanned = false;
    });
  }

  bool inviteControlIsValid() => false; // _pasteTextController.text.isNotEmpty;

  Future<Uint8List?> scanQRImage(BuildContext context) async {
    final theme = Theme.of(context);
    //final textTheme = theme.textTheme;
    final scale = theme.extension<ScaleScheme>()!;
    final windowSize = MediaQuery.of(context).size;
    //final maxDialogWidth = min(windowSize.width - 64.0, 800.0 - 64.0);
    //final maxDialogHeight = windowSize.height - 64.0;

    final scanWindow = Rect.fromCenter(
      center: MediaQuery.of(context).size.center(Offset.zero),
      width: 200,
      height: 200,
    );

    final cameraController = MobileScannerController();
    try {
      return showDialog(
          context: context,
          builder: (context) => Stack(
                fit: StackFit.expand,
                children: [
                  MobileScanner(
                      fit: BoxFit.contain,
                      scanWindow: scanWindow,
                      controller: cameraController,
                      errorBuilder: (context, error, child) =>
                          ScannerErrorWidget(error: error),
                      onDetect: (c) {
                        final barcode = c.barcodes.firstOrNull;

                        final barcodeBytes = barcode?.rawBytes;
                        if (barcodeBytes != null) {
                          cameraController.dispose();
                          Navigator.pop(context, barcodeBytes);
                        }
                      }),
                  CustomPaint(
                    painter: ScannerOverlay(scanWindow),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      alignment: Alignment.bottomCenter,
                      height: 100,
                      color: Colors.black.withOpacity(0.4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            color: Colors.white,
                            icon: ValueListenableBuilder(
                              valueListenable: cameraController,
                              builder: (context, state, child) {
                                switch (state.torchState) {
                                  case TorchState.off:
                                    return Icon(Icons.flash_off,
                                        color:
                                            scale.grayScale.subtleBackground);
                                  case TorchState.on:
                                    return Icon(Icons.flash_on,
                                        color: scale.primaryScale.primary);
                                  case TorchState.auto:
                                    return Icon(Icons.flash_auto,
                                        color: scale.primaryScale.primary);
                                  case TorchState.unavailable:
                                    return Icon(Icons.no_flash,
                                        color: scale.primaryScale.primary);
                                }
                              },
                            ),
                            iconSize: 32,
                            onPressed: cameraController.toggleTorch,
                          ),
                          SizedBox(
                            width: windowSize.width - 120,
                            height: 50,
                            child: FittedBox(
                              child: Text(
                                translate(
                                    'scan_invitation_dialog.instructions'),
                                overflow: TextOverflow.fade,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge!
                                    .copyWith(color: Colors.white),
                              ),
                            ),
                          ),
                          IconButton(
                            color: Colors.white,
                            icon: ValueListenableBuilder(
                              valueListenable: cameraController,
                              builder: (context, state, child) {
                                switch (state.cameraDirection) {
                                  case CameraFacing.front:
                                    return const Icon(Icons.camera_front);
                                  case CameraFacing.back:
                                    return const Icon(Icons.camera_rear);
                                }
                              },
                            ),
                            iconSize: 32,
                            onPressed: cameraController.switchCamera,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                          color: Colors.white,
                          icon:
                              Icon(Icons.close, color: scale.grayScale.primary),
                          iconSize: 32,
                          onPressed: () => {
                                SchedulerBinding.instance
                                    .addPostFrameCallback((_) {
                                  cameraController.dispose();
                                  Navigator.pop(context);
                                })
                              })),
                ],
              ));
    } on MobileScannerException catch (e) {
      if (e.errorCode == MobileScannerErrorCode.permissionDenied) {
        context
            .read<NotificationsCubit>()
            .error(text: translate('scan_invitation_dialog.permission_error'));
      } else {
        context
            .read<NotificationsCubit>()
            .error(text: translate('scan_invitation_dialog.error'));
      }
    } on Exception catch (_) {
      context
          .read<NotificationsCubit>()
          .error(text: translate('scan_invitation_dialog.error'));
    }

    return null;
  }

  Future<Uint8List?> pasteQRImage(BuildContext context) async {
    final imageBytes = await Pasteboard.image;
    if (imageBytes == null) {
      if (context.mounted) {
        context
            .read<NotificationsCubit>()
            .error(text: translate('scan_invitation_dialog.not_an_image'));
      }
      return null;
    }

    final image = img.decodeImage(imageBytes);
    if (image == null) {
      if (context.mounted) {
        context.read<NotificationsCubit>().error(
            text: translate('scan_invitation_dialog.could_not_decode_image'));
      }
      return null;
    }

    try {
      final source = RGBLuminanceSource(
          image.width,
          image.height,
          image
              .convert(numChannels: 4)
              .getBytes(order: img.ChannelOrder.abgr)
              .buffer
              .asInt32List());
      final bitmap = BinaryBitmap(HybridBinarizer(source));

      final reader = QRCodeReader();
      final result = reader.decode(bitmap);

      final segs = result.resultMetadata[ResultMetadataType.byteSegments]!
          as List<Int8List>;
      return Uint8List.fromList(segs[0].toList());
    } on Exception catch (_) {
      if (context.mounted) {
        context.read<NotificationsCubit>().error(
            text: translate('scan_invitation_dialog.not_a_valid_qr_code'));
      }
      return null;
    }
  }

  Widget buildInviteControl(
      BuildContext context,
      InvitationDialogState dialogState,
      Future<void> Function({required Uint8List inviteData})
          validateInviteData) {
    //final theme = Theme.of(context);
    //final scale = theme.extension<ScaleScheme>()!;
    //final textTheme = theme.textTheme;
    //final height = MediaQuery.of(context).size.height;

    if (isiOS || isAndroid) {
      return Column(mainAxisSize: MainAxisSize.min, children: [
        if (!scanned)
          Text(
            translate('scan_invitation_dialog.scan_qr_here'),
          ).paddingLTRB(0, 0, 0, 8),
        if (!scanned)
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            child: ElevatedButton(
                onPressed: dialogState.isValidating
                    ? null
                    : () async {
                        final inviteData = await scanQRImage(context);
                        if (inviteData != null) {
                          setState(() {
                            scanned = true;
                          });
                          await validateInviteData(inviteData: inviteData);
                        }
                      },
                child: Text(translate('scan_invitation_dialog.scan'))),
          ).paddingLTRB(0, 0, 0, 8)
      ]);
    }
    return Column(mainAxisSize: MainAxisSize.min, children: [
      if (!scanned)
        Text(
          translate('scan_invitation_dialog.paste_qr_here'),
        ).paddingLTRB(0, 0, 0, 8),
      if (!scanned)
        Container(
          constraints: const BoxConstraints(maxHeight: 200),
          child: ElevatedButton(
              onPressed: dialogState.isValidating
                  ? null
                  : () async {
                      final inviteData = await pasteQRImage(context);
                      if (inviteData != null) {
                        await validateInviteData(inviteData: inviteData);
                        setState(() {
                          scanned = true;
                        });
                      }
                    },
              child: Text(translate('scan_invitation_dialog.paste'))),
        ).paddingLTRB(0, 0, 0, 8)
    ]);
  }

  @override
  // ignore: prefer_expression_function_bodies
  Widget build(BuildContext context) {
    return InvitationDialog(
        locator: widget._locator,
        onValidationCancelled: onValidationCancelled,
        onValidationSuccess: onValidationSuccess,
        onValidationFailed: onValidationFailed,
        inviteControlIsValid: inviteControlIsValid,
        buildInviteControl: buildInviteControl);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<bool>('scanned', scanned));
  }
}
