// ignore_for_file: always_specify_types

// @dart=2.9

import 'dart:io';

import 'package:barcode_image/barcode_image.dart';
import 'package:image/image.dart';

void main() {
  // Create an image
  final image = Image(600, 350);

  // Fill it with a solid color (white)
  fill(image, getColor(255, 255, 255));

  // Draw the barcode
  drawBarcode(image, Barcode.code128(), 'Test', font: arial_24);

  // Save the image
  File('barcode.png').writeAsBytesSync(encodePng(image));
}
