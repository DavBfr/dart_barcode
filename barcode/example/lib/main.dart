// ignore_for_file: always_specify_types

import 'dart:io';

import 'package:barcode/barcode.dart';
import 'package:image/image.dart';

int getStringWidth(BitmapFont font, String string) {
  var stringWidth = 0;
  final chars = string.codeUnits;

  for (var c in chars) {
    if (!font.characters.containsKey(c)) {
      continue;
    }

    final ch = font.characters[c];
    stringWidth += ch.xadvance;
  }

  return stringWidth;
}

/// Create a Barcode
void buildBarcode(Barcode bc, String data, [String filename]) {
  // Create an image
  final image = Image(660, 150);

  // Fill it with a solid color (white)
  fill(image, getColor(255, 255, 255));

  final font = arial_24;

  // Without margin, the readers can't read the code
  const margin = 30;

  // Draw the barcode
  for (var elem in bc.make(
    data,
    width: image.width.toDouble() - margin * 2,
    height: image.height.toDouble(),
    drawText: true,
    fontHeight: font.lineHeight.toDouble(),
  )) {
    if (elem is BarcodeBar) {
      if (elem.black) {
        // Draw one black bar
        fillRect(
          image,
          margin + elem.left.toInt(),
          elem.top.toInt(),
          margin + elem.right.toInt(),
          elem.bottom.toInt(),
          getColor(0, 0, 0),
        );
      }
    } else if (elem is BarcodeText) {
      // Center the text
      final left = margin +
          elem.left +
          (elem.width - getStringWidth(font, elem.text)) / 2;

      // Draw some text using 14pt arial font
      drawString(
        image,
        font,
        left.toInt(),
        elem.top.toInt() + 4,
        elem.text,
        color: getColor(0, 0, 0),
      );
    }
  }

  // Save the image to disk as a PNG
  filename ??= bc.name.replaceAll(RegExp(r'\s'), '-').toLowerCase();
  File('$filename.png').writeAsBytesSync(encodePng(image));
}

void main() {
  buildBarcode(Barcode.code39(), 'CODE 39');
  buildBarcode(Barcode.code93(), 'CODE 93');
  buildBarcode(Barcode.code128(useCode128B: false, useCode128C: false),
      'BARCODE\t128', 'code-128a');
  buildBarcode(Barcode.code128(useCode128A: false, useCode128C: false),
      'Barcode 128', 'code-128b');
  buildBarcode(Barcode.code128(useCode128A: false, useCode128B: false),
      '0123456789', 'code-128c');
  buildBarcode(Barcode.ean13(), '590123412345');
  buildBarcode(Barcode.ean8(), '9638507');
  buildBarcode(Barcode.isbn(), '978316148410');
  buildBarcode(Barcode.upcA(), '98765432109');
  buildBarcode(Barcode.upcE(), '06510000432');
}
