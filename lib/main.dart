import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './status.dart';
import './calorie.dart';
import './weight.dart';
import './history.dart';
import './settings.dart';

void main() =>
    runApp(MaterialApp(
      home: MyApp(),
      theme: ThemeData(
        fontFamily: 'Quicksand',
        canvasColor: Colors.grey[900],
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        accentColor: Colors.greenAccent,
        brightness: Brightness.dark,
      ),
    ));

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> with TickerProviderStateMixin {
  AnimationController controller;
  var mode = 'READY';
  var eatEndTime = '';
  var fastEndTime = '';
  var maxDailyCalories = 2000;
  Color color = Colors.greenAccent;
  var calories = {};
  var calorieSum = 0;
  var _result;
  bool isLoading = true;

  _readInt(key, defaultVal) async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getInt(key) ?? defaultVal;
    print('read $key: $value');
  }

  _readString(key, defaultVal) async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(key) ?? defaultVal;
    print('read $key: $value');
  }

  _save(key, val) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(key, val);
    print('saved $key: $val');
  }

  loadAsyncData() async {
    mode = await _readString('mode', 'READY');
    eatEndTime = await _readString('eatEndTime', DateTime.now().toString());
    fastEndTime = await _readString('fastEndTime', DateTime.now().toString());
    maxDailyCalories = await _readInt('maxDailyCalories', 2000);

    print('init: mode[$mode], eatEndTime[$eatEndTime], fastEndTime[$fastEndTime], maxDailyCalories[$maxDailyCalories]');
  }

  @override
  void initState() {
    super.initState();

    loadAsyncData().then((result) {
      // If we need to rebuild the widget with the resulting data,
      // make sure to use `setState`
      setState(() {
        _result = result;
        isLoading = false;
      });
    });

    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 10),
    )..addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.dismissed) {
        if (mode == 'EATING') {
          print('will transition to fasting');
          controller.duration = Duration(seconds: 10);
          controller.reverse(
              from: controller.value == 0.0 ? 1.0 : controller.value);
          setState(() {
            mode = 'FASTING';
            color = Colors.lightBlue;
          });
        } else if (mode == 'FASTING') {
          print('will transition to ready');
          controller.duration = Duration(seconds: 5);
          setState(() {
            mode = 'READY';
            color = Colors.greenAccent;
          });
        }
      }
    });
  }

  _getCalories(BuildContext context) async {
    var inputCalories = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              CalorieDialog(
                color: color,
                controller: controller,
                mode: mode,
              ),
          fullscreenDialog: true,
        ));

    if (inputCalories != null) {
      calories[DateTime.now()] = inputCalories;
      print(calories);
      var today = DateTime.now();
      String dateSlug = '${today.year.toString()}-${today.month.toString().padLeft(2,'0')}-${today.day.toString().padLeft(2,'0')}';
      calorieSum = calories.entries.where((e) =>
          e.key.toString()
              .startsWith(dateSlug))
          .map<int>((e) => e.value)
          .reduce((a, b) => a + b);
      print(
          'received calories: $inputCalories, sum is now: $calorieSum, calories are now: $calories');
      // start animation and set mode
      if (!controller.isAnimating && inputCalories != null) {
        controller.reverse(
            from: controller.value == 0.0 ? 1.0 : controller.value);
        setState(() {
          mode = 'EATING';
          color = Colors.pinkAccent;
        });
        print('mode is now: $mode');
      }
    }
  }

  _getWeight(BuildContext context) async {
    var weight = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) =>
              WeightDialog(
                color: color,
              ),
          fullscreenDialog: true,
        ));
    print('received weight: $weight');
  }

  @override
  Widget build(BuildContext context) {
    print('hey $mode');
    return
      isLoading ?
          Scaffold() :
      Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          title: Text('EZIF'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.schedule,
            color: color,
            size: 30,),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        HistoryPage(),
                    fullscreenDialog: true,
                  ));
            },
          ),
          IconButton(
            icon: Icon(Icons.settings,
              color: color,
              size: 30,),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        SettingsPage(),
                    fullscreenDialog: true,
                  ));
            },
          )
        ],),
        body: Container(
          child: Padding(
            padding: EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Status(controller: controller, color: color, mode: mode,),

                CalorieCount(color: color, calorieSum: calorieSum),
                Column(
                  children: <Widget>[
                    Card(
                        margin: EdgeInsets.fromLTRB(60, 5, 60, 5),
                        child: ListTile(
                          title: Center(child: Text("Add meal", style: TextStyle(fontSize: 22),)),
                          onTap: () {
                            _getCalories(context);
                          },
                        )),
                    Card(
                        margin: EdgeInsets.fromLTRB(60, 5, 60, 5),
                        child: ListTile(
                          title: Center(child: Text("Add weight", style: TextStyle(fontSize: 22),)),
                          onTap: () {
                            _getWeight(context);
                          },
                        )),
                  ],
                ),
                Text(''),
              ],
            ),
          ),
        ));
  }
}
