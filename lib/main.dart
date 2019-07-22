import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './status.dart';
import './calorie.dart';
import './weight.dart';

void main() => runApp(MaterialApp(
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

  String get timerString {
    Duration duration = controller.duration * controller.value;
    return '${(duration.inHours).toString().padLeft(2, '0')}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 3600 % 60).toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 10000),
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    var mode = 'READY';
    Color color = Colors.greenAccent;
    var calories = [100, 200, 300, 500];

    CalorieDialog _calorieDialog = new CalorieDialog();
    WeightDialog _weightDialog = new WeightDialog();

    return Scaffold(
        resizeToAvoidBottomPadding: false,
        // TODO: bottomNavigationBar: BottomNavigationBar(items: null),
        body: Container(
          child: Padding(
            padding: EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                // Status circle
                mode != 'READY'
                    ? Expanded(
                        child: Align(
                          alignment: FractionalOffset.center,
                          child: AspectRatio(
                            aspectRatio: 1.0,
                            child: Stack(
                              children: <Widget>[
                                Positioned.fill(
                                  child: AnimatedBuilder(
                                    animation: controller,
                                    builder:
                                        (BuildContext context, Widget child) {
                                      return CustomPaint(
                                          painter: TimerPainter(
                                        animation: controller,
                                        backgroundColor: Colors.white,
                                        color: themeData.indicatorColor,
                                      ));
                                    },
                                  ),
                                ),
                                Align(
                                  alignment: FractionalOffset.center,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Text(''),
                                      Text(
                                        mode,
                                        style: TextStyle(fontSize: 30),
                                      ),
                                      AnimatedBuilder(
                                          animation: controller,
                                          builder: (BuildContext context,
                                              Widget child) {
                                            return Text(
                                              timerString,
                                              style: TextStyle(
                                                fontSize: 70,
                                              ),
                                            );
                                          }),
                                      Text('')
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : Expanded(
                        child: Align(
                          alignment: FractionalOffset.center,
                          child: AspectRatio(
                            aspectRatio: 1.0,
                            child: Stack(
                              children: <Widget>[
                                Positioned.fill(
                                  child: AnimatedBuilder(
                                    animation: controller,
                                    builder:
                                        (BuildContext context, Widget child) {
                                      return CustomPaint(
                                          painter: TimerPainter(
                                        animation: controller,
                                        backgroundColor: Colors.white,
                                        color: themeData.indicatorColor,
                                      ));
                                    },
                                  ),
                                ),
                                Align(
                                  alignment: FractionalOffset.center,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Text(''),
                                      Text(
                                        mode,
                                        style: TextStyle(fontSize: 30),
                                      ),
                                      Text(
                                        '',
                                        style: TextStyle(
                                          fontSize: 70,
                                        ),
                                      ),
                                      Text('')
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                CalorieCount(color: color),
                Card(
                    margin: EdgeInsets.fromLTRB(60, 5, 60, 5),
                    child: ListTile(
                      title: Center(child: Text("Add your meal")),
                      onTap: () {
                          if (controller.isAnimating)
                            controller.stop();
                          else {
                            controller.reverse(
                                from: controller.value == 0.0
                                    ? 1.0
                                    : controller.value);
                          }
                          setState(() {
                            mode = 'EATING';
                          });
                          print('yo: ${mode}');
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) => _calorieDialog,
                              fullscreenDialog: true,
                            ));
                      },
                    )),
                Card(
                    margin: EdgeInsets.fromLTRB(60, 5, 60, 5),
                    child: ListTile(
                      title: Center(child: Text("Add your weight")),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) => _weightDialog,
                              fullscreenDialog: true,
                            ));
                      },
                    )),
                /*Container(
              margin: EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  FloatingActionButton(
                    child: AnimatedBuilder(
                      animation: controller,
                      builder: (BuildContext context, Widget child) {
                        return Icon(controller.isAnimating
                            ? Icons.pause
                            : Icons.play_arrow);
                      },
                    ),
                    onPressed: () {
                      if (controller.isAnimating)
                        controller.stop();
                      else {
                        controller.reverse(
                            from: controller.value == 0.0
                                ? 1.0
                                : controller.value);
                      }
                    },
                  )
                ],
              ),
            ),*/
              ],
            ),
          ),
          margin: MediaQuery.of(context).padding,
        ));
  }
}

