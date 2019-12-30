import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';

import 'settings_widgets.dart';

class BarcodeConf extends ChangeNotifier {
  BarcodeType _type = BarcodeType.Code128;
  BarcodeType get type => _type;
  set type(BarcodeType value) {
    _type = value;
    notifyListeners();
  }

  String _data = 'HELLO';
  String get data => _data;
  set data(String value) {
    _data = value;
    notifyListeners();
  }

  double fontSize = 13;

  double height = 80;

  double width = 200;
}

class Settings extends StatelessWidget {
  Settings(this.conf);

  final BarcodeConf conf;

  @override
  Widget build(BuildContext context) {
    final types = <BarcodeType, String>{};
    for (var item in BarcodeType.values) {
      types[item] = Barcode.fromType(item).name;
    }

    return Column(
      children: <Widget>[
        DropdownPreference<BarcodeType>(
          title: 'Barcode Type',
          onRead: (context) => conf.type,
          onWrite: (context, value) => conf.type = value,
          values: types,
        ),
        TextPreference(
          title: 'Data',
          onRead: (context) => conf.data,
          onWrite: (context, value) => conf.data = value,
        )
      ],
    );
  }
}
