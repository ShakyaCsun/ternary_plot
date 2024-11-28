import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:ternary_plot/src/extensions/map_extensions.dart';
import 'package:ternary_plot/ternary_plot.dart';

typedef PointsHitCallback<T> = void Function(List<T> points);

/// {@template ternary_plot}
/// Create ternary/triangle plot
/// {@endtemplate}
class TernaryPlot<T> extends MultiChildRenderObjectWidget {
  /// {@macro ternary_plot}
  TernaryPlot({
    required this.plotData,
    this.settings = const TernaryPlotSettings(),
    this.areas,
    this.onPointTap,
    this.onPointHovered,
    this.offsetChildrenAtSamePoint = true,
    super.key,
  }) : super(children: plotData.children);

  final TernaryPlotData<T> plotData;
  final TernaryPlotSettings settings;
  final List<TernaryPlotArea>? areas;

  /// Callback for Points that are tapped.
  ///
  /// This is guaranteed to contain a point [T] that was tapped unlike
  /// [onPointHovered]
  final PointsHitCallback<T>? onPointTap;

  /// Callback for Points that are hovered
  ///
  /// The [List<T>] can be empty to denote hover exit.
  final PointsHitCallback<T>? onPointHovered;

  /// Slightly Offset children sharing same [TernaryPoint].
  ///
  /// Defaults to `true`. Note: Might cause issues if the children are of
  /// different sizes.
  final bool offsetChildrenAtSamePoint;

  @override
  RenderTernaryPlot<T> createRenderObject(BuildContext context) {
    return RenderTernaryPlot(
      plotData: plotData,
      settings: settings,
      areas: areas,
      onPointTap: onPointTap,
      onPointHovered: onPointHovered,
      offsetChildren: offsetChildrenAtSamePoint,
    )..configureDefaultTextStyles(context);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderTernaryPlot<T> renderObject,
  ) {
    renderObject
      ..configureDefaultTextStyles(context)
      ..offsetChildren = offsetChildrenAtSamePoint
      ..plotData = plotData
      ..settings = settings
      ..areas = areas
      ..onPointTap = onPointTap
      ..onPointHovered = onPointHovered;
  }
}

class TernaryPlotParentData extends ContainerBoxParentData<RenderBox> {}

class RenderTernaryPlot<T> extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, TernaryPlotParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, TernaryPlotParentData> {
  RenderTernaryPlot({
    required TernaryPlotData<T> plotData,
    required TernaryPlotSettings settings,
    List<TernaryPlotArea>? areas,
    PointsHitCallback<T>? onPointTap,
    PointsHitCallback<T>? onPointHovered,
    bool offsetChildren = true,
  })  : _offsetChildren = offsetChildren,
        _plotData = plotData,
        _settings = settings,
        _areas = areas,
        _onPointTap = onPointTap,
        _onPointHovered = onPointHovered {
    _hoveredPoints.addListener(_hoveredPointCallback);
  }

  TernaryPlotData<T> get plotData => _plotData;
  TernaryPlotData<T> _plotData;
  set plotData(TernaryPlotData<T> value) {
    if (value == _plotData) {
      return;
    }
    if (!mapEquals(value.data, _plotData.data)) {
      _alignments = _getAlignments(value.data, offsetChildren);
    }
    _plotData = value;
    markNeedsPaint();
  }

  TernaryPlotSettings get settings => _settings;
  TernaryPlotSettings _settings;
  set settings(TernaryPlotSettings value) {
    if (value == _settings) {
      return;
    }
    if (value.ternaryLabels != _settings.ternaryLabels) {
      final ternaryLabels = value.ternaryLabels;
      if (ternaryLabels != null) {
        _topLabelPainter.text = TextSpan(
          text: ternaryLabels.topLabel,
          style: ternaryLabels.topLabelStyle ?? _defaultLabelStyle,
        );
        _leftLabelPainter.text = TextSpan(
          text: ternaryLabels.leftLabel,
          style: ternaryLabels.leftLabelStyle ?? _defaultLabelStyle,
        );
        _rightLabelPainter.text = TextSpan(
          text: ternaryLabels.rightLabel,
          style: ternaryLabels.rightLabelStyle ?? _defaultLabelStyle,
        );
      }
    }
    _settings = value;
    markNeedsPaint();
  }

  List<TernaryPlotArea>? get areas => _areas;
  List<TernaryPlotArea>? _areas;
  set areas(List<TernaryPlotArea>? value) {
    if (listEquals(value, _areas)) {
      return;
    }
    _areas = value;
    markNeedsPaint();
  }

