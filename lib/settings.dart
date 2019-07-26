import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  final Color color;

  SettingsPage({this.color});

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  int _maxCalories = 2000;
  TextEditingController _maxCaloriesController = TextEditingController();
  bool _shouldShowError = false;

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _maxCalories = (prefs.getInt('maxCalories') ?? 2200);
    });
  }

  setSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('maxCalories', _maxCalories);
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
                'Maximum daily calories: $_maxCalories',
                style: TextStyle(fontSize: 20),
              )),
              TextField(
                controller: _maxCaloriesController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              Row(
                children: <Widget>[
                  Expanded(
                      child: RaisedButton(
                    onPressed: () {
                      if (this._isNumeric(_maxCaloriesController.text)) {
                        setState(() {
                          _maxCalories = int.parse(_maxCaloriesController.text);
                          _maxCaloriesController.clear();
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
