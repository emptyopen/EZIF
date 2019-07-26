import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/scheduler.dart';
import 'dart:convert';

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

class MyAppState extends State<MyApp> with NonStopTickerProviderMixin {
  AnimationController controller;
  var mode = 'READY';
  var eatEndTime = '';
  var fastEndTime = '';
  var maxDailyCalories = 2000;
  Color color = Colors.greenAccent;
  var calories = {};
  var weights = {};
  var calorieSum = 0;
  bool isLoading = false;
  int eatingSeconds = 7;
  int fastingSeconds = 10;

  // TODO: only save and load what is needed?
  _saveAsyncData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('maxDailyCalories', maxDailyCalories);
    prefs.setString('mode', mode);
    prefs.setString('color', color.toString());
    //prefs.setString('eatEndTime', value);
    //prefs.setString('fastEndTime', value);
    print('storing ${json.encode(calories)}');
    prefs.setString('calories', json.encode(calories));
    prefs.setInt('calorieSum', calorieSum);
    prefs.setString('weights', json.encode(weights));
  }

  _loadAsyncData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      maxDailyCalories = prefs.getInt('maxDailyCalories') ?? 2000;
      //mode = prefs.getString('mode') ?? 'READY';
      //color = _convertStringToColor(prefs.getString('color')) ?? Colors.greenAccent;
      eatEndTime = prefs.getString('eatEndTime') ?? DateTime.now().toString();
      fastEndTime = prefs.getString('fastEndTime') ?? DateTime.now().toString();
      calories = json.decode(prefs.getString('calories')) ?? {};
      calorieSum = prefs.getInt('calorieSum') ?? 0;
      weights = json.decode(prefs.getString('weights'))?? {};
    });
  }

  _convertStringToColor(colorString) {
    String valueString = colorString.split('(0x')[1].split(')')[0];
    int value = int.parse(valueString, radix: 16);
    return Color(value);
  }

  @override
  void initState() {
    super.initState();

    _loadAsyncData();

    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: eatingSeconds),
    )..addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.dismissed) {
        if (mode == 'EATING') {
          setState(() {
            mode = 'FASTING';
            color = Colors.lightBlue;
          });
          var fastEndTime2 = DateTime.now().add(Duration(hours: 16));
          // TODO: make this based on stored fastEndTime
          controller.duration = Duration(seconds: fastingSeconds);
          controller.reverse(
              from: controller.value == 0.0 ? 1.0 : controller.value);
          print('transitioning to fasting: fastEndTime $fastEndTime2');
        } else if (mode == 'FASTING') {
          print('will transition to ready');
          controller.duration = Duration(seconds: eatingSeconds);
          setState(() {
            mode = 'READY';
            color = Colors.greenAccent;
          });
        }
        _saveAsyncData();
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
      var today = DateTime.now();
      String dateSlug = '${today.year.toString()}-${today.month.toString().padLeft(2,'0')}-${today.day.toString().padLeft(2,'0')}';
      calories[DateTime.now().toString()] = inputCalories;
      // store calories and sum
      calorieSum = calories.entries.where((e) =>
          e.key.toString()
              .startsWith(dateSlug))
          .map<int>((e) => e.value)
          .reduce((a, b) => a + b);
      print('received calories: $inputCalories, sum is now: $calorieSum, calories are now: $calories');
      // start animation and set mode
      if (!controller.isAnimating && inputCalories != null) {
        controller.reverse(
            from: controller.value == 0.0 ? 1.0 : controller.value);
        setState(() {
          mode = 'EATING';
          color = Colors.pinkAccent;
        });
        _saveAsyncData();
      }
    }
  }

  _getWeight(BuildContext context) async {
    var inputWeight = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) =>
              WeightDialog(
                color: color,
              ),
          fullscreenDialog: true,
        ));
    if (inputWeight != null) {
      weights[DateTime.now().toString()] = inputWeight;
      print('received weight: $inputWeight, weights: $weights');
    }
    _saveAsyncData();
    _loadAsyncData();
  }

  _getHistory(BuildContext context) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              HistoryPage(),
          fullscreenDialog: true,
        ));
    _saveAsyncData();
    _loadAsyncData();
  }

  _getSettings(BuildContext context) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              SettingsPage(color: color),
          fullscreenDialog: true,
        ));
    _saveAsyncData();
    _loadAsyncData();
  }

  @override
  Widget build(BuildContext context) {
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
              _getHistory(context);
            },
          ),
          IconButton(
            icon: Icon(Icons.settings,
              color: color,
              size: 30,),
            onPressed: () {
              _getSettings(context);
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

                CalorieCount(color: color, calorieSum: calorieSum, maxDailyCalories: maxDailyCalories,),
                Column(
                  children: <Widget>[
                    Card(
                        margin: EdgeInsets.fromLTRB(60, 5, 60, 5),
                        child: ListTile(
                          title: Center(child: Text("++ MEAL ++", style: TextStyle(fontSize: 24),)),
                          onTap: () {
                            _getCalories(context);
                          },
                        )),
                    Card(
                        margin: EdgeInsets.fromLTRB(80, 15, 80, 5),
                        child: ListTile(
                          title: Center(child: Text("++ WEIGHT ++", style: TextStyle(fontSize: 18),)),
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


mixin NonStopTickerProviderMixin implements TickerProvider {
  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}