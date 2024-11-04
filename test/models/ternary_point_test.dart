import 'package:flutter_test/flutter_test.dart';
import 'package:ternary_plot/ternary_plot.dart';

void main() {
  group('TernaryPoint', () {
    group('.compareTo works correctly', () {
      test(
        'when xyPoint is same',
        () {
          const pointA = TernaryPoint(a: 1, b: 0, c: 0);
          const pointB = TernaryPoint(a: 2, b: 0, c: 0);
          expect(
            pointA.compareTo(pointB),
            equals(0),
          );
        },
      );

      test(
        'when y-axis for point A is less than point B',
        () {
          const pointA = TernaryPoint(a: 1, b: 1, c: 1);
          const pointB = TernaryPoint(a: 0, b: 0, c: 1);
          final (x1, y1) = pointA.xyPoint;
          final (x2, y2) = pointB.xyPoint;
          expect(x1, equals(x2));
          expect(y1, lessThan(y2));
          expect(
            pointA.compareTo(pointB),
            isPositive,
          );
          expect(
            pointB.compareTo(pointA),
            isNegative,
          );
        },
      );

      test(
        'when x-axis for point A is less than point B',
        () {
          const pointA = TernaryPoint(a: 1, b: 0, c: 1);
          const pointB = TernaryPoint(a: 0, b: 1, c: 1);
          final (x1, y1) = pointA.xyPoint;
          final (x2, y2) = pointB.xyPoint;
          expect(y1, equals(y2));
          expect(x1, lessThan(x2));
          expect(
            pointA.compareTo(pointB),
            isNegative,
          );
          expect(
            pointB.compareTo(pointA),
            isPositive,
          );
        },
      );
    });
  });
  group(
    'List of TernaryPoints',
    () {
      test(
        'gets sorted top to bottom and left to right',
        () {
          final points = [
            const TernaryPoint(a: 0, b: 1, c: 0),
            const TernaryPoint(a: 1, b: 1, c: 1),
            const TernaryPoint(a: 1, b: 0, c: 0),
            const TernaryPoint(a: 0, b: 0, c: 1),
          ]..sort();
          const sortedPoints = [
            TernaryPoint(a: 0, b: 0, c: 1),
            TernaryPoint(a: 1, b: 1, c: 1),
            TernaryPoint(a: 1, b: 0, c: 0),
            TernaryPoint(a: 0, b: 1, c: 0),
          ];
          expect(points, equals(sortedPoints));
        },
      );
    },
  );
}
