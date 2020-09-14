import 'package:flutter/material.dart';

class LineChartPainter extends CustomPainter {
  final List<List> data;
  final double width;
  final double height;
  final Function(Canvas, Size) customDraw;
  final Paint linePaint;
  final Paint circlePaint;
  final bool showCircles;
  final double radiusValue;
  final Paint insideCirclePaint;

  LineChartPainter(
    this.data,
    this.width,
    this.height,
    this.linePaint,
    this.circlePaint, {
    this.customDraw,
    this.showCircles = true,
    this.radiusValue = 6,
    this.insideCirclePaint,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (customDraw != null) {
      customDraw(canvas, size);
    }

    data.forEach((value) {
      final currentIndex = data.indexOf(value);

      Path path = Path();

      path.moveTo(value[0].dx, value[0].dy);

      if (data.last == value) {
        path.lineTo(size.width, value[0].dy);
      } else {
        path.lineTo(data[currentIndex + 1][0].dx, data[currentIndex + 1][0].dy);
      }

      canvas.drawPath(path, linePaint);

      if (showCircles) {
        canvas.drawCircle(value[0], radiusValue, circlePaint);
        canvas.drawCircle(
          value[0],
          radiusValue - radiusValue / 2,
          insideCirclePaint != null ? insideCirclePaint : circlePaint,
        );
      }
    });
  }

  @override
  bool shouldRepaint(CustomPainter old) {
    return true;
  }
}
