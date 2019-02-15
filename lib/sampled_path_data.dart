import 'package:flutter/rendering.dart';

/// This is a class used to store the sampled path data.
/// In addition to the sampled points from both paths, it stores the
/// indices of points that are at the beginning of a contour.
class SampledPathData {
  var points1;
  var points2;
  var endIndices;
  var shiftedPoints;

  SampledPathData() {
    points1 = List<Offset>();
    points2 = List<Offset>();
    shiftedPoints = List<Offset>();
    endIndices = List<int>();
  }
}
