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

// ignore_for_file: omit_local_variable_types

import 'package:barcode/barcode.dart';
import 'package:image/image.dart';

class BitmapFontMetrics {
  const BitmapFontMetrics(this.width, this.height);

  final int width;
  final int height;
}

extension BitmapFontMetricsFunctions on BitmapFont {
  BitmapFontMetrics getMetrics(String string) {
    if (string.isEmpty) {
      return const BitmapFontMetrics(0, 0);
    }

    int width = 0;
    int height = 0;
    final List<int> cu = string.codeUnits;

    for (int c in cu.sublist(0, cu.length - 1)) {
      if (!characters.containsKey(c)) {
        continue;
      }

      final BitmapFontCharacter ch = characters[c];
      width += ch.xadvance;
      if (height < ch.height + ch.yoffset) {
        height = ch.height + ch.yoffset;
      }
    }

    final int c = cu.last;
    if (characters.containsKey(c)) {
      final BitmapFontCharacter ch = characters[c];
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
  int width,
  int height,
  BitmapFont font,
  int color = 0xff000000,
}) {
  width ??= image.width;
  height ??= image.height;

  // Draw the barcode
  for (BarcodeElement elem in barcode.make(
    data,
    width: width.toDouble(),
    height: height.toDouble(),
    drawText: font != null,
    fontHeight: font != null ? font.lineHeight.toDouble() : null,
  )) {
    if (elem is BarcodeBar) {
      if (elem.black) {
        // Draw one black bar
        fillRect(
          image,
          (x + elem.left).round(),
          elem.top.round(),
          (y + elem.right - 1).round(),
          (elem.bottom - 1).round(),
          color,
        );
      }
    } else if (elem is BarcodeText) {
      // Get string dimensions
      final BitmapFontMetrics metrics = font.getMetrics(elem.text);
      final double top = y + elem.top + elem.height - font.size;
      double left;

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
