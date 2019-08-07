import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import './weight.dart';
import './calorie.dart';

// TODO: tables: fix screen update after modifications
// TODO: tables: reverse dates, or allow sorting
// TODO: plot: hard select ranges, range selections (week, month, year)
// TODO: plot: add calories (bubbles with size of calories)

class HistoryPage extends StatefulWidget {
  final Color color;

  HistoryPage({this.color});

  @override
  HistoryPageState createState() => HistoryPageState();
}

class HistoryPageState extends State<HistoryPage> {
  var calories = {};
  var weights = {};
  var test = 'one';

  @override
  void initState() {
    super.initState();
    _loadAsyncData();
  }

  _loadAsyncData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      String caloriesString = prefs.getString('calories') ?? '';
      if (caloriesString != '') {
        calories = json.decode(caloriesString);
      } else {
        calories = {};
      }
      String weightsString = prefs.getString('weights') ?? '';
      if (weightsString != '') {
        weights = json.decode(weightsString);
      } else {
        weights = {};
      }
    });
  }

  _updateCalories(BuildContext context, _caloriesDataSource) async {
    var inputCalories = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: Text('Update meals')),
            body: Column(
              children: <Widget>[
                PaginatedDataTable(
                  header: Text('Meal Log'),
                  dataRowHeight: 30,
                  headingRowHeight: 30,
                  rowsPerPage: 10,
                  columns: <DataColumn>[
                    DataColumn(
                      label: Text('Date'),
                    ),
                    DataColumn(label: Text('Calories'))
                  ],
                  source: _caloriesDataSource,
                ),
                RaisedButton(
                  onPressed: () => setState,
                  child: Text('hi'),
                )
              ],
            )
          ),
          fullscreenDialog: true,
        ));

    if (inputCalories != null) {
      print(inputCalories);
    }
  }

  _updateWeights(BuildContext context, _weightsDataSource) async {
    var inputWeight = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: Text('Update weights')),
            body: Column(
              children: <Widget>[
                PaginatedDataTable(
                  header: Text('Weight Log'),
                  sortColumnIndex: 0,
                  sortAscending: false,
                  dataRowHeight: 30,
                  headingRowHeight: 30,
                  rowsPerPage: 10,
                  columns: <DataColumn>[
                    DataColumn(
                      label: Text('Date'),
                    ),
                    DataColumn(label: Text('Weight'))
                  ],
                  source: _weightsDataSource,
                ),
                RaisedButton(
                  onPressed: () {
                    print('wowowow');
                    setState(() {

                    });

                  },
                  child: Text('hi'),
                )
              ],
            )
          ),
          fullscreenDialog: true,
        ));

    if (inputWeight != null) {
      print(inputWeight);
    }

    await _loadAsyncData();
  }

  @override
  Widget build(BuildContext context) {

    //_loadAsyncData();

    List<Weight> weightData = List();
    weights.forEach((k, v) =>
        weightData.add(Weight(DateTime.parse(k), double.parse(v.toString()))));
    weightData.sort((a, b) => a.date.compareTo(b.date));
    var _weightsDataSource = WeightDataSource(context, weightData);
    setState(() {
      _weightsDataSource = WeightDataSource(context, weightData);
    });
    var weightSeries = [
      charts.Series<Weight, DateTime>(
        id: 'Weight',
        colorFn: (_, __) => charts.Color.fromHex(code: '#b2ff59'),
        domainFn: (Weight weightData, _) => weightData.date,
        measureFn: (Weight weightData, _) => weightData.weight,
        data: weightData,
      ),
    ];
    var weightChart = Padding(
      padding: EdgeInsets.all(32.0),
      child: SizedBox(
        height: 200.0,
        child: charts.TimeSeriesChart(
          weightSeries,
          animate: true,
          domainAxis: charts.DateTimeAxisSpec(
              tickProviderSpec: charts.DayTickProviderSpec(increments: [5]),
              tickFormatterSpec: charts.AutoDateTimeTickFormatterSpec(
                  day: charts.TimeFormatterSpec(
                      format: 'd', transitionFormat: 'MMM dd')),
              renderSpec: new charts.SmallTickRendererSpec(
                  labelStyle:
                  charts.TextStyleSpec(color: charts.MaterialPalette.white))),
          primaryMeasureAxis: charts.NumericAxisSpec(
              tickProviderSpec: charts.BasicNumericTickProviderSpec(
                  zeroBound: false, desiredMinTickCount: 6),
              renderSpec: new charts.GridlineRendererSpec(
                  labelStyle:
                  charts.TextStyleSpec(color: charts.MaterialPalette.white))),
        ),
      ),
    );


    // TODO: convert calories to daily calories (red if it is over?)
    List<Calorie> calorieData = List();
    if (weightData.length > 0) {
      calories.forEach((k, v) => calorieData
          .add(Calorie(DateTime.parse(k), double.parse(v.toString()), weightData[0].weight, true)));
    }
    calorieData.sort((a, b) => a.date.compareTo(b.date));
    var _caloriesDataSource = CalorieDataSource(context, calorieData);
    setState(() {
      _caloriesDataSource = CalorieDataSource(context, calorieData);
    });
    var calorieSeries = [
      charts.Series<Calorie, int>(
        id: 'Calories',
        colorFn: (_, __) => charts.Color.fromHex(code: '#b2ff59'),
        domainFn: (Calorie calorieData, _) => calorieData.date.millisecondsSinceEpoch,
        measureFn: (Calorie calorieData, _) => calorieData.calorie,
        data: calorieData,
      ),
    ];
    var calorieChart = Padding(
      padding: EdgeInsets.all(32.0),
      child: SizedBox(
        height: 200.0,
        child: charts.ScatterPlotChart(
          calorieSeries,
          animate: true,
        ),
      ),
    );


    return Scaffold(
        appBar: AppBar(
          title: Text('History'),
        ),
        body: Container(
          child: Column(
            children: <Widget>[
              //Center(child: calorieChart),
              Center(child: weightChart),
              Card(
                  margin: EdgeInsets.fromLTRB(70, 0, 70, 0),
                  child: ListTile(
                    title: Center(
                        child: Text(
                      'Update meals',
                      style: TextStyle(fontSize: 20),
                    )),
                    onTap: () {
                      _updateCalories(context, _caloriesDataSource);
                    },
                  )),
              Card(
                  margin: EdgeInsets.fromLTRB(70, 20, 70, 0),
                  child: ListTile(
                    title: Center(
                        child: Text(
                      'Update weights',
                      style: TextStyle(fontSize: 20),
                    )),
                    onTap: () {
                      _updateWeights(context, _weightsDataSource);
                    },
                  )),
            ],
          ),
        ));
  }
}


