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

import 'barcode_exception.dart';
import 'barcode_maps.dart';
import 'barcode_operations.dart';
import 'ean.dart';

class BarcodeUpcA extends BarcodeEan {
  const BarcodeUpcA();

  @override
  String get name => 'UPC A';

  @override
  int get minLength => 11;

  @override
  int get maxLength => 12;

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

    int index = 0;
    for (int code in data.codeUnits) {
      final List<int> codes = BarcodeMaps.ean[code];

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
  double marginLeft(bool drawText, double width, double fontHeight) {
    if (!drawText) {
      return 0;
    }

    return fontHeight;
  }

  @override
  double marginRight(bool drawText, double width, double fontHeight) {
    if (!drawText) {
      return 0;
    }

    return fontHeight;
  }

  @override
  double getHeight(
    int index,
    int count,
    double height,
    double fontHeight,
    bool drawText,
  ) {
    if (!drawText) {
      return super.getHeight(index, count, height, fontHeight, drawText);
    }

    final double h = height - fontHeight;

    if (index + count < 11 || (index > 45 && index < 49) || index > 82) {
      return h + fontHeight / 2;
    }

    return h;
  }

  @override
  Iterable<BarcodeText> makeText(
    String data,
    double width,
    double height,
    double fontHeight,
    double lineWidth,
  ) sync* {
    final String text = checkLength(data, maxLength);
    final double w = lineWidth * 7;
    final double left = marginLeft(true, width, fontHeight);
    final double right = marginRight(true, width, fontHeight);

    yield BarcodeText(
      left: 0,
      top: height - fontHeight,
      width: left - lineWidth,
      height: fontHeight,
      text: text[0],
      align: BarcodeTextAlign.right,
    );

    double offset = left + lineWidth * 10;

    for (int i = 1; i < text.length - 1; i++) {
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
