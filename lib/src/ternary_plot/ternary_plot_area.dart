import 'package:flutter/material.dart';
import 'package:ternary_plot/ternary_plot.dart';

/// {@template ternary_plot_area}
/// The base class used to paint areas in [TernaryPlot].
///
/// See Also [TernaryPlotAreaWithTitle] for helpful text painter implementation.
/// Check out [SolidTernaryPlotArea] and [OutlinedTernaryPlotArea] for concrete
/// implementations of this class.
/// {@endtemplate}
abstract class TernaryPlotArea {
  /// {@macro ternary_plot_area}
  const TernaryPlotArea({required this.points});

  /// The vertices of the Area covered in [TernaryPlot].
  ///
  /// The last and first [TernaryPoint] are implicitly closed off.
  /// i.e. if the [points] equals [a, b, c, d], the area is the polygon from
  /// a-b, b-c, c-d, and d-a.
  final List<TernaryPoint> points;

  /// Defines how to paint the area represented by [points].
  void paint(
    Canvas canvas,
    EquilateralTriangle triangle,
    TextStyle defaultTextStyle,
    TextDirection textDirection,
  );
}

/// {@template ternary_plot_area_with_title}
/// Helper base class to create [TernaryPlotArea] with optional area title/label
/// support.
///
/// Use of [defaultTitleTextPainter] provided with this class during [paint]
/// is recommended.
/// {@endtemplate}
abstract class TernaryPlotAreaWithTitle extends TernaryPlotArea {
  /// {@macro ternary_plot_area_with_title}
  const TernaryPlotAreaWithTitle({
    required super.points,
    this.title,
    this.titleStyle,
    this.titlePosition,
  });

  /// Optional title for what the area in [TernaryPlot] represents.
  final String? title;

  /// Title TextStyle.
  final TextStyle? titleStyle;

  /// Represents where to position the [title] text.
  ///
  /// If null, title is placed at the center of Rectangle that covers the given
  /// area.
  final TernaryPoint? titlePosition;

  void defaultTitleTextPainter(
    Canvas canvas,
    EquilateralTriangle triangle,
    TextStyle titleStyle,
    TextDirection textDirection,
  ) {
    if (title == null) {
      return;
    }
    final rect = triangle.getAreaPath(points: points).getBounds();
    final offset = switch (titlePosition) {
      final titlePosition? => triangle.correctedPosition(point: titlePosition),
      null => Offset(rect.left + rect.width / 2, rect.top + rect.height / 2),
    };

    final textPainter = TextPainter(
      text: TextSpan(text: title, style: titleStyle),
      textDirection: textDirection,
      textAlign: TextAlign.center,
    )..layout();
    final textPosition =
        offset - Offset(textPainter.width / 2, textPainter.height / 2);
    textPainter
      ..paint(canvas, textPosition)
      ..dispose();
  }
}

/// {@template solid_ternary_plot_area}
/// Paints the entire area enclosed by [points] in given [color].
///
/// If [title] is provided without [titleStyle], a default text style of the
/// black or white color based on brightness of given [color] is used instead.
/// {@endtemplate}
class SolidTernaryPlotArea extends TernaryPlotAreaWithTitle {
  /// {@macro solid_ternary_plot_area}
  const SolidTernaryPlotArea({
    required super.points,
    required this.color,
    super.title,
    super.titleStyle,
    super.titlePosition,
  });

  /// [SolidTernaryPlotArea] for the top triangle, when the equilateral triangle
  /// is divided into 4 equal equilateral triangles.
  factory SolidTernaryPlotArea.top({
    required Color color,
    String? title,
    TextStyle? titleStyle,
    TernaryPoint? titlePosition,
  }) {
    return SolidTernaryPlotArea(
      points: const [
        TernaryPoint(a: 0, b: 0, c: 2),
        TernaryPoint(a: 0, b: 1, c: 1),
        TernaryPoint(a: 1, b: 0, c: 1),
      ],
      color: color,
      title: title,
      titleStyle: titleStyle,
      titlePosition: titlePosition ?? const TernaryPoint(a: 1, b: 1, c: 4),
    );
  }

