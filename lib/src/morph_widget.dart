import 'package:flutter/material.dart';
import 'package:path_morph/src/morph_default_painter.dart';
import 'package:path_morph/src/path_morph_utils.dart';

typedef PainterProvider = CustomPainter Function(Path);

/// This package currently allows you to morph two paths only if
/// they both have an equal number of contours. You can think of
/// a contour as a line you can draw without lifting the pen.
///
/// For example, the path to draw a triangle, a circle, or a square
/// has one contour only. But a path to draw two concentric circles
/// will have two contours.
class MorphWidget extends StatefulWidget {
  /// The path that is drawn first
  final Path path1;

  /// The path that we morph into
  final Path path2;

  /// A controller, move forward to animate from path1 to path2
  /// and move backward to animate from path2 to path1
  final AnimationController controller;

  /// A function that returns a [CustomPainter] that draws the path
  /// default uses [MorphDefaultPainter]
  final PainterProvider? painter;

  const MorphWidget({
    required this.path1,
    required this.path2,
    required this.controller,
    this.painter,
    super.key,
  });

  @override
  State<MorphWidget> createState() => _MorphWidgetState();
}

class _MorphWidgetState extends State<MorphWidget> {
  late final _data = PathMorphUtils.samplePaths(widget.path1, widget.path2);
  late final _animations = <int, Animation<Offset>>{};

  @override
  void initState() {
    super.initState();
    _animations
      ..clear()
      ..addAll(PathMorphUtils.generateAnimations(widget.controller, _data))
      ..forEach(_addAnimationListener);
  }

  void _addAnimationListener(int index, Animation<Offset> animation) {
    animation.addListener(() => _data.shiftedPoints[index] = animation.value);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) {
        final path = PathMorphUtils.generatePath(_data);
        return CustomPaint(
          painter: widget.painter?.call(path) ??
              MorphDefaultPainter(
                path,
                Paint()
                  ..color = Colors.red
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 3,
              ),
        );
      },
    );
  }
}
