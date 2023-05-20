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
  late SampledPathData data;
  late AnimationController controller;

  @override
  void initState() {
    super.initState();

    Path path1 = createPath1();
    Path path2 = createPath2();

    data = PathMorph.samplePaths(path1, path2);

    controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));

    PathMorph.generateAnimations(controller, data, func);

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        controller.forward();
      }
    });

    controller.forward();
  }

  void func(int i, Offset z) {
    setState(() {
      data.shiftedPoints[i] = z;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: MyPainter(PathMorph.generatePath(data)));
  }
}

class MyPainter extends CustomPainter {
  Path path;
  late Paint myPaint;

  MyPainter(this.path) {
    myPaint = Paint();
    myPaint.color = const Color.fromRGBO(255, 0, 0, 1.0);
    myPaint.style = PaintingStyle.stroke;
    myPaint.strokeWidth = 3.0;
  }

  @override
  void paint(Canvas canvas, Size size) => canvas.drawPath(path, myPaint);

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

/*
* Use any method you want to create your paths.
* These are some very simple paths for the sake of an example only.
*/
Path createPath1() {
  return Path()
    ..moveTo(60, 200)
    ..lineTo(60, 150)
    ..lineTo(200, 150)
    ..lineTo(200, 200);
}

Path createPath2() {
  return Path()
    ..moveTo(60, 200)
    ..lineTo(90, 150)
    ..lineTo(150, 100)
    ..lineTo(180, 150)
    ..lineTo(250, 190)
    ..lineTo(250, 250);
}
