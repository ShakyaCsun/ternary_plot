import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:ternary_plot/src/models/models.dart';

class TernaryPoint extends Equatable implements Comparable<TernaryPoint> {
  const TernaryPoint({required this.a, required this.b, required this.c})
    : assert(
        a >= 0 && b >= 0 && c >= 0,
        'All points in TernaryPoint must be positive',
      ),
      total = a + b + c;

  /// Bottom Left
  ///
  /// If a = total, this translates to (x, y) = (0, 0)
  final double a;

  /// Bottom Right
  ///
  /// If b = total, this translates to (x, y) = (0, 1)
  final double b;

  /// Top Vertex
  ///
  /// If c = total, this translates to (x, y) = (0.5, sqrt(3)/2)
  final double c;

  final double total;

  (double x, double y) get xyPoint {
    // https://en.wikipedia.org/wiki/Ternary_plot
    return (0.5 * (2 * b + c) / total, sqrt_3by2 * c / total);
  }

  /// Corrected cartesian point for Flutter world where (0, 0) is top left
  /// and (1, 1) is bottom right
  Offset get cartesianPoint {
    final (x, y) = xyPoint;
    return Offset(x, 1 - y);
  }

  @override
  int compareTo(TernaryPoint other) {
    final (x, y) = xyPoint;
    final (otherX, otherY) = other.xyPoint;
    if (y != otherY) {
      return otherY.compareTo(y);
    }
    if (x != otherX) {
      return x.compareTo(y);
    }
    return 0;
  }

  @override
  List<Object> get props => [a, b, c];
}
