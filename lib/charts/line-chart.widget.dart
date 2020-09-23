import 'package:flutter/material.dart';
import 'package:line_chart/charts/line-chart-painter.widget.dart';
import 'package:line_chart/model/line-chart.model.dart';

class LineChart extends StatefulWidget {
  const LineChart({
    @required this.width,
    @required this.height,
    @required this.data,
    @required this.linePaint,
    this.circlePaint,
    this.showPointer = false,
    this.onValuePointer,
    this.onDropPointer,
    this.customDraw,
    this.insideCirclePaint,
    this.circleRadiusValue = 6,
    this.showCircles = false,
    this.linePointerDecoration,
    this.pointerDecoration,
    this.insidePadding = 8,
  });

  final Function(LineChartModelCallback) onValuePointer;
  final Function(Canvas, Size) customDraw;
  final Function onDropPointer;
  final BoxDecoration pointerDecoration;
  final BoxDecoration linePointerDecoration;
  final double width;
  final double height;
  final double circleRadiusValue;
  final bool showPointer;
  final bool showCircles;
  final Paint linePaint;
  final Paint circlePaint;
  final Paint insideCirclePaint;
  final List<LineChartModel> data;
  final double insidePadding;

  @override
  _LineChartState createState() => _LineChartState();
}

class _LineChartState extends State<LineChart> {
  List<List> offsetsAndValues = [];
  BoxDecoration linePointerDecoration = BoxDecoration(
    color: Colors.black,
  );
  BoxDecoration pointerDecoration = BoxDecoration(
    color: Colors.black,
    shape: BoxShape.circle,
  );
  double x = 0;
  double y = 0;
  double maxValue = 0;
  double minValue = 0;
  bool showPointer = false;
  Paint circlePaint = Paint()..color = Colors.black;
  List<double> percentagesOffsets = [];

  void initState() {
    super.initState();
    maxValue = _getMaxValue();
    minValue = _getMinValue();
    generateOffsets();

    if (widget.linePointerDecoration != null) {
      linePointerDecoration = widget.linePointerDecoration;
    }

    if (widget.pointerDecoration != null) {
      pointerDecoration = widget.pointerDecoration;
    }

    if (widget.circlePaint != null) {
      circlePaint = widget.circlePaint;
    }
  }

  void didUpdateWidget(Widget oldWidget) {
    super.didUpdateWidget(oldWidget);

    setState(() {
      maxValue = _getMaxValue();
      minValue = _getMinValue();
      generateOffsets();

      if (widget.linePointerDecoration != null) {
        linePointerDecoration = widget.linePointerDecoration;
      }

      if (widget.pointerDecoration != null) {
        pointerDecoration = widget.pointerDecoration;
      }
    });
  }

  void generateOffsets() {
    double basePos = widget.width / widget.data.length;
    double next = 0;

    offsetsAndValues = widget.data.map((chart) {
      final Offset circlePosition =
          _getPointPos(next + widget.circleRadiusValue, chart.amount);

      next = next + basePos;
      return [
        circlePosition,
        chart,
      ];
    }).toList();
  }

  double _getMaxValue() {
    return widget.data.fold(0, (previousValue, element) {
      if (element.amount > previousValue) {
        return element.amount;
      }

      return previousValue;
    });
  }

  double _getMinValue() {
    return widget.data.fold(maxValue, (previousValue, element) {
      if (element.amount < previousValue) {
        return element.amount;
      }

      return previousValue;
    });
  }

  Offset _getPointPos(double width, double amount) {
    if (maxValue == 0) {
      return Offset(width, widget.height);
    }

    double percentage = (amount - minValue) / (maxValue - minValue);

    if (percentage.isNaN) {
      percentage = 0.5;
    }

    percentagesOffsets.add(percentage);

    return Offset(
      width - widget.circleRadiusValue * 2,
      widget.height * (1 - percentage),
    );
  }

