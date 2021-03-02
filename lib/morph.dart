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
        Offset position =
            metric.getTangentForOffset(metric.length * i).position;
        data.points1.add(position);
        data.shiftedPoints.add(position);
      }
    });
    path2.computeMetrics().forEach((metric) {
      data.endIndices.add(k);
      for (var i = 0.0; i < 1.1; i += precision) {
        k += 1;
        data.points2
            .add(metric.getTangentForOffset(metric.length * i).position);
      }
    });

    /// If path1 and path2 are closed, the points1 offsets are rotated one at a
    /// time to calculate sum of squared distances. Consequently, the same
    /// process is repeated for reversed points1 order.
    /// This way we can find more optimal pairs of points for smoother morphing.
    data.points1IsClosed = data.points1.first == data.points1.last ? true : false;
    data.points2IsClosed = data.points2.first == data.points2.last ? true : false;
    if(data.points1IsClosed && data.points2IsClosed) {
      double minSumDistSqrd = double.infinity;
      int optimalIndex;
      bool isReversed;
      for (int reversed = 0; reversed <= 1; reversed++) {
        if (reversed == 1) {
          data.points1 = List.from(data.points1.reversed);
        }
        for (int shiftIndex = 0; shiftIndex < data.points1.length; shiftIndex++) {
          double sumDistSqrd = 0;
          for (int pointIndex = 0; pointIndex < data.points1.length; pointIndex++) {
            sumDistSqrd += (data.points1[pointIndex] - data.points2[pointIndex]).distanceSquared;
          }
          if (sumDistSqrd < minSumDistSqrd) {
            minSumDistSqrd = sumDistSqrd;
            optimalIndex = shiftIndex;
            isReversed = reversed == 1 ? true : false;
          }
          data.points1 = _shiftList(data.points1, 1);
        }
      }
      data.points1 = _shiftList(data.points1, optimalIndex);
      data.points1 =
      isReversed ? data.points1 : List.from(data.points1.reversed);
    }
    return data;
  }

  /// shift list by offset v
  static List<Object> _shiftList(List<Object> list, int v) {
    if(list == null || list.isEmpty) return list;
    var i = v % list.length;
    return list.sublist(i)..addAll(list.sublist(0, i));
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
    if(data.points1IsClosed && data.points2IsClosed) {p.close();}
    return p;
  }
}
