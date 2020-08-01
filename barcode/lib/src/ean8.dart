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

import 'barcode_exception.dart';
import 'barcode_maps.dart';
import 'barcode_operations.dart';
import 'ean.dart';

/// EAN 8 Barcode
///
/// An EAN-8 is an EAN/UPC symbology barcode and is derived from the longer
/// International Article Number code. It was introduced for use on small
/// packages where an EAN-13 barcode would be too large; for example on
/// cigarettes, pencils, and chewing gum packets. It is encoded identically
/// to the 12 digits of the UPC-A barcode, except that it has 4 digits in
/// each of the left and right halves.
class BarcodeEan8 extends BarcodeEan {
  /// Create an EAN 8 Barcode
  const BarcodeEan8(this.drawSpacers);

  /// Draw the start '<' and end '>' chars in the left and right margins
  final bool drawSpacers;

  static const String _startSpacer = '<';

  static const String _finalSpacer = '>';

  @override
  String get name => 'EAN 8';

  @override
  int get minLength => 7;

  @override
  int get maxLength => 8;

  @override
  void verifyBytes(Uint8List data) {
    final text = utf8.decoder.convert(data);
    checkLength(text, maxLength);
    super.verifyBytes(data);
  }

  @override
  Iterable<bool> convert(String data) sync* {
    data = checkLength(data, maxLength);

    // Start
    yield* add(BarcodeMaps.eanStartEnd, 3);

    var index = 0;
    for (var code in data.codeUnits) {
      final codes = BarcodeMaps.ean[code];

      if (codes == null) {
        throw BarcodeException(
            'Unable to encode "${String.fromCharCode(code)}" to $name Barcode');
      }

      if (index == 4) {
        yield* add(BarcodeMaps.eanCenter, 5);
      }

      yield* add(codes[index < 4 ? 0 : 2], 7);
      index++;
    }

    // Stop
    yield* add(BarcodeMaps.eanStartEnd, 3);
  }

  @override
  double marginLeft(
    bool drawText,
    double width,
    double height,
    double fontHeight,
    double textPadding,
  ) {
    if (!drawText || !drawSpacers) {
      return 0;
    }

    return fontHeight;
  }

  @override
  double marginRight(
    bool drawText,
    double width,
    double height,
    double fontHeight,
    double textPadding,
  ) {
    if (!drawText || !drawSpacers) {
      return 0;
    }

    return fontHeight;
  }

  @override
  double getHeight(
    int index,
    int count,
    double width,
    double height,
    double fontHeight,
    double textPadding,
    bool drawText,
  ) {
    if (!drawText) {
      return super.getHeight(
        index,
        count,
        width,
        height,
        fontHeight,
        textPadding,
        drawText,
      );
    }

    final h = height - fontHeight - textPadding;

    if (index + count < 4 || (index > 31 && index + count < 36) || index > 63) {
      return h + fontHeight / 2 + textPadding;
    }

    return h;
  }

  @override
  Iterable<BarcodeElement> makeText(
    String data,
    double width,
    double height,
    double fontHeight,
    double textPadding,
    double lineWidth,
  ) sync* {
    data = checkLength(data, maxLength);
    final w = lineWidth * 7;
    final left = marginLeft(true, width, height, fontHeight, textPadding);
    final right = marginRight(true, width, height, fontHeight, textPadding);
    var offset = left + lineWidth * 3;

    for (var i = 0; i < data.length; i++) {
      yield BarcodeText(
        left: offset,
        top: height - fontHeight,
        width: w,
        height: fontHeight,
        text: data[i],
        align: BarcodeTextAlign.center,
      );

      offset += w;
      if (i == 3) {
        offset += lineWidth * 5;
      }
    }

    if (drawSpacers) {
      yield BarcodeText(
        left: 0,
        top: height - fontHeight,
        width: left - lineWidth,
        height: fontHeight,
        text: _startSpacer,
        align: BarcodeTextAlign.right,
      );
      yield BarcodeText(
        left: width - right + lineWidth,
        top: height - fontHeight,
        width: right - lineWidth,
        height: fontHeight,
        text: _finalSpacer,
        align: BarcodeTextAlign.left,
      );
    }
  }
}
