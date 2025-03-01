import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:ternary_plot/src/models/models.dart';

/// Square root of 3.
const sqrt_3 = 1.7320508075688772;

/// Square root of 3, divided by 2
const sqrt_3by2 = sqrt_3 / 2;

class EquilateralTriangle extends Equatable {
  EquilateralTriangle({required this.padding, required this.availableSize});

  static final zero = EquilateralTriangle(padding: 0, availableSize: Size.zero);
  final double padding;
  final Size availableSize;

  /// Maximum [Size] of Equilateral Triangle that fits in [availableSize] with
  /// given [padding]
  late final Size triangleSize = () {
    final Size(:width, :height) = availableSize;
    final (maxWidth, maxHeight) = (width - padding * 2, height - padding * 2);

    // Desired height if triangle width equals maxWidth
    final desiredHeight = sqrt_3by2 * maxWidth;
    final widthFits = maxHeight >= desiredHeight;
    return switch (widthFits) {
      // Expand to maxWidth
      true => Size(maxWidth, desiredHeight),
      // Expand to maxHeight
      false => Size(2 / sqrt_3 * maxHeight, maxHeight),
    };
  }();

  /// Required [Offset] to center the triangle with minimum padding of [padding]
  /// on either sides of [availableSize].
  late final Offset centerOffset = Offset(
    (availableSize.width - triangleSize.width) / 2,
    (availableSize.height - triangleSize.height) / 2 -
        triangleSize.width +
        triangleSize.height,
  );

  /// Bottom Left vertex
  Offset get A => Offset(0, triangleSize.width) + centerOffset;

  /// Bottom Right vertex
  Offset get B {
    return Offset(triangleSize.width, triangleSize.width) + centerOffset;
  }

  /// Top vertex
  Offset get C {
    return Offset(
          triangleSize.width / 2,
          triangleSize.width - triangleSize.height,
        ) +
        centerOffset;
  }

  Path get path {
    return Path()
      ..moveTo(A.dx, A.dy)
      ..lineTo(B.dx, B.dy)
      ..lineTo(C.dx, C.dy)
      ..close();
  }

  Offset correctedPosition({required TernaryPoint point}) {
    return (point.cartesianPoint * triangleSize.width) + centerOffset;
  }

  Path getAreaPath({required List<TernaryPoint> points, bool close = true}) {
    final pointsCount = points.length;
    if (pointsCount == 0) {
      return Path();
    }
    final Offset(dx: x, dy: y) = correctedPosition(point: points[0]);
    if (pointsCount == 1) {
      return Path()
        ..moveTo(x, y)
        ..addOval(Rect.fromCircle(center: Offset.zero, radius: 1));
    }
    final areaPath = Path()..moveTo(x, y);
    for (final point in points.skip(1)) {
      final Offset(:dx, :dy) = correctedPosition(point: point);
      areaPath.lineTo(dx, dy);
    }
    if (close) {
      return areaPath..close();
    }
    return areaPath;
  }

  @override
  List<Object> get props => [padding, availableSize];
}
