import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:ternary_plot/ternary_plot.dart';

typedef DataToPoint<T> = Map<T, TernaryPoint>;
typedef ChildBuilder<T> = Widget Function(T value);

class TernaryPlotData<T> extends Equatable {
  const TernaryPlotData({
    required this.data,
    required this.builder,
  });

  final DataToPoint<T> data;
  final ChildBuilder<T> builder;

  List<Widget> get children {
    return data.keys
        .map(
          (key) => KeyedSubtree(
            key: ValueKey(key),
            child: builder(key),
          ),
        )
        .toList();
  }

  @override
  List<Object> get props => [data, builder];
}

class TernaryPlotArea extends Equatable {
  const TernaryPlotArea({
    required this.points,
    required this.color,
    this.title,
    this.titleStyle,
    this.titlePosition,
  });

  /// [TernaryPlotArea] for the top triangle, when the equilateral triangle
  /// is divided into 4 equal equilateral triangles.
  factory TernaryPlotArea.top({
    required Color color,
    String? title,
    TextStyle? titleStyle,
    TernaryPoint? titlePosition,
  }) {
    return TernaryPlotArea(
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

  /// [TernaryPlotArea] for the bottom left triangle, when the equilateral
  /// triangle is divided into 4 equal equilateral triangles.
  factory TernaryPlotArea.bottomLeft({
    required Color color,
    String? title,
    TextStyle? titleStyle,
    TernaryPoint? titlePosition,
  }) {
    return TernaryPlotArea(
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

  /// [TernaryPlotArea] for the bottom right triangle, when the equilateral
  /// triangle is divided into 4 equal equilateral triangles.
  factory TernaryPlotArea.bottomRight({
    required Color color,
    String? title,
    TextStyle? titleStyle,
    TernaryPoint? titlePosition,
  }) {
    return TernaryPlotArea(
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

  /// [TernaryPlotArea] for the inverted central triangle, when the
  /// equilateral triangle is divided into 4 equal equilateral triangles.
  factory TernaryPlotArea.center({
    required Color color,
    String? title,
    TextStyle? titleStyle,
    TernaryPoint? titlePosition,
  }) {
    return TernaryPlotArea(
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

  /// The vertices of the Area covered in [TernaryPlot].
  ///
  /// The last and first [TernaryPoint] are implicitly closed off.
  /// i.e. if the [points] equals [a, b, c, d], the area is the polygon from
  /// a-b, b-c, c-d, and d-a.
  final List<TernaryPoint> points;

  /// The color to paint the Area with
  final Color color;

  /// Optional title for what the area in [TernaryPlot] represents.
  final String? title;

  /// Title TextStyle.
  final TextStyle? titleStyle;

  /// Represents where to position the [title] text.
  ///
  /// If null, title is placed at the center of Rectangle that covers the given
  /// area.
  final TernaryPoint? titlePosition;

  @override
  List<Object?> get props => [title, titleStyle, titlePosition, color, points];
}
