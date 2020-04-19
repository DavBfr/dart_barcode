import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';

import 'settings_widgets.dart';

/// Barcode configuration
class BarcodeConf extends ChangeNotifier {
  BarcodeType _type = BarcodeType.Code128;

  /// Barcode type
  BarcodeType get type => _type;
  set type(BarcodeType value) {
    _type = value;
    notifyListeners();
  }

  String _data = 'HELLO';

  /// Data to encode
  String get data => _data;
  set data(String value) {
    _data = value;
    notifyListeners();
  }

  /// Size of the font
  double fontSize = 30;

  /// height of the barcode
  double height = 160;

  /// width of the barcode
  double width = 400;
}

/// Settings widget
class Settings extends StatelessWidget {
  /// Manage the barcode settings
  const Settings(this.conf);

  /// Barcode configuration
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
          onWrite: (context, dynamic value) => conf.type = value,
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
