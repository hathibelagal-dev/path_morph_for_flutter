import 'package:flutter/material.dart';
import 'package:path_morph/path_morph.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MyApp();
  }
}

class _MyApp extends State<MyApp> with SingleTickerProviderStateMixin {
  final _path1 = Path()
    ..moveTo(60, 200)
    ..lineTo(60, 150)
    ..lineTo(200, 150)
    ..lineTo(200, 200);
  final _path2 = Path()
    ..moveTo(60, 200)
    ..lineTo(90, 150)
    ..lineTo(150, 100)
    ..lineTo(180, 150)
    ..lineTo(250, 190)
    ..lineTo(250, 250);
  late final _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1));

  @override
  void initState() {
    super.initState();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _controller.forward();
      }
    });
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return MorphWidget(
      controller: _controller,
      path1: _path1,
      path2: _path2,
    );
  }
}
