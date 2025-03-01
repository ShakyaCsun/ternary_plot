import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ternary_plot/ternary_plot.dart';

void main() {
  group('EquilateralTriangle', () {
    group('calculates correct triangle size', () {
      test('when height is smaller', () {
        final triangle = EquilateralTriangle(
          padding: 10,
          availableSize: const Size(100, 60),
        );
        expect(triangle.triangleSize, equals(const Size(2 / sqrt_3 * 40, 40)));
      });
      test('when width is smaller', () {
        final triangle = EquilateralTriangle(
          padding: 10,
          availableSize: const Size(50, 100),
        );
        expect(triangle.triangleSize, equals(const Size(30, sqrt_3by2 * 30)));
      });
      test('when width and height fit perfectly', () {
        const width = 30.0;
        const height = sqrt_3by2 * width;
        final triangle = EquilateralTriangle(
          padding: 0,
          availableSize: const Size(width, height),
        );
        expect(triangle.triangleSize, equals(const Size(width, height)));
      });
      test('when width and height fit perfectly with padding', () {
        const width = 30.0;
        const height = sqrt_3by2 * width;
        const padding = 10.0;
        final triangle = EquilateralTriangle(
          padding: padding,
          availableSize: const Size(width + 2 * padding, height + 2 * padding),
        );
        expect(triangle.triangleSize, equals(const Size(width, height)));
      });
    });
    group('centers Triangle', () {
      const size = Size(1871, 1179);
      final triangle = EquilateralTriangle(
        padding: 0.1 * 1179,
        availableSize: size,
      );
      test('vertically', () {
        final distanceFromBottom = size.height - triangle.A.dy;
        final distanceFromTop = triangle.C.dy;
        expect(distanceFromBottom, moreOrLessEquals(distanceFromTop));
      });
      test('horizontally', () {
        final distanceFromRight = size.width - triangle.B.dx;
        final distanceFromLeft = triangle.A.dx;
        expect(distanceFromLeft, moreOrLessEquals(distanceFromRight));
      });
    });

    group('.correctedPosition', () {
      group('works for TernaryPoint', () {
        final triangle = EquilateralTriangle(
          padding: 10,
          availableSize: const Size(100, 100),
        );
        const pointA = TernaryPoint(a: 100, b: 0, c: 0);
        const pointB = TernaryPoint(a: 0, b: 100, c: 0);
        const pointC = TernaryPoint(a: 0, b: 0, c: 100);
        test('A', () {
          expect(
            triangle.correctedPosition(point: pointA),
            offsetMoreOrLessEquals(triangle.A),
          );
        });
        test('B', () {
          expect(
            triangle.correctedPosition(point: pointB),
            offsetMoreOrLessEquals(triangle.B),
          );
        });
        test('C', () {
          expect(
            triangle.correctedPosition(point: pointC),
            offsetMoreOrLessEquals(triangle.C),
          );
        });
      });
    });
  });
}
