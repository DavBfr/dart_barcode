// ignore_for_file: always_specify_types

import 'dart:io';

import 'package:barcode/barcode.dart';

void buildBarcode(Barcode bc, String data, {String filename, double width}) {
  /// Create the Barcode
  final svg = bc.toSvg(data, width: width ?? 200);

  // Save the image
  filename ??= bc.name.replaceAll(RegExp(r'\s'), '-').toLowerCase();
  File('$filename.svg').writeAsStringSync(svg);
}

void main() {
  buildBarcode(
    Barcode.code39(),
    'CODE 39',
  );

  buildBarcode(
    Barcode.code93(),
    'CODE 93',
  );

  buildBarcode(
    Barcode.code128(useCode128B: false, useCode128C: false),
    'BARCODE\t128',
    filename: 'code-128a',
  );

  buildBarcode(
    Barcode.code128(useCode128A: false, useCode128C: false),
    'Barcode 128',
    filename: 'code-128b',
  );

  buildBarcode(
    Barcode.code128(useCode128A: false, useCode128B: false),
    '0123456789',
    filename: 'code-128c',
  );

  buildBarcode(
    Barcode.ean13(),
    '590123412345',
  );

  buildBarcode(
    Barcode.ean8(),
    '9638507',
    width: 100,
  );

  buildBarcode(
    Barcode.ean2(),
    '05',
    width: 40,
  );

  buildBarcode(
    Barcode.isbn(),
    '978316148410',
  );

  buildBarcode(
    Barcode.upcA(),
    '98765432109',
  );

  buildBarcode(
    Barcode.upcE(),
    '06510000432',
    width: 100,
  );
}