  /// [SolidTernaryPlotArea] for the bottom left triangle, when the equilateral
  /// triangle is divided into 4 equal equilateral triangles.
  factory SolidTernaryPlotArea.bottomLeft({
    required Color color,
    String? title,
    TextStyle? titleStyle,
    TernaryPoint? titlePosition,
  }) {
    return SolidTernaryPlotArea(
      points: const [
        TernaryPoint(a: 2, b: 0, c: 0),
        TernaryPoint(a: 1, b: 1, c: 0),
        TernaryPoint(a: 1, b: 0, c: 1),
      ],
      color: color,
      title: title,
      titleStyle: titleStyle,
      titlePosition: titlePosition ?? const TernaryPoint(a: 4, b: 1, c: 1),
    );
  }

  /// [SolidTernaryPlotArea] for the bottom right triangle, when the equilateral
  /// triangle is divided into 4 equal equilateral triangles.
  factory SolidTernaryPlotArea.bottomRight({
    required Color color,
    String? title,
    TextStyle? titleStyle,
    TernaryPoint? titlePosition,
  }) {
    return SolidTernaryPlotArea(
      points: const [
        TernaryPoint(a: 0, b: 2, c: 0),
        TernaryPoint(a: 0, b: 1, c: 1),
        TernaryPoint(a: 1, b: 1, c: 0),
      ],
      color: color,
      title: title,
      titleStyle: titleStyle,
      titlePosition: titlePosition ?? const TernaryPoint(a: 1, b: 4, c: 1),
    );
  }

  /// [SolidTernaryPlotArea] for the inverted central triangle, when the
  /// equilateral triangle is divided into 4 equal equilateral triangles.
  factory SolidTernaryPlotArea.center({
    required Color color,
    String? title,
    TextStyle? titleStyle,
    TernaryPoint? titlePosition,
  }) {
    return SolidTernaryPlotArea(
      points: const [
        TernaryPoint(a: 1, b: 1, c: 0),
        TernaryPoint(a: 0, b: 1, c: 1),
        TernaryPoint(a: 1, b: 0, c: 1),
      ],
      color: color,
      title: title,
      titleStyle: titleStyle,
      titlePosition: titlePosition ?? const TernaryPoint(a: 1, b: 1, c: 1),
    );
  }

  /// The color to paint the Area with
  final Color color;

  @override
  void paint(
    Canvas canvas,
    EquilateralTriangle triangle,
    TextStyle defaultTextStyle,
    TextDirection textDirection,
  ) {
    final areaPaint = Paint()..color = color;
    final areaPath = triangle.getAreaPath(points: points);
    canvas.drawPath(areaPath, areaPaint);

    defaultTitleTextPainter(
      canvas,
      triangle,
      titleStyle ??
          defaultTextStyle.copyWith(
            color: _getColorForBrightness(
              ThemeData.estimateBrightnessForColor(color),
            ),
          ),
      textDirection,
    );
  }
}

/// {@template outlined_ternary_plot_area}
/// Paints the outline of the area enclosed by [points] in given [color].
///
/// If [title] is provided without [titleStyle], a default text style of the
/// given outline [color] is used instead.
/// {@endtemplate}
class OutlinedTernaryPlotArea extends TernaryPlotAreaWithTitle {
  /// {@macro outlined_ternary_plot_area}
  const OutlinedTernaryPlotArea({
    required super.points,
    required this.color,
    this.thickness = 1,
    super.title,
    super.titlePosition,
    super.titleStyle,
  });

  /// The outline color for this area.
  final Color color;

  /// The thickness of the outline.
  final double thickness;

  @override
  void paint(
    Canvas canvas,
    EquilateralTriangle triangle,
    TextStyle defaultTextStyle,
    TextDirection textDirection,
  ) {
    final areaPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..color = color;
    final areaPath = triangle.getAreaPath(points: points);
    canvas.drawPath(areaPath, areaPaint);

    defaultTitleTextPainter(
      canvas,
      triangle,
      titleStyle ?? defaultTextStyle.copyWith(color: color),
      textDirection,
    );
  }
}

Color _getColorForBrightness(Brightness brightness) {
  return switch (brightness) {
    Brightness.dark => const Color(0xFFFFFFFF),
    Brightness.light => const Color(0xFF000000),
  };
}
