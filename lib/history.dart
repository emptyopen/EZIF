import 'package:flutter/material.dart';

class HistoryPage extends StatefulWidget {
  final Color color;

  HistoryPage({this.color});

  @override
  HistoryPageState createState() => HistoryPageState();
}

class HistoryPageState extends State<HistoryPage> {

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
          title: Text("History"),
        ),
        body: Container(
          child: Text('whoa'),
        )
    );
  }
}