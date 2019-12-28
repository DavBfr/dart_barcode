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

void main() {
  // Create a Barcode
  final bc = Barcode.code39();

  // Create an image
  final image = Image(660, 150);

  // Fill it with a solid color (white)
  fill(image, getColor(255, 255, 255));

  final font = arial_24;

  // Without margin, the readers can't read the code
  const margin = 30;

  // Draw the barcode
  for (var elem in bc.make(
    'HELLO 123',
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
  File('barcode.png').writeAsBytesSync(encodePng(image));
}
