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

/// UPC-A Barcode
///
/// The Universal Product Code is a barcode symbology that is widely used in
/// the United States, Canada, Europe, Australia, New Zealand, and other
/// countries for tracking trade items in stores. UPC consists of 12 numeric
/// digits that are uniquely assigned to each trade item.
class BarcodeUpcA extends BarcodeEan {
  /// Create an UPC-A Barcode
  const BarcodeUpcA();

  @override
  String get name => 'UPC A';

  @override
  int get minLength => 11;

  @override
  int get maxLength => 12;

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

      if (index == 6) {
        yield* add(BarcodeMaps.eanCenter, 5);
      }

      yield* add(codes[index < 6 ? 0 : 2], 7);
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
  ) {
    if (!drawText) {
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
  ) {
    if (!drawText) {
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
    bool drawText,
  ) {
    if (!drawText) {
      return super.getHeight(index, count, width, height, fontHeight, drawText);
    }

    final h = height - fontHeight;

    if (index + count < 11 || (index > 45 && index < 49) || index > 82) {
      return h + fontHeight / 2;
    }

    return h;
  }

  @override
  Iterable<BarcodeElement> makeText(
    String data,
    double width,
    double height,
    double fontHeight,
    double lineWidth,
  ) sync* {
    final text = checkLength(data, maxLength);
    final w = lineWidth * 7;
    final left = marginLeft(true, width, height, fontHeight);
    final right = marginRight(true, width, height, fontHeight);

    yield BarcodeText(
      left: 0,
      top: height - fontHeight,
      width: left - lineWidth,
      height: fontHeight,
      text: text[0],
      align: BarcodeTextAlign.right,
    );

    var offset = left + lineWidth * 10;

    for (var i = 1; i < text.length - 1; i++) {
      yield BarcodeText(
        left: offset,
        top: height - fontHeight,
        width: w,
        height: fontHeight,
        text: text[i],
        align: BarcodeTextAlign.center,
      );

      offset += w;
      if (i == 5) {
        offset += lineWidth * 5;
      }
    }

    yield BarcodeText(
      left: width - right + lineWidth,
      top: height - fontHeight,
      width: right - lineWidth,
      height: fontHeight,
      text: text[text.length - 1],
      align: BarcodeTextAlign.left,
    );
  }
}
