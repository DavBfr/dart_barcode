// ignore_for_file: always_specify_types

import 'dart:io';

import 'package:barcode_image/barcode_image.dart';
import 'package:image/image.dart';

void main() {
  // Create an image
  final image = Image(width: 600, height: 350);

  // Fill it with a solid color (white)
  fill(image, color: ColorRgb8(255, 255, 255));

  // Draw the barcode
  drawBarcode(image, Barcode.code128(), 'Test', font: arial24);

  // Save the image
  File('barcode.png').writeAsBytesSync(encodePng(image));
}
