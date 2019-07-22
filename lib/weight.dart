import 'package:flutter/material.dart';

class WeightDialog extends StatefulWidget {
  @override
  WeightDialogState createState() => new WeightDialogState();
}

class WeightDialogState extends State<WeightDialog> {
  String _weight = '0';
  TextEditingController _weightController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Add weight"),
        ),
        body: new Padding(
          child: new ListView(
            children: <Widget>[
              new TextField(
                controller: _weightController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              new Row(
                children: <Widget>[
                  new Expanded(
                      child: new RaisedButton(
                        onPressed: () {
                          _weight = _weightController.text;
                          Navigator.pop(context);
                        },
                        color: Colors.greenAccent,
                        child: new Text("Save"),
                      ))
                ],
              )
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
        ));
  }
}
