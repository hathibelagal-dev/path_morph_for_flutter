import 'package:flutter/material.dart';

/// A default painter to show how to implement a custom painter
/// for the [MorphWidget]
class MorphDefaultPainter extends CustomPainter {
  final Path _path;
  final Paint _paint;

  MorphDefaultPainter(this._path, this._paint);

  @override
  void paint(Canvas canvas, Size size) => canvas.drawPath(_path, _paint);

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
