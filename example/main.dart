// ignore_for_file: always_specify_types

import 'package:barcode/barcode.dart';

void main() {
  final bc = Barcode.code39();
  for (var elem in bc.make('HELLO 123', 200, 50, 10)) {
    if (elem is BarcodeText) {
      print(elem.text);
    }
  }
}
