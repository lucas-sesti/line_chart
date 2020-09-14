import 'package:flutter/material.dart';
import 'package:line_chart/charts/line-chart.widget.dart';
import 'package:line_chart/model/line-chart.model.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<LineChartModel> data = [
    LineChartModel(amount: 100, date: DateTime(2020, 1, 1)),
    LineChartModel(amount: 200, date: DateTime(2020, 1, 2)),
    LineChartModel(amount: 300, date: DateTime(2020, 1, 3)),
    LineChartModel(amount: 500, date: DateTime(2020, 1, 4)),
    LineChartModel(amount: 800, date: DateTime(2020, 1, 5)),
    LineChartModel(amount: 200, date: DateTime(2020, 1, 6)),
    LineChartModel(amount: 120, date: DateTime(2020, 1, 7)),
    LineChartModel(amount: 140, date: DateTime(2020, 1, 8)),
    LineChartModel(amount: 110, date: DateTime(2020, 1, 9)),
    LineChartModel(amount: 250, date: DateTime(2020, 1, 10)),
    LineChartModel(amount: 390, date: DateTime(2020, 1, 11)),
    LineChartModel(amount: 1300, date: DateTime(2020, 1, 12)),
  ];

  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      data = [
        LineChartModel(amount: 500, date: DateTime(2020, 1, 4)),
        LineChartModel(amount: 200, date: DateTime(2020, 1, 2)),
        LineChartModel(amount: 200, date: DateTime(2020, 1, 6)),
        LineChartModel(amount: 800, date: DateTime(2020, 1, 5)),
        LineChartModel(amount: 1300, date: DateTime(2020, 1, 12)),
        LineChartModel(amount: 300, date: DateTime(2020, 1, 3)),
        LineChartModel(amount: 120, date: DateTime(2020, 1, 7)),
        LineChartModel(amount: 250, date: DateTime(2020, 1, 10)),
        LineChartModel(amount: 140, date: DateTime(2020, 1, 8)),
        LineChartModel(amount: 100, date: DateTime(2020, 1, 1)),
        LineChartModel(amount: 110, date: DateTime(2020, 1, 9)),
        LineChartModel(amount: 390, date: DateTime(2020, 1, 11)),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    Paint circlePaint = Paint()..color = Colors.black;

    Paint insideCirclePaint = Paint()..color = Colors.white;

    Paint linePaint = Paint()
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..color = Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: Text('Line Chart Showcase'),
      ),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: ListView(
          children: [
            // First chart
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Line chart - Line, Circles, Pointer',
                  style: Theme.of(context).textTheme.headline5,
                ),
                LineChart(
                  width: MediaQuery.of(context).size.width,
                  height: 180,
                  data: data,
                  linePaint: linePaint,
                  circlePaint: circlePaint,
                  showPointer: true,
                  showCircles: true,
                  customDraw: (Canvas canvas, Size size) {},
                  linePointerDecoration: BoxDecoration(
                    color: Colors.black,
                  ),
                  pointerDecoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black,
                  ),
                  insideCirclePaint: insideCirclePaint,
                  onValuePointer: (LineChartModel value) {
                    print('onValuePointer');
                  },
                  onDropPointer: () {
                    print('onDropPointer');
                  },
                ),
              ],
            ),

            // Second Chart
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Line chart - Line, Pointer',
                    style: Theme.of(context).textTheme.headline5,
                  ),
                  LineChart(
                    width: MediaQuery.of(context).size.width,
                    height: 180,
                    data: data,
                    linePaint: linePaint,
                    circlePaint: circlePaint,
                    showPointer: true,
                    showCircles: false,
                    customDraw: (Canvas canvas, Size size) {},
                    linePointerDecoration: BoxDecoration(
                      color: Colors.black,
                    ),
                    pointerDecoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black,
                    ),
                    insideCirclePaint: insideCirclePaint,
                    onValuePointer: (LineChartModel value) {
                      print('onValuePointer');
                    },
                    onDropPointer: () {
                      print('onDropPointer');
                    },
                  ),
                ],
              ),
            ),

            // Third chart
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Line chart - Line',
                  style: Theme.of(context).textTheme.headline5,
                ),
                LineChart(
                  width: MediaQuery.of(context).size.width,
                  height: 180,
                  data: data,
                  linePaint: linePaint,
                  circlePaint: circlePaint,
                  showPointer: false,
                  showCircles: false,
                  customDraw: (Canvas canvas, Size size) {},
                  linePointerDecoration: BoxDecoration(
                    color: Colors.black,
                  ),
                  pointerDecoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black,
                  ),
                  insideCirclePaint: insideCirclePaint,
                  onValuePointer: (LineChartModel value) {
                    print('onValuePointer');
                  },
                  onDropPointer: () {
                    print('onDropPointer');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
