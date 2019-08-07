import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class WeightDialog extends StatefulWidget {
  final Color color;
  final String saveUpdate;

  WeightDialog({this.color, this.saveUpdate});

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
                            var _weight = double.parse(_weightController.text);
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
                        child: widget.saveUpdate == 'save' ?
                        Text("Save", style: TextStyle(color: Colors.black),) :
                        Text("Update", style: TextStyle(color: Colors.black),),
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


class Weight {
  final DateTime date;
  final double weight;
  bool selected = false;

  Weight(this.date, this.weight);
}


class WeightDataSource extends DataTableSource {
  final List<Weight> _weights;
  final BuildContext context;

  WeightDataSource(this.context, this._weights);

  int _selectedCount = 0;

  _updateWeight(index, Weight _weight) async {
    print('$index $_weight');
    var updatedWeight = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => WeightDialog(
            color: Colors.greenAccent,
            saveUpdate: 'update',
          ),
          fullscreenDialog: true,
        ));
    if (updatedWeight != null) {
      print('received weight: $updatedWeight');
      final prefs = await SharedPreferences.getInstance();
      var tempWeights = json.decode(prefs.getString('weights')) ?? {};
      print('existing weights $tempWeights');
      tempWeights[_weight.date.toString()] = updatedWeight;
      prefs.setString('weights', json.encode(tempWeights));
      tempWeights = json.decode(prefs.getString('weights')) ?? {};
      print('updated weights  $tempWeights');
      _weights.add(Weight(DateTime.now(), 143));
      print('test');
    }
  }

  Future<Null> _updateDate(DateTime oldDate) async {
    final DateTime newDate = await showDatePicker(
        context: context,
        initialDate: oldDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (newDate != null && newDate != oldDate) {
      print('changing date from $oldDate to $newDate');
      final prefs = await SharedPreferences.getInstance();
      var tempWeights = json.decode(prefs.getString('weights')) as Map ?? {};
      var tempWeight = tempWeights[oldDate.toString()];
      tempWeights.remove(oldDate.toString());
      tempWeights[newDate.toString()] = tempWeight;
      prefs.setString('weights', json.encode(tempWeights));
      tempWeights = json.decode(prefs.getString('weights')) ?? {};
      print('updated weights $tempWeights');
    }
  }

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    if (index >= _weights.length) return null;
    final Weight weight = _weights[index];
    return DataRow.byIndex(
        index: index,
        selected: weight.selected,
        onSelectChanged: null,
        cells: <DataCell>[
          DataCell(
              Text(
                  '${weight.date.year.toString().padLeft(2, '0')}-${weight.date.month.toString().padLeft(2, '0')}-${weight.date.day.toString().padLeft(2, '0')}'),
              onTap: () {
                _updateDate(weight.date);
              }),
          DataCell(Text('${weight.weight}'), onTap: () {
            _updateWeight(index, weight);
          }),
        ]);
  }

  @override
  int get rowCount => _weights.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedCount;
}