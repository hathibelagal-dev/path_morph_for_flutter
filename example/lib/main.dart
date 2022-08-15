import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:path_morph/path_morph.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() => _MyApp();
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
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: MorphWidget(
                controller: _controller,
                path1: _path1,
                path2: _path2,
              ),
            ),
            const Expanded(child: SvgMorphExample()),
          ],
        ),
      ),
    );
  }
}

class SvgMorphExample extends StatefulWidget {
  const SvgMorphExample({super.key});

  @override
  State<SvgMorphExample> createState() => _SvgMorphExampleState();
}

class _SvgMorphExampleState extends State<SvgMorphExample> with TickerProviderStateMixin {
  final _homePath = parseSvgPathData(
      r'M61.44,0L0,60.18l14.99,7.87L61.04,19.7l46.85,48.36l14.99-7.87L61.44,0L61.44,0z M18.26,69.63L18.26,69.63 L61.5,26.38l43.11,43.25h0v0v42.43H73.12V82.09H49.49v29.97H18.26V69.63L18.26,69.63L18.26,69.63z');

  final _appleScaleMatrix4 = Matrix4.identity()..scale(0.2, 0.2);
  late final _applePath = parseSvgPathData(
          r'M380.844,297.529c0.787,84.751,74.349,112.954,75.164,113.314c-0.622,1.989-11.754,40.192-38.756,79.653 c-23.342,34.116-47.568,68.107-85.731,68.811c-37.499,0.691-49.557-22.237-92.429-22.237c-42.859,0-56.256,21.533-91.753,22.928 c-36.837,1.394-64.888-36.892-88.424-70.883C10.822,419.585-25.931,292.64,23.419,206.95 c24.516-42.554,68.328-69.501,115.882-70.192c36.173-0.69,70.316,24.336,92.429,24.336c22.099,0,63.59-30.096,107.208-25.676 c18.26,0.76,69.516,7.376,102.429,55.552C438.715,192.614,380.208,226.674,380.844,297.529 M310.369,89.418 C329.926,65.745,343.089,32.79,339.498,0c-28.19,1.133-62.278,18.785-82.498,42.445c-18.121,20.952-33.991,54.487-29.709,86.628 C258.712,131.504,290.811,113.106,310.369,89.418')
      .transform(_appleScaleMatrix4.storage);
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
      path1: _homePath,
      path2: _applePath,
    );
  }
}