  int _binarySearchApprox(arr, double value) {
    if (arr.length == 1) return 0;

    var minIndex = 0;
    var maxIndex = arr.length - 1;
    var isAscending = arr[maxIndex][0].dx > arr[minIndex][0].dx;

    while (maxIndex - minIndex > 1) {
      var curIndex = (maxIndex + minIndex) >> 1;

      if (arr[curIndex][0].dx == value) {
        return curIndex;
      }

      if (arr[curIndex][0].dx > value == isAscending) {
        maxIndex = curIndex;
      } else {
        minIndex = curIndex;
      }
    }

    if ((value - arr[minIndex][0].dx).abs() <
        (value - arr[maxIndex][0].dx).abs()) {
      return minIndex;
    }

    return maxIndex;
  }

  void _showDetailsPointer(details) {
    if (widget.showPointer) {
      final int nearestIndex =
          _binarySearchApprox(offsetsAndValues, details.localPosition.dx);

      setState(() {
        x = offsetsAndValues[nearestIndex][0].dx;
        y = offsetsAndValues[nearestIndex][0].dy;

        if (details.localPosition.dx < 0) {
          showPointer = false;
        } else if (details.localPosition.dx > offsetsAndValues.last[0].dx) {
          showPointer = false;
        } else {
          if (widget.onValuePointer != null) {
            widget.onValuePointer(
              LineChartModelCallback(
                chart: offsetsAndValues[nearestIndex][1],
                percentage: percentagesOffsets[nearestIndex] * 100,
              ),
            );
          }

          showPointer = true;
        }
      });
    }
  }

  void _dropPointer(details) {
    if (widget.showPointer) {
      setState(() => showPointer = false);

      if (widget.onDropPointer != null) {
        widget.onDropPointer();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      child: SizedBox(
        width: widget.width,
        height: widget.height + widget.insidePadding,
        child: Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
              onLongPressStart: _showDetailsPointer,
              onLongPressMoveUpdate: _showDetailsPointer,
              onLongPressEnd: _dropPointer,
              onPanUpdate: _showDetailsPointer,
              onPanEnd: _dropPointer,
              child: Container(
                color: Colors.green,
                child: CustomPaint(
                  size: Size(widget.width, widget.height),
                  painter: LineChartPainter(
                    offsetsAndValues,
                    widget.width,
                    widget.height,
                    widget.linePaint,
                    widget.circlePaint,
                    customDraw: widget.customDraw,
                    insideCirclePaint: widget.insideCirclePaint,
                    radiusValue: widget.circleRadiusValue,
                    showCircles: widget.showCircles,
                    insidePadding: widget.insidePadding,
                  ),
                ),
              ),
            ),
            if (widget.showPointer) ...{
              // Line
              Positioned(
                left: x + widget.insidePadding - 1.5,
                top: 0,
                child: AnimatedOpacity(
                  duration: Duration(milliseconds: 200),
                  opacity: showPointer ? 1 : 0,
                  curve: Curves.easeInOut,
                  child: Container(
                    height: widget.height + widget.insidePadding,
                    width: 2,
                    decoration: linePointerDecoration,
                  ),
                ),
              ),

              // Circle
              Positioned(
                left: x + widget.insidePadding - 6.5,
                top: (y - 6) + widget.insidePadding / 2,
                child: AnimatedOpacity(
                  duration: Duration(milliseconds: 200),
                  opacity: showPointer ? 1 : 0,
                  curve: Curves.easeInOut,
                  child: Container(
                    width: widget.circleRadiusValue * 2,
                    height: widget.circleRadiusValue * 2,
                    decoration: pointerDecoration,
                  ),
                ),
              ),
            },
            // if (widget.showLegend) ...{
            //   Padding(
            //     padding: EdgeInsets.only(top: 6),
            //     child: Row(
            //       children: widget.data.map<Widget>((chart) {
            //         return Expanded(
            //           child: Padding(
            //             padding: EdgeInsets.only(top: 6),
            //             child: Text('item'),
            //           ),
            //         );
            //       }).toList(),
            //     ),
            //   ),
            // }
          ],
        ),
      ),
    );
  }
}
