import 'package:flutter/material.dart';

class CalorieCount extends StatelessWidget {
  final Color color;
  var calorieSum;

  CalorieCount({this.color, this.calorieSum});

  @override
  Widget build(BuildContext context) {
    var totalCalories = 2200;
    return Container(
      margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
      height: 80,
      width: 300,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(const Radius.circular(10.0)),
          border: Border.all(width: 2.0, color: color)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          totalCalories - calorieSum >= 0 ?
          Text('${totalCalories - calorieSum} calories',
              style: TextStyle(
                fontSize: 24,
              )) :
          Text('${(totalCalories - calorieSum).abs()} calories',
              style: TextStyle(
                fontSize: 24,
              )),
          totalCalories - calorieSum >= 0 ?
          Text('left to eat!', style: TextStyle(fontSize: 18)):
          Text('overeaten!', style: TextStyle(fontSize: 18, color: Colors.pinkAccent)),
        ],
      ),
      alignment: Alignment(0, 0),
    );
  }
}

class CalorieDialog extends StatefulWidget {
  final Color color;
  AnimationController controller;
  String mode;

  CalorieDialog({this.color, this.controller, this.mode});

  @override
  CalorieDialogState createState() => CalorieDialogState();
}

class CalorieDialogState extends State<CalorieDialog> {
  int _calories = 0;
  bool _shouldShowError = false;
  TextEditingController _caloriesController = TextEditingController();

  bool _isNumeric(String str) {
    if(str == null) {
      return false;
    }
    return double.tryParse(str) != null;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: AppBar(
          title: Text("Add calories"),
        ),
        body: Padding(
          child: ListView(
            children: <Widget>[
              Container(
                height: 150,
                margin: EdgeInsets.fromLTRB(0, 30, 0, 0),
                child: GridView.count(
                  crossAxisCount: 5,
                  childAspectRatio: 1.5,
                  children: List.generate(15, (index) {
                    return GestureDetector(
                        onTap: () {
                          _calories = index * 100 + 100;
                          Navigator.pop(context, _calories);
                        },
                        child: Container(
                          margin: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            border: Border.all(width: 2, color: Colors.black),
                            color: widget.color,
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          child: Center(
                              child: Text(
                                '${index * 100 + 100}',
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              )),
                        ));
                  }),
                ),
              ),
              TextField(
                controller: _caloriesController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              Row(
                children: <Widget>[
                  Expanded(
                      child: RaisedButton(
                        color: widget.color,
                        onPressed: () {
                          if (this._isNumeric(_caloriesController.text)) {
                            _calories = int.parse(_caloriesController.text);
                            setState(() {
                              _shouldShowError = false;
                            });
                            Navigator.pop(context, _calories);
                          } else {
                            setState(() {
                              _shouldShowError = true;
                            });
                          }
                        },
                        child: Text("Save", style: TextStyle(color: Colors.black),),
                      ))
                ],
              ),
              if(_shouldShowError) Text('Calories must be numeric.'),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
        ));
  }
}
