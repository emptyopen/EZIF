import 'package:flutter/material.dart';

class WeightDialog extends StatefulWidget {
  final Color color;

  WeightDialog({this.color});

  @override
  WeightDialogState createState() => WeightDialogState();
}

class WeightDialogState extends State<WeightDialog> {
  bool _shouldShowError = false;
  TextEditingController _weightController = TextEditingController();

  bool _isNumeric(String str) {
    if(str == null) {
      return false;
    }
    return double.tryParse(str) != null;
  }

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
                          if (this._isNumeric(_weightController.text)) {
                            var _weight = int.parse(_weightController.text);
                            setState(() {
                              _shouldShowError = false;
                            });
                            Navigator.pop(context, _weight);
                          } else {
                            setState(() {
                              _shouldShowError = true;
                            });
                          }
                        },
                        color: widget.color,
                        child: Text("Save", style: TextStyle(color: Colors.black),),
                      ))
                ],
              ),
              if(_shouldShowError) Text('Weight must be numeric.'),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
        ));
  }
}
