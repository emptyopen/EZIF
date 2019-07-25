import 'package:flutter/material.dart';

class WeightDialog extends StatefulWidget {
  final Color color;

  WeightDialog({this.color});

  @override
  WeightDialogState createState() => WeightDialogState();
}

class WeightDialogState extends State<WeightDialog> {
  String _weight = '0';
  TextEditingController _weightController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Add weight"),
        ),
        body: Padding(
          child: ListView(
            children: <Widget>[
              TextField(
                controller: _weightController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              Row(
                children: <Widget>[
                  Expanded(
                      child: RaisedButton(
                        onPressed: () {
                          _weight = _weightController.text;
                          Navigator.pop(context, _weight);
                        },
                        color: widget.color,
                        child: Text("Save", style: TextStyle(color: Colors.black),),
                      ))
                ],
              )
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
        ));
  }
}
