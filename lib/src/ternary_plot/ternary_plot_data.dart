import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:ternary_plot/ternary_plot.dart';

typedef DataToPoint<T> = Map<T, TernaryPoint>;
typedef ChildBuilder<T> = Widget Function(T value);

class TernaryPlotData<T> extends Equatable {
  TernaryPlotData({required this.data, required this.builder});

  final DataToPoint<T> data;
  final ChildBuilder<T> builder;

  late final List<Widget> children = data.keys
      .map((key) => KeyedSubtree(key: ValueKey(key), child: builder(key)))
      .toList();

  @override
  List<Object> get props => [data, builder];
}
