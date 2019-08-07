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
  DateTime eatEndTime;
  DateTime fastEndTime;
  DateTime lastEaten;
  var maxDailyCalories = 2000;
  Color color = Colors.greenAccent;
  var calories = {};
  var sortedCalories = [];
  var weights = {};
  var calorieSum = 0;
  bool isLoading = true;
  int eatingSeconds = 60;
  int fastingSeconds = 60;
  var allDuration = Duration(minutes: 1);

  @override
  void initState() {
    super.initState();

    _loadAsyncData(initTrue: true);

    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: eatingSeconds),
    )..addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.dismissed) {
        if (mode == 'EATING') {
          setState(() {

            // TODO: this might cause problems
            sortedCalories = calories.keys.toList();
            sortedCalories.sort();
            lastEaten = DateTime.parse(sortedCalories[sortedCalories.length - 1]);

            mode = 'FASTING';
            color = Colors.lightBlue;
            eatEndTime = null;
            // TODO: add duration from last eaten
            fastEndTime = DateTime.now().add(allDuration);
          });
          controller.duration = Duration(seconds: fastingSeconds);
          controller.reverse(
              from: controller.value == 0.0 ? 1.0 : controller.value);
        } else if (mode == 'FASTING') {
          print('will transition to ready');
          controller.duration = Duration(seconds: eatingSeconds);
          setState(() {
            mode = 'READY';
            color = Colors.greenAccent;
            fastEndTime = null;
          });
        }
        _saveAsyncData('all');
      }
    });
  }

  _loadAsyncData({bool initTrue: false}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print('loading async data');
    setState(() {
      // max daily calories
      maxDailyCalories = prefs.getInt('maxDailyCalories') ?? 2000;

      // mode
      mode = prefs.getString('mode') ?? 'READY';

      // color
      color = _convertStringToColor(prefs.getString('color')) ?? Colors.greenAccent;

      // calories
      String caloriesString = prefs.getString('calories') ?? '';
      if (caloriesString != '') {
        calories = json.decode(caloriesString);
      } else {
        calories = {};
      }
      sortedCalories = calories.keys.toList();
      sortedCalories.sort();
      lastEaten = DateTime.parse(sortedCalories[sortedCalories.length - 1]);

      // check if new day for calorieSum
      _loadCalorieSum();

      // weights
      String weightsString = prefs.getString('weights') ?? '';
      if (weightsString != '') {
        weights = json.decode(weightsString);
      } else {
        weights = {};
      }

      // eating and fasting end times
      String eatEndTimeString = prefs.getString('eatEndTime') ?? null;
      String fastEndTimeString = prefs.getString('fastEndTime') ?? null;
      print('eatEndTimeString: $eatEndTimeString, fastEndTimeString: $fastEndTimeString');
      if (eatEndTimeString == 'null') {
        print('eatEndTimeString is null');
      }
      if (fastEndTimeString == 'null') {
        print('fastEndTimeString is null');
      }

      // check if we are done fasting, if so set to ready
      if (fastEndTimeString != 'null') {
        fastEndTime = DateTime.parse(fastEndTimeString);
        if (eatEndTime.difference(DateTime.now()).inSeconds < 0) {
          print('we are past fastEndTime... set to ready');
          mode = 'READY';
          color = Colors.greenAccent;
          eatEndTime = null;
          fastEndTime = null;
        }
      } else {
        fastEndTime = null;
      }

      // check if we are done eating, if so set to fasting or ready (depending on time since last eaten)
      if (eatEndTimeString != 'null') {
        // TODO: make sure this triggers when user opens app after minimizing it - app state https://api.flutter.dev/flutter/dart-ui/AppLifecycleState-class.html
        eatEndTime = DateTime.parse(eatEndTimeString);
        if (eatEndTime.difference(DateTime.now()).inSeconds < 0) {
          print('we are past eatEndTime... find when last eaten and change mode to fasting or ready');
          print('if we are within 16 hours of last eaten, transition to fasting as relevant, otherwise ready');
          print('last eaten: $lastEaten');

          // if last eaten is less than 16 hours ago, switch to fasting with partial time
          if (DateTime.now().difference(lastEaten).inSeconds < 57600) {
            print('last eaten was less than 16 hours ago, setting to fasting');
            mode = 'FASTING';
            color = Colors.lightBlue;
            eatEndTime = null;
            fastEndTime = lastEaten.add(allDuration);
          } else {  // else switch to ready
            print('last eaten was more than 16 hours ago, setting to ready');
            mode = 'READY';
            color = Colors.greenAccent;
            eatEndTime = null;
            fastEndTime = null;
          }
        }
      } else {
        eatEndTime = null;
      }
    });


    // if we are entering app cold, need to re-adjust animations
    if (initTrue) {

      print('in initTrue');

      if (eatEndTime != null) {  // we should be eating
        var eatTimeRemainingFraction = eatEndTime.difference(DateTime.now()).inSeconds / eatingSeconds;
        print('eatTimeRemainingFraction: $eatTimeRemainingFraction');
        controller.duration = Duration(seconds: eatingSeconds);
        controller.reverse(
            from: eatTimeRemainingFraction); //eatTimeRemainingFraction);
      } else if (fastEndTime != null) {  // we should be fasting
        var fastTimeRemainingFraction = fastEndTime.difference(DateTime.now()).inSeconds / fastingSeconds;
        print('fastTimeRemainingFraction: $fastTimeRemainingFraction');
        controller.duration = Duration(seconds: fastingSeconds);
        controller.reverse(
            from: fastTimeRemainingFraction);
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  _loadCalorieSum() {
    var today = DateTime.now();
    String dateSlug = '${today.year.toString()}-${today.month.toString().padLeft(2,'0')}-${today.day.toString().padLeft(2,'0')}';
    try {
      setState(() {
        calorieSum = calories.entries.where((e) =>
            e.key.toString()
                .startsWith(dateSlug))
            .map<int>((e) => e.value)
            .reduce((a, b) => a + b);
      });
    } catch (Exception) {
      print('no daily calories, setting sum to 0');
      setState(() {
        calorieSum = 0;
      });
    }
  }

  _saveAsyncData(String key) async {
    print('saving async data: $key');
    final prefs = await SharedPreferences.getInstance();
    if (key == 'maxDailyCalories' || key == 'all') {
      prefs.setInt('maxDailyCalories', maxDailyCalories);
    }
    if (key == 'mode' || key == 'all') {
      prefs.setString('mode', mode);
    }
    if (key == 'color' || key == 'all') {
      prefs.setString('color', color.toString());
    }
    if (key == 'eatEndTime' || key == 'all') {
      prefs.setString('eatEndTime', eatEndTime.toString());
    }
    if (key == 'fastEndTime' || key == 'all') {
      prefs.setString('fastEndTime', fastEndTime.toString());
    }
    if (key == 'calories' || key == 'all') {
      prefs.setString('calories', json.encode(calories));
    }
    if (key == 'weights' || key == 'all') {
      prefs.setString('weights', json.encode(weights));
    }
  }

  _getCalories(BuildContext context) async {
    var inputCalories = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              CalorieDialog(
                color: color,
                saveUpdate: 'save',
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
          eatEndTime = DateTime.now().add(allDuration);
          color = Colors.pinkAccent;
        });
        _saveAsyncData('calories');
        _saveAsyncData('mode');
        _saveAsyncData('eatStartTime');
        _saveAsyncData('eatEndTime');
        _saveAsyncData('color');
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
                saveUpdate: 'save',
              ),
          fullscreenDialog: true,
        ));
    if (inputWeight != null) {
      weights[DateTime.now().toString()] = inputWeight;
      print('received weight: $inputWeight, weights: $weights');
      _saveAsyncData('weights');
    }
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
    _loadAsyncData();
  }

  @override
  Widget build(BuildContext context) {
    print('mode is: $mode');
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
            padding: EdgeInsets.fromLTRB(40, 0, 40, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                        margin: EdgeInsets.fromLTRB(70, 15, 70, 5),
                        child: ListTile(
                          title: Center(child: Text("+ WEIGHT +", style: TextStyle(fontSize: 18),)),
                          onTap: () {
                            _getWeight(context);
                          },
                        )),
                  ],
                ),
              ],
            ),
          ),
        ));
  }

  _convertStringToColor(colorString) {
    String valueString = colorString.split('(0x')[1].split(')')[0];
    int value = int.parse(valueString, radix: 16);
    return Color(value);
  }
}


mixin NonStopTickerProviderMixin implements TickerProvider {
  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}