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

import 'barcode_exception.dart';
import 'barcode_maps.dart';
import 'barcode_operations.dart';
import 'ean.dart';

/// EAN 13 Barcode
///
/// The International Article Number is a standard describing a barcode
/// symbology and numbering system used in global trade to identify a specific
/// retail product type, in a specific packaging configuration,
/// from a specific manufacturer.
class BarcodeEan13 extends BarcodeEan {
  /// Create an EAN 13 Barcode
  const BarcodeEan13(this.drawEndChar);

  /// Draw the end char '>' in the right margin
  final bool drawEndChar;

  static const String _finalSpacer = '>';

  @override
  String get name => 'EAN 13';

  @override
  int get minLength => 12;

  @override
  int get maxLength => 13;

  @override
  void verify(String data) {
    checkLength(data, maxLength);
    super.verify(data);
  }

  @override
  Iterable<bool> convert(String data) sync* {
    data = checkLength(data, maxLength);

    // Start
    yield* add(BarcodeMaps.eanStartEnd, 3);

    var index = 0;
    final first = BarcodeMaps.eanFirst[data.codeUnits.first];
    if (first == null) {
      throw BarcodeException(
          'Unable to encode "${String.fromCharCode(data.codeUnits.first)}" to $name Barcode');
    }

    for (var code in data.codeUnits.sublist(1)) {
      final codes = BarcodeMaps.ean[code];

      if (codes == null) {
        throw BarcodeException(
            'Unable to encode "${String.fromCharCode(code)}" to $name Barcode');
      }

      if (index == 6) {
        yield* add(BarcodeMaps.eanCenter, 5);
      }

      if (index < 6) {
        yield* add(codes[(first >> index) & 1], 7);
      } else {
        yield* add(codes[2], 7);
      }

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
    if (!drawText || !drawEndChar) {
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

    if (index < 3 || (index > 45 && index < 49) || index > 91) {
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

    var offset = left + lineWidth * 3;

    for (var i = 1; i < text.length; i++) {
      yield BarcodeText(
        left: offset,
        top: height - fontHeight,
        width: w,
        height: fontHeight,
        text: text[i],
        align: BarcodeTextAlign.center,
      );

      offset += w;
      if (i == 6) {
        offset += lineWidth * 5;
      }
    }

    if (drawEndChar) {
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
