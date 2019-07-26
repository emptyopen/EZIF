import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  final Color color;

  SettingsPage({this.color});

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  int _maxDailyCalories = 2000;
  TextEditingController _maxDailyCaloriesController = TextEditingController();
  bool _shouldShowError = false;

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _maxDailyCalories = (prefs.getInt('maxDailyCalories') ?? 2200);
    });
  }

  setSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('maxDailyCalories', _maxDailyCalories);
  }

  bool _isNumeric(String str) {
    if (str == null) {
      return false;
    }
    return double.tryParse(str) != null;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: AppBar(
          title: Text("Settings"),
        ),
        body: Container(
          child: ListView(
            children: <Widget>[
              Center(
                  child: Text(
                'Maximum daily calories: $_maxDailyCalories',
                style: TextStyle(fontSize: 20),
              )),
              TextField(
                controller: _maxDailyCaloriesController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              Row(
                children: <Widget>[
                  Expanded(
                      child: RaisedButton(
                    onPressed: () {
                      if (this._isNumeric(_maxDailyCaloriesController.text)) {
                        setState(() {
                          _maxDailyCalories = int.parse(_maxDailyCaloriesController.text);
                          _maxDailyCaloriesController.clear();
                          _shouldShowError = false;
                        });
                        setSettings();
                      } else {
                        setState(() {
                          _shouldShowError = true;
                        });
                      }
                    },
                    color: widget.color,
                    child: Text(
                      "Update",
                      style: TextStyle(color: Colors.black),
                    ),
                  ))
                ],
              ),
              if (_shouldShowError) Text('Max daily calories must be numeric.'),
            ],
          ),
        ));
  }
}
