import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

// TODO: hard select ranges, range selections (week, month, year)
// TODO: actually populate weights and calories with real stored data
// TODO: add calories (bubbles with size of calories)

class HistoryPage extends StatefulWidget {
  final Color color;

  HistoryPage({this.color});

  @override
  HistoryPageState createState() => HistoryPageState();
}

class HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    var weightData = [
      Weight(DateTime(2019, 6, 20), 182),
      Weight(DateTime(2019, 6, 26), 181.9),
      Weight(DateTime(2019, 6, 29), 184),
      Weight(DateTime(2019, 6, 30), 182),
      Weight(DateTime(2019, 7, 1), 180),
      Weight(DateTime(2019, 7, 2), 182.5),
      Weight(DateTime(2019, 7, 9), 182.5),
      Weight(DateTime(2019, 7, 11), 182.1),
      Weight(DateTime(2019, 7, 17), 182.5),
      Weight(DateTime(2019, 7, 23), 183.4),
    ];
    var CaloriesData = [Calories(DateTime(2019, 7, 22), 140)];
    var series = [
      charts.Series<Weight, DateTime>(
        id: 'Weights',
        colorFn: (_, __) => charts.Color.fromHex(code: '#b2ff59'),
        domainFn: (Weight weightData, _) => weightData.date,
        measureFn: (Weight weightdata, _) => weightdata.weight,
        data: weightData,
      ),
    ];
    var chart = charts.TimeSeriesChart(
      series,
      animate: true,
      domainAxis: charts.DateTimeAxisSpec(
          tickProviderSpec: charts.DayTickProviderSpec(increments: [5]),
          tickFormatterSpec: charts.AutoDateTimeTickFormatterSpec(
              day: charts.TimeFormatterSpec(
                  format: 'd', transitionFormat: 'MMM dd'))),
      primaryMeasureAxis: charts.NumericAxisSpec(
          tickProviderSpec: charts.BasicNumericTickProviderSpec(
              zeroBound: false, desiredMinTickCount: 6)),
    );
    var chartWidget = Padding(
      padding: EdgeInsets.all(32.0),
      child: SizedBox(
        height: 200.0,
        child: chart,
      ),
    );

    return Scaffold(
        appBar: AppBar(
          title: Text("History"),
        ),
        body: Container(
          child: Center(child: chartWidget),
        ));
  }
}

class Weight {
  final DateTime date;
  final double weight;

  Weight(this.date, this.weight);
}

class Calories {
  final DateTime date;
  final double calories;

  Calories(this.date, this.calories);
}
