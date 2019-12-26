// ignore_for_file: always_specify_types

import 'package:barcode/barcode.dart';

class MyBarcodeDraw extends BarcodeDraw {
  @override
  void fillRect(
      double left, double top, double width, double height, bool black) {
    print('BAR $left, $top, $width, $height, $black');
  }
}

void main() {
  final bc = Barcode.code39(draw: MyBarcodeDraw());
  bc.make('HELLO 123', 200, 50);
}
