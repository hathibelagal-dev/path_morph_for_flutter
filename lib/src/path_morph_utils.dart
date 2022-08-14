import 'package:flutter/animation.dart';
import 'package:flutter/rendering.dart';
import 'package:path_morph/src/sampled_path_data.dart';

typedef UpdatePointCallback = void Function(int i, Offset z);

/// This class has all the methods you need to create your morph animations.
class PathMorphUtils {
  /// This method is responsible for sampling both the paths. It generates a
  /// [SampledPathData] object containing all the details required for the
  /// morph animation.
  static SampledPathData samplePaths(Path path1, Path path2, {double precision = 0.01}) {
    final data = SampledPathData();
    var k = 0;
    path1.computeMetrics().forEach((metric) {
      for (var i = 0.0; i < 1.1; i += precision) {
        final position = metric.getTangentForOffset(metric.length * i)?.position;
        if (position == null) continue;
        data.points1.add(position);
        data.shiftedPoints.add(position);
      }
    });
    path2.computeMetrics().forEach((metric) {
      data.endIndices.add(k);
      for (var i = 0.0; i < 1.1; i += precision) {
        k += 1;
        final position = metric.getTangentForOffset(metric.length * i)?.position;
        if (position == null) continue;
        data.points2.add(position);
      }
    });

    // If path1 and path2 are closed, the points1 offsets are rotated one at a
    // time to calculate sum of squared distances. Consequently, the same
    // process is repeated for reversed points1 order.
    // This way we can find more optimal pairs of points for smoother morphing.
    data.points1IsClosed = data.points1.first == data.points1.last ? true : false;
    data.points2IsClosed = data.points2.first == data.points2.last ? true : false;
    if (data.points1IsClosed && data.points2IsClosed) {
      var minSumDistSqrd = double.infinity;
      int? optimalIndex;
      var isReversed = false;
      for (var reversed = 0; reversed <= 1; reversed++) {
        if (reversed == 1) {
          data.points1
            ..clear()
            ..addAll(data.points1.reversed);
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
          data.points1
            ..clear()
            ..addAll(_shiftList(data.points1, 1));
        }
      }
      final shifted = _shiftList(data.points1, optimalIndex);
      data.points1
        ..clear()
        ..addAll(isReversed ? shifted : shifted.reversed);
    }
    return data;
  }

  /// shift list by offset v
  static List<T> _shiftList<T>(List<T> list, int? v) {
    if (list.isEmpty || v == null || v == 0) return list;
    final i = v % list.length;
    return list.sublist(i)..addAll(list.sublist(0, i));
  }

  /// Generates a bunch of animations that are responsible for moving
  /// all the points of paths into the right positions.
  static Map<int, Animation<Offset>> generateAnimations(AnimationController controller, SampledPathData data) {
    final animations = <int, Animation<Offset>>{};
    for (var i = 0; i < data.points1.length; i++) {
      final start = data.points1[i];
      final end = data.points2[i];
      final tween = Tween(begin: start, end: end);
      final animation = tween.animate(controller);
      animations.addAll({i: animation});
    }
    return animations;
  }

  /// Generates a path using the [SampledPathData] object.
  /// You can use this path while drawing the frames of
  /// the morph animation on your canvas.
  static Path generatePath(SampledPathData data) {
    final path = Path();
    for (var i = 0; i < data.shiftedPoints.length; i++) {
      for (var j = 0; j < data.endIndices.length; j++) {
        if (i == data.endIndices[j]) {
          path.moveTo(data.shiftedPoints[i].dx, data.shiftedPoints[i].dy);
          break;
        }
      }
      path.lineTo(data.shiftedPoints[i].dx, data.shiftedPoints[i].dy);
    }
    if (data.points1IsClosed && data.points2IsClosed) {
      path.close();
    }
    return path;
  }
}
