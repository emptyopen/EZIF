import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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
  var calories = {};
  var weights = {};

  @override
  void initState() {
    super.initState();
    _loadAsyncData();
  }

  _loadAsyncData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      calories = json.decode(prefs.getString('calories')) ?? {};
      weights = json.decode(prefs.getString('weights')) ?? {};
    });
  }

  @override
  Widget build(BuildContext context) {
    //_loadAsyncData();
    print(weights);
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
    var _weightsDataSource = WeightDataSource(weightData);
    var caloriesData = [
      Calorie(DateTime(2019, 7, 22), 140),
      Calorie(DateTime(2019, 7, 22), 140),
      Calorie(DateTime(2019, 7, 22), 140),
      Calorie(DateTime(2019, 7, 22), 140),
      Calorie(DateTime(2019, 7, 22), 140),
      Calorie(DateTime(2019, 7, 22), 140),
    ];
    var _caloriesDataSource = CalorieDataSource(caloriesData);
    var series = [
      charts.Series<Weight, DateTime>(
        id: 'Weight',
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
          child: Column(
            children: <Widget>[
              Center(child: chartWidget),
              PaginatedDataTable(
                  header: Text('Meal Log'),
                  dataRowHeight: 30,
                  headingRowHeight: 30,
                  rowsPerPage: 4,
                  columns: <DataColumn>[
                    DataColumn(
                        label: Text('Date'),),
                    DataColumn(label: Text('Calories'))
                  ],
                  source: _caloriesDataSource,
              ),
              PaginatedDataTable(
                  header: Text('Weight Log'),
                  dataRowHeight: 30,
                  headingRowHeight: 30,
                  rowsPerPage: 3,
                  columns: <DataColumn>[
                    DataColumn(
                        label: Text('Date'),),
                    DataColumn(label: Text('Weight'))
                  ],
                  source: _weightsDataSource,
              ),
            ],
          ),
        ));
  }
}

class WeightDataSource extends DataTableSource {
  final List<Weight> _weights;
  WeightDataSource(this._weights);
  int _selectedCount = 0;

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    if (index >= _weights.length) return null;
    final Weight weight = _weights[index];
    return DataRow.byIndex(
        index: index,
        selected: weight.selected,
        onSelectChanged: null,
        cells: <DataCell>[
          DataCell(Text('${weight.date.year.toString().padLeft(2, '0')}-${weight.date.month.toString().padLeft(2, '0')}-${weight.date.day.toString().padLeft(2, '0')}'),
          onTap: () => print(weight.date)),
          DataCell(Text('${weight.weight}'),
          onTap: () => print(weight.weight)),
        ]);
  }

  @override
  int get rowCount => _weights.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedCount;
}

class CalorieDataSource extends DataTableSource {
  final List<Calorie> _calories;
  CalorieDataSource(this._calories);
  int _selectedCount = 0;

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    if (index >= _calories.length) return null;
    final Calorie calorie = _calories[index];
    return DataRow.byIndex(
        index: index,
        selected: calorie.selected,
        onSelectChanged: null,
        cells: <DataCell>[
          DataCell(Text('${calorie.date}'),
              onTap: () => print(calorie.date)),
          DataCell(Text('${calorie.calorie}'),
              onTap: () => print(calorie.calorie)),
        ]);
  }

  @override
  int get rowCount => _calories.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedCount;
}

class Weight {
  final DateTime date;
  final double weight;
  bool selected = false;

  Weight(this.date, this.weight);
}

class Calorie {
  final DateTime date;
  final double calorie;
  bool selected = false;

  Calorie(this.date, this.calorie);
}
