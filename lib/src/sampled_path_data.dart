import 'package:flutter/rendering.dart';

/// This is a class used to store the sampled path data.
/// In addition to the sampled points from both paths, it stores the
/// indices of points that are at the beginning of a contour.
class SampledPathData {
  final points1 = <Offset>[];
  final points2 = <Offset>[];
  final shiftedPoints = <Offset>[];
  final endIndices = <int>[];
  var points1IsClosed = false;
  var points2IsClosed = false;
}