  bool get offsetChildren => _offsetChildren;
  bool _offsetChildren;
  set offsetChildren(bool value) {
    if (value == _offsetChildren) {
      return;
    }
    _offsetChildren = value;
    markNeedsPaint();
  }

  PointsHitCallback<T>? get onPointTap => _onPointTap;
  PointsHitCallback<T>? _onPointTap;
  set onPointTap(PointsHitCallback<T>? value) {
    if (value == _onPointTap) {
      return;
    }
    _onPointTap = value;
  }

  PointsHitCallback<T>? get onPointHovered => _onPointHovered;
  PointsHitCallback<T>? _onPointHovered;
  set onPointHovered(PointsHitCallback<T>? value) {
    if (value == _onPointHovered) {
      return;
    }
    _onPointHovered = value;
  }

  double get _padding {
    return max(settings.minPadding, 0.1 * min(size.width, size.height));
  }

  EquilateralTriangle get triangle => _triangle;
  EquilateralTriangle _triangle = EquilateralTriangle.zero;
  set triangle(EquilateralTriangle value) {
    if (value == _triangle) {
      return;
    }
    _triangle = value;
  }

  final ValueListNotifier<T> _hoveredPoints = ValueListNotifier([]);

  void _hoveredPointCallback() {
    _onPointHovered?.call(_hoveredPoints.value);
  }

  final ValueListNotifier<T> _tappedPoints = ValueListNotifier([]);

  void _onTap() {
    _onPointTap?.call(_tappedPoints.value);
  }

  void configureDefaultTextStyles(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    defaultLabelStyle = textTheme.headlineMedium;
    defaultAreaTitleStyle = textTheme.labelLarge;
    textDirection = Directionality.of(context);
    final textColor = _getColorForBrightness(Theme.of(context).brightness);
    defaultLabelStyle = defaultLabelStyle.copyWith(
      color: defaultLabelStyle.color ?? textColor,
    );
    defaultAreaTitleStyle = defaultAreaTitleStyle.copyWith(
      color: defaultLabelStyle.color ?? textColor,
    );
  }

  TextStyle get defaultLabelStyle => _defaultLabelStyle;
  TextStyle _defaultLabelStyle = const TextStyle(fontSize: 14);
  set defaultLabelStyle(TextStyle? value) {
    if (value == _defaultLabelStyle) {
      return;
    }
    if (value == null) {
      return;
    }
    _defaultLabelStyle = value;
  }

  TextStyle get defaultAreaTitleStyle => _defaultAreaTitleStyle;
  TextStyle _defaultAreaTitleStyle = const TextStyle(fontSize: 14);
  set defaultAreaTitleStyle(TextStyle? value) {
    if (value == _defaultAreaTitleStyle) {
      return;
    }
    if (value == null) {
      return;
    }
    _defaultAreaTitleStyle = value;
  }

  TextDirection get textDirection => _textDirection;
  TextDirection _textDirection = TextDirection.ltr;
  set textDirection(TextDirection value) {
    if (value == _textDirection) {
      return;
    }
    _textDirection = value;
  }

  late final TextPainter _topLabelPainter = TextPainter(
    text: TextSpan(
      text: settings.ternaryLabels?.topLabel,
      style: settings.ternaryLabels?.topLabelStyle ?? _defaultLabelStyle,
    ),
    textDirection: textDirection,
    textAlign: TextAlign.center,
  );
  late final TextPainter _leftLabelPainter = TextPainter(
    text: TextSpan(
      text: settings.ternaryLabels?.leftLabel,
      style: settings.ternaryLabels?.leftLabelStyle ?? _defaultLabelStyle,
    ),
    textDirection: textDirection,
    textAlign: TextAlign.center,
  );
  late final TextPainter _rightLabelPainter = TextPainter(
    text: TextSpan(
      text: settings.ternaryLabels?.rightLabel,
      style: settings.ternaryLabels?.rightLabelStyle ?? _defaultLabelStyle,
    ),
    textDirection: textDirection,
    textAlign: TextAlign.center,
  );

