import 'package:flutter/material.dart';
import 'package:line_chart/charts/time-series-chart-painter.widget.dart';
import 'package:line_chart/model/month-bar-chart.model.dart';

class TimeSeriesChart extends StatefulWidget {
  const TimeSeriesChart({
    @required this.width,
    @required this.height,
    @required this.data,
    @required this.linePaint,
    @required this.circlePaint,
    this.showLegend = false,
    this.showPointer = false,
    this.onValuePointer,
    this.onDropPointer,
    this.customDraw,
    this.insideCirclePaint,
    this.circleRadiusValue = 6,
    this.showCircles = false,
    this.linePointerDecoration,
    this.pointerDecoration,
  });

  final double width;
  final double height;
  final List<MonthChartModel> data;
  final Paint linePaint;
  final bool showPointer;
  final Paint circlePaint;
  final BoxDecoration pointerDecoration;
  final bool showLegend;
  final Function(MonthChartModel) onValuePointer;
  final Function onDropPointer;
  final Function(Canvas, Size) customDraw;
  final Paint insideCirclePaint;
  final double circleRadiusValue;
  final bool showCircles;
  final BoxDecoration linePointerDecoration;

  @override
  _TimeSeriesChartState createState() => _TimeSeriesChartState();
}

class _TimeSeriesChartState extends State<TimeSeriesChart> {
  final double radiusValue = 6;
  BoxDecoration linePointerDecoration = BoxDecoration(
    color: Colors.black,
  );
  BoxDecoration pointerDecoration = BoxDecoration(
    color: Colors.black,
    shape: BoxShape.circle,
  );
  double x = 0;
  double y = 0;
  bool showPointer = false;
  List<List> offsetsAndValues = [];

  double maxValue = 0;
  double minValue = 0;

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
      final Offset circlePosition = _getPointPos(next + 12, chart.amount);

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

    return Offset(
      width - radiusValue * 2,
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
            widget.onValuePointer(offsetsAndValues[nearestIndex][1]);
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
    return SizedBox(
      width: widget.width,
      height: widget.height + 16,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: GestureDetector(
              onLongPressStart: _showDetailsPointer,
              onLongPressMoveUpdate: _showDetailsPointer,
              onLongPressEnd: _dropPointer,
              onPanUpdate: _showDetailsPointer,
              onPanEnd: _dropPointer,
              child: CustomPaint(
                size: Size(widget.width, widget.height),
                painter: TimeSeriesChartPainter(offsetsAndValues, widget.width,
                    widget.height, widget.linePaint, widget.circlePaint,
                    customDraw: widget.customDraw,
                    insideCirclePaint: widget.insideCirclePaint,
                    radiusValue: widget.circleRadiusValue,
                    showCircles: widget.showCircles),
              ),
            ),
          ),
          if (widget.showPointer) ...{
            // Line
            Positioned(
              left: x + 14.5,
              top: 0,
              child: AnimatedOpacity(
                duration: Duration(milliseconds: 200),
                opacity: showPointer ? 1 : 0,
                curve: Curves.easeInOut,
                child: Container(
                  height: widget.height + 16,
                  width: 2,
                  decoration: linePointerDecoration,
                ),
              ),
            ),

            // Circle
            Positioned(
              left: x + 9,
              top: y + 2,
              child: AnimatedOpacity(
                duration: Duration(milliseconds: 200),
                opacity: showPointer ? 1 : 0,
                curve: Curves.easeInOut,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: pointerDecoration,
                ),
              ),
            ),
          },
          if (widget.showLegend) ...{
            Padding(
              padding: EdgeInsets.only(top: 6),
              child: Row(
                children: widget.data.map<Widget>((chart) {
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Text('item'),
                    ),
                  );
                }).toList(),
              ),
            ),
          }
        ],
      ),
    );
  }
}
