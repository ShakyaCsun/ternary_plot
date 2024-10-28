import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:ternary_plot/ternary_plot.dart';

class TernaryPlotSettings extends Equatable {
  const TernaryPlotSettings({
    this.lineColor,
    this.ternaryLabels,
    this.minPadding = 8,
    this.gridLines = 0,
    this.gridLineColor,
  }) : assert(
          gridLines < 1 || gridLineColor != null || lineColor != null,
          'If gridLines are greater than 0, then either lineColor or '
          'gridLineColor should be provided to draw the lines',
        );

  /// If [ternaryLabels] are null, then no labels are shown.
  ///
  /// If provided, then 10% of available shortestSide is reserved to show the
  /// labels. It is not guaranteed that the labels will be shown as
  /// [TernaryPlot] automatically hides the labels if 10% is not enough.
  final TernaryLabelData? ternaryLabels;

  /// Minimum Padding around Triangle. Default is 8.
  final double minPadding;

  /// Number of minor grid lines to show.
  ///
  /// If this number is 0 or negative, no grid lines are shown.
  /// Default value is 0.
  final int gridLines;

  /// Color of the main Triangle sides.
  final Color? lineColor;

  /// [Color] of grid lines.
  ///
  /// By default, it uses [lineColor] with opacity 0.4
  final Color? gridLineColor;

  @override
  List<Object?> get props {
    return [
      gridLines,
      minPadding,
      lineColor,
      gridLineColor,
      ternaryLabels,
    ];
  }
}

class TernaryLabelData extends Equatable {
  const TernaryLabelData({
    required this.topLabel,
    required this.leftLabel,
    required this.rightLabel,
    this.topLabelStyle,
    this.leftLabelStyle,
    this.rightLabelStyle,
  });

  /// Helper constructor to create a [TernaryLabelData] that has same style for
  /// all Labels
  const TernaryLabelData.sharedStyle({
    required this.topLabel,
    required this.leftLabel,
    required this.rightLabel,
    TextStyle? style,
  })  : topLabelStyle = style,
        leftLabelStyle = style,
        rightLabelStyle = style;

  /// Label for Top vertex of [TernaryPlot]. Corresponds to [TernaryPoint.c]
  final String topLabel;

  /// Label for Left vertex of [TernaryPlot]. Corresponds to [TernaryPoint.a]
  final String leftLabel;

  /// Label for Right vertex of [TernaryPlot]. Corresponds to [TernaryPoint.b]
  final String rightLabel;

  final TextStyle? topLabelStyle;
  final TextStyle? leftLabelStyle;
  final TextStyle? rightLabelStyle;

  @override
  List<Object?> get props {
    return [
      topLabel,
      leftLabel,
      rightLabel,
      topLabelStyle,
      leftLabelStyle,
      rightLabelStyle,
    ];
  }
}