  late final TapGestureRecognizer _tapGestureRecognizer;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _tapGestureRecognizer = TapGestureRecognizer(debugOwner: this)
      ..onTap = _onTap;
  }

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! TernaryPlotParentData) {
      child.parentData = TernaryPlotParentData();
    }
  }

  // LAYOUT

  @override
  bool get sizedByParent => true;

  @override
  Size computeDryLayout(covariant BoxConstraints constraints) {
    if (constraints.hasBoundedWidth && !constraints.hasBoundedHeight) {
      return Size(constraints.maxWidth, constraints.maxWidth);
    }
    if (!constraints.hasBoundedWidth && constraints.hasBoundedHeight) {
      return Size(constraints.maxHeight, constraints.maxHeight);
    }
    return constraints.biggest;
  }

  @override
  void performLayout() {
    triangle = EquilateralTriangle(padding: _padding, availableSize: size);
    if (!canPaintLabels(settings.minPadding)) {
      triangle = EquilateralTriangle(
        padding: settings.minPadding,
        availableSize: size,
      );
    }
    // Children are allowed to be as big as they want (= unconstrained).
    const childConstraints = BoxConstraints();
    _childrenSizes.clear();

    var child = firstChild;
    for (final slot in _plotData.data.keys) {
      child?.layout(childConstraints, parentUsesSize: true);
      _positionChild(
        child!,
        calculateChildPosition(
          point: _plotData.data[slot]!,
          childSize: child.size,
          alignment: _alignments[slot],
        ),
      );
      _childrenSizes[slot] = child.size;
      child = (child.parentData as TernaryPlotParentData?)?.nextSibling;
    }
  }

  late Map<T, Alignment> _alignments = _getAlignments(
    _plotData.data,
    offsetChildren,
  );

  Offset calculateChildPosition({
    required TernaryPoint point,
    required Size childSize,
    Alignment? alignment,
  }) {
    final pointOffset = triangle.correctedPosition(point: point);
    return pointOffset - (alignment ?? Alignment.center).alongSize(childSize);
  }

  void _positionChild(RenderBox child, Offset offset) {
    (child.parentData! as BoxParentData).offset = offset;
  }

  bool canPaintLabels(double padding) {
    final TernaryPlotSettings(:ternaryLabels) = settings;
    if (ternaryLabels == null) {
      return false;
    }
    final (maxWidth, maxHeight) = (
      size.width / 2 - padding * 4,
      _triangle.C.dy - padding * 1.2,
    );
    _topLabelPainter.layout(maxWidth: maxWidth);
    _leftLabelPainter.layout(maxWidth: maxWidth);
    _rightLabelPainter.layout(maxWidth: maxWidth);
    return _topLabelPainter.height <= maxHeight &&
        _leftLabelPainter.height <= maxHeight &&
        _rightLabelPainter.height <= maxHeight;
  }

  /// The [Size] of children; calculated during performLayout, used during paint
  final Map<T, Size> _childrenSizes = {};

  // PAINT

  @override
  void paint(PaintingContext context, Offset offset) {
    final TernaryPlotSettings(
      :gridLines,
      :gridLineColor,
      :lineColor,
      :minPadding,
      :ternaryLabels,
    ) = settings;

    final canvas = context.canvas
      ..save()
      ..translate(offset.dx, offset.dy);

    // Doesn't actually paint labels if size doesn't allow or
    // if there are no labels
    paintLabels(canvas, minPadding);

    for (final area in _areas ?? <TernaryPlotArea>[]) {
      final TernaryPlotArea(
        :points,
        :color,
        :title,
        :titleStyle,
        :titlePosition
      ) = area;
      final areaPaint = Paint()..color = color;
      final areaPath = triangle.getAreaPath(points: points);
      canvas.drawPath(areaPath, areaPaint);

      if (title != null) {
        final rect = areaPath.getBounds();
        final offset = titlePosition != null
            ? triangle.correctedPosition(point: titlePosition)
            : Offset(
                rect.left + rect.width / 2,
                rect.top + rect.height / 2,
              );

        final textPainter = TextPainter(
          text: TextSpan(
            text: title,
            style: titleStyle ??
                defaultAreaTitleStyle.copyWith(
                  color: _getColorForBrightness(
                    ThemeData.estimateBrightnessForColor(color),
                  ),
                ),
          ),
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

    if (gridLines > 0) {
      final gridLinePaint = Paint()
        ..color =
            gridLineColor ?? (lineColor ?? Colors.white).withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke;

      for (var i = 0; i < gridLines; i++) {
        final one = i.toDouble();
        final two = (gridLines - i).toDouble();

        final area = triangle.getAreaPath(
          points: [
            TernaryPoint(a: two, b: one, c: 0),
            TernaryPoint(a: 0, b: one, c: two),
            TernaryPoint(a: one, b: 0, c: two),
            TernaryPoint(a: one, b: two, c: 0),
          ],
          close: i == 0,
        );
        canvas.drawPath(area, gridLinePaint);
      }
    }

    if (lineColor != null) {
      final linePaint = Paint()
        ..color = lineColor
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      canvas.drawPath(triangle.path, linePaint);
    }

    // Restore to original canvas before offset translation
    canvas.restore();

    // PAINT CHILDREN

    defaultPaint(context, offset);
  }

  void paintLabels(Canvas canvas, double padding) {
    if (!canPaintLabels(padding)) return;

    _topLabelPainter.paint(
      canvas,
      _triangle.C -
          Offset(
            _topLabelPainter.width / 2,
            _topLabelPainter.height + padding,
          ),
    );
    if ([_leftLabelPainter.width, _rightLabelPainter.width]
        .every((element) => element < _triangle.A.dx - padding * 2)) {
      _leftLabelPainter.paint(
        canvas,
        _triangle.A -
            Offset(
              _leftLabelPainter.width + 2 * padding,
              _leftLabelPainter.height / 2,
            ),
      );
      _rightLabelPainter.paint(
        canvas,
        _triangle.B + Offset(padding, -_rightLabelPainter.height / 2),
      );
    } else {
      _leftLabelPainter.paint(
        canvas,
        Offset(
          max(padding, _triangle.A.dx - _leftLabelPainter.width / 2),
          _triangle.A.dy + padding,
        ),
      );
      _rightLabelPainter.paint(
        canvas,
        Offset(
          min(
            size.width - _rightLabelPainter.width - padding,
            _triangle.B.dx - _rightLabelPainter.width / 2,
          ),
          _triangle.B.dy + padding,
        ),
      );
    }
  }

  @override
  bool hitTestSelf(Offset position) {
    return size.contains(position);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void handleEvent(PointerEvent event, covariant BoxHitTestEntry entry) {
    assert(debugHandleEvent(event, entry), 'Support debugPaintPointersEnabled');
    var child = lastChild;
    final pointsAtOffset = <T>[];
    for (final point in _plotData.data.keys.toList().reversed) {
      final childParentData = child!.parentData! as TernaryPlotParentData;
      final isHit = child.hitTest(
        BoxHitTestResult(),
        position: entry.localPosition - childParentData.offset,
      );
      if (isHit) {
        pointsAtOffset.add(point);
      }
      child = childParentData.previousSibling;
    }
    if (onPointTap != null && event is PointerDownEvent) {
      if (pointsAtOffset.isNotEmpty) {
        _tappedPoints.value = pointsAtOffset;
        _tapGestureRecognizer.addPointer(event);
      }
    }
    if (onPointHovered != null && event is PointerHoverEvent) {
      _hoveredPoints.value = pointsAtOffset;
    }
  }

  @override
  void dispose() {
    _topLabelPainter.dispose();
    _leftLabelPainter.dispose();
    _rightLabelPainter.dispose();
    _hoveredPoints.dispose();
    _tappedPoints.dispose();
    _tapGestureRecognizer.dispose();
    super.dispose();
  }
}

Map<T, Alignment> _getAlignments<T>(
  Map<T, TernaryPoint> data,
  bool offsetChildren,
) {
  if (!offsetChildren) {
    return {};
  }
  final pointChildIds = data.swapKV;
  const half = 0.5;
  const align2 = [
    Alignment(half, 0),
    Alignment(-half, 0),
  ];
  const align3 = [
    Alignment(half, 0.25),
    Alignment(-half, 0.25),
    Alignment(0, -0.25),
  ];
  const alignMore = [
    Alignment.center,
    Alignment(0, -0.25),
    Alignment(half, 0.25),
    Alignment(-half, 0.25),
  ];
  return pointChildIds.entries.fold(
    <T, Alignment>{},
    (previousValue, element) {
      final MapEntry(key: point, value: childIds) = element;
      if (childIds.length <= 1) {
        return previousValue;
      }

      switch (childIds) {
        case [final child1, final child2]:
          previousValue[child1] = align2[0];
          previousValue[child2] = align2[1];
        case [final child1, final child2, final child3]:
          previousValue[child1] = align3[0];
          previousValue[child2] = align3[1];
          previousValue[child3] = align3[2];
        default:
          for (final (i, childId) in childIds.indexed) {
            previousValue[childId] = alignMore[i % alignMore.length];
          }
          return previousValue;
      }
      return previousValue;
    },
  );
}

Color _getColorForBrightness(Brightness brightness) {
  return switch (brightness) {
    Brightness.dark => const Color(0xFFFFFFFF),
    Brightness.light => const Color(0xFF000000)
  };
}
