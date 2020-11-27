/*
 * Copyright (C) 2020, David PHAM-VAN <dev.nfet.net@gmail.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'dart:convert';
import 'dart:typed_data';

import 'package:barcode/barcode.dart';
import 'package:image/image.dart';

/// Store the width and height of a rendered text
class BitmapFontMetrics {
  /// Create a BitmapFontMetrics structure
  const BitmapFontMetrics(this.width, this.height);

  /// The width of the text in pixels
  final int width;

  /// The height of the text in pixels
  final int height;
}

/// Extension on BitmapFont to add metrics calculation
extension BitmapFontMetricsFunctions on BitmapFont {
  /// Calculate the width and height in pixels of a text string
  BitmapFontMetrics getMetrics(String string) {
    if (string.isEmpty) {
      return const BitmapFontMetrics(0, 0);
    }

    var width = 0;
    var height = 0;
    final cu = string.codeUnits;

    for (var c in cu.sublist(0, cu.length - 1)) {
      if (!characters.containsKey(c)) {
        continue;
      }

      final ch = characters[c]!;
      width += ch.xadvance;
      if (height < ch.height + ch.yoffset) {
        height = ch.height + ch.yoffset;
      }
    }

    final c = cu.last;
    if (characters.containsKey(c)) {
      final ch = characters[c]!;
      width += ch.width;
      if (height < ch.height + ch.yoffset) {
        height = ch.height + ch.yoffset;
      }
    }

    return BitmapFontMetrics(width, height);
  }
}

/// Create a Barcode
void drawBarcode(
  Image image,
  Barcode barcode,
  String data, {
  int x = 0,
  int y = 0,
  int? width,
  int? height,
  BitmapFont? font,
  int? textPadding,
  int color = 0xff000000,
}) {
  drawBarcodeBytes(
    image,
    barcode,
    utf8.encoder.convert(data),
    x: x,
    y: y,
    width: width,
    height: height,
    font: font,
    textPadding: textPadding,
    color: color,
  );
}

/// Create a Barcode
void drawBarcodeBytes(
  Image image,
  Barcode barcode,
  Uint8List bytes, {
  int x = 0,
  int y = 0,
  int? width,
  int? height,
  BitmapFont? font,
  int? textPadding,
  int color = 0xff000000,
}) {
  width ??= image.width;
  height ??= image.height;
  textPadding ??= 0;

  // Draw the barcode
  for (var elem in barcode.makeBytes(
    bytes,
    width: width.toDouble(),
    height: height.toDouble(),
    drawText: font != null,
    fontHeight: font?.lineHeight?.toDouble(),
    textPadding: textPadding.toDouble(),
  )) {
    if (elem is BarcodeBar) {
      if (elem.black) {
        // Draw one black bar
        fillRect(
          image,
          (x + elem.left).round(),
          (y + elem.top).round(),
          (x + elem.right).round(),
          (y + elem.bottom).round(),
          color,
        );
      }
    } else if (elem is BarcodeText) {
      // Get string dimensions
      final metrics = font!.getMetrics(elem.text);
      final top = y + elem.top + elem.height - font.size;
      late double left;

      // Center the text
      switch (elem.align) {
        case BarcodeTextAlign.left:
          left = x + elem.left;
          break;
        case BarcodeTextAlign.center:
          left = x + elem.left + (elem.width - metrics.width) / 2;
          break;
        case BarcodeTextAlign.right:
          left = x + elem.left + elem.width - metrics.width;
          break;
      }

      // Draw some text using 14pt arial font
      drawString(
        image,
        font,
        left.round(),
        top.round(),
        elem.text,
        color: color,
      );
    }
  }
}
