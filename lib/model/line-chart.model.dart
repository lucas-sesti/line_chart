library line_chart;

class LineChartModel {
  DateTime date;
  double amount;

  LineChartModel({
    this.date,
    this.amount,
  });
}

class LineChartModelCallback {
  LineChartModel chart;
  double percentage;

  LineChartModelCallback({
    this.chart,
    this.percentage,
  });
}
