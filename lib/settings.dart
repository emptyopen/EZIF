import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  final Color color;

  SettingsPage({this.color});

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {

  var fakeData = {
    DateTime(2019, 1, 1, 1, 1, 1): 184,
    DateTime(2019, 1, 1, 1, 1, 1): 184,
    DateTime(2019, 1, 1, 1, 1, 1): 184,
    DateTime(2019, 1, 1, 1, 1, 1): 184,
    DateTime(2019, 1, 1, 1, 1, 1): 184,

  };

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: AppBar(
          title: Text("Settings"),
        ),
        body: Container(
          child: Text('here'),
        )
    );
  }
}