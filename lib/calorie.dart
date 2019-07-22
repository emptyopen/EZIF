import 'package:flutter/material.dart';

class CalorieCount extends StatelessWidget {
  final Color color;

  CalorieCount({this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
      height: 70,
      width: 300,
      decoration: new BoxDecoration(
          borderRadius: new BorderRadius.all(const Radius.circular(10.0)),
          border: Border.all(width: 2.0, color: color)
      ),
      child: Text('2000 calories left to eat!',
      style: TextStyle(fontSize: 18),),
      alignment: Alignment(0, 0),
    );
  }
}

class CalorieDialog extends StatefulWidget {
  @override
  CalorieDialogState createState() => new CalorieDialogState();
}

class CalorieDialogState extends State<CalorieDialog> {
  String _calories = '0';
  TextEditingController _caloriesController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Add calories"),
        ),
        body: new Padding(
          child: new ListView(
            children: <Widget>[
              new TextField(
                controller: _caloriesController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              new Row(
                children: <Widget>[
                  new Expanded(
                      child: new RaisedButton(
                        onPressed: () {
                          _calories = _caloriesController.text;
                          Navigator.pop(context);
                          print('hi');
                          print(_calories);
                        },
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


