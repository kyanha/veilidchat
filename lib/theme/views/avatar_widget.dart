import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../theme.dart';

class AvatarWidget extends StatelessWidget {
  AvatarWidget({
    required String name,
    required double size,
    required Color borderColor,
    required Color foregroundColor,
    required Color backgroundColor,
    required ScaleConfig scaleConfig,
    required TextStyle textStyle,
    super.key,
    ImageProvider<Object>? imageProvider,
  })  : _name = name,
        _size = size,
        _borderColor = borderColor,
        _foregroundColor = foregroundColor,
        _backgroundColor = backgroundColor,
        _scaleConfig = scaleConfig,
        _textStyle = textStyle,
        _imageProvider = imageProvider;

  @override
  Widget build(BuildContext context) {
    final abbrev = _name.split(' ').map((s) => s.isEmpty ? '' : s[0]).join();
    late final String shortname;
    if (abbrev.length >= 3) {
      shortname = abbrev[0] + abbrev[1] + abbrev[abbrev.length - 1];
    } else {
      shortname = abbrev;
    }

    return Container(
        height: _size,
        width: _size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: _scaleConfig.preferBorders
              ? Border.all(
                  color: _borderColor,
                  width: 1 * (_size ~/ 32 + 1),
                  strokeAlign: BorderSide.strokeAlignOutside)
              : null,
          color: _borderColor,
        ),
        child: AvatarImage(
            //size: 32,
            backgroundImage: _imageProvider,
            backgroundColor:
                _scaleConfig.useVisualIndicators && !_scaleConfig.preferBorders
                    ? _foregroundColor
                    : _backgroundColor,
            child: Text(
              shortname,
              style: _textStyle.copyWith(
                color: _scaleConfig.useVisualIndicators &&
                        !_scaleConfig.preferBorders
                    ? _backgroundColor
                    : _foregroundColor,
              ),
            )));
  }

  ////////////////////////////////////////////////////////////////////////////
  final String _name;
  final double _size;
  final Color _borderColor;
  final Color _foregroundColor;
  final Color _backgroundColor;
  final ScaleConfig _scaleConfig;
  final TextStyle _textStyle;
  final ImageProvider<Object>? _imageProvider;
}
