import 'package:flutter/rendering.dart';
import 'package:flutter/animation.dart';
import './sampled_path_data.dart';

/// This class has all the methods you need to create your morph animations.
class PathMorph {
  /// This method is responsible for sampling both the paths. It generates a
  /// [SampledPathData] object containing all the details required for the
  /// morph animation.
  static SampledPathData samplePaths(Path path1, Path path2,
      {double precision = 0.01}) {
    var data = SampledPathData();
    var k = 0;
    path1.computeMetrics().forEach((metric) {
      for (var i = 0.0; i < 1.1; i += precision) {
        final position =
            metric.getTangentForOffset(metric.length * i)?.position;
        if (position != null) {
          data.points1.add(position);
          data.shiftedPoints.add(position);
        }
      }
    });
    path2.computeMetrics().forEach((metric) {
      data.endIndices.add(k);
      for (var i = 0.0; i < 1.1; i += precision) {
        k += 1;
        final position =
            metric.getTangentForOffset(metric.length * i)?.position;
        if (position != null) {
          data.points2.add(position);
        }
      }
    });
    return data;
  }

  /// Generates a bunch of animations that are responsible for moving
  /// all the points of paths into the right positions.
  static void generateAnimations(
      AnimationController controller, SampledPathData data, Function func) {
    for (var i = 0; i < data.points1.length; i++) {
      var start = data.points1[i];
      var end = data.points2[i];
      var tween = Tween(begin: start, end: end);
      var animation = tween.animate(controller);
      animation.addListener(() {
        func(i, animation.value);
      });
    }
  }

  /// Generates a path using the [SampledPathData] object.
  /// You can use this path while drawing the frames of
  /// the morph animation on your canvas.
  static Path generatePath(SampledPathData data) {
    Path p = Path();
    for (var i = 0; i < data.shiftedPoints.length; i++) {
      for (var j = 0; j < data.endIndices.length; j++) {
        if (i == data.endIndices[j]) {
          p.moveTo(data.shiftedPoints[i].dx, data.shiftedPoints[i].dy);
          break;
        }
      }
      p.lineTo(data.shiftedPoints[i].dx, data.shiftedPoints[i].dy);
    }
    return p;
  }
}
