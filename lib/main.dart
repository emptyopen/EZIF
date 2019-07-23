import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './status.dart';
import './calorie.dart';
import './weight.dart';

void main() =>
    runApp(MaterialApp(
      home: MyApp(),
      theme: ThemeData(
        canvasColor: Colors.grey[600],
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
  Color color = Colors.greenAccent;
  var calories = {};
  var calorieSum = 0;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 10),
    )..addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.dismissed) {
        print('completed');
        // TODO: transition from eating to fasting, and from fasting to ready
        if (mode == 'EATING') {
          print('will transition to fasting');
          controller.duration = Duration(seconds: 20);
          controller.reverse();
          // this isn't working
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
    calories[DateTime.now()] = inputCalories;
    calorieSum = calories.entries.where((e) =>
        e.key.toString()
            .startsWith('2019-07-22'))
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
        color = Colors.amberAccent;
      });
      print('mode is now: $mode');
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
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        // TODO: bottomNavigationBar: BottomNavigationBar(items: null),
        appBar: AppBar(title: Text('EZIF'),),
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
                          title: Center(child: Text("Add meal")),
                          onTap: () {
                            _getCalories(context);
                          },
                        )),
                    Card(
                        margin: EdgeInsets.fromLTRB(60, 5, 60, 5),
                        child: ListTile(
                          title: Center(child: Text("Add weight")),
                          onTap: () {
                            _getWeight(context);
                          },
                        )),
                  ],
                ),
              ],
            ),
          ),
          margin: MediaQuery
              .of(context)
              .padding,
        ));
  }
}
