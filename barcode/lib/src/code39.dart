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

import 'package:barcode/src/barcode_operations.dart';

import 'barcode_1d.dart';
import 'barcode_exception.dart';
import 'barcode_maps.dart';

/// Code 39 [Barcode]
///
/// The Code 39 specification defines 43 characters, consisting of uppercase
/// letters (A through Z), numeric digits (0 through 9) and a number of special
/// characters (-, ., \$, /, +, %, and space).
///
/// An additional character (denoted '*') is used for both start and stop
/// delimiters.
class BarcodeCode39 extends Barcode1D {
  /// Create a code 39 Barcode
  const BarcodeCode39();

  @override
  Iterable<int> get charSet => BarcodeMaps.code39.keys;

  @override
  String get name => 'CODE 39';

  @override
  Iterable<bool> convert(String data) sync* {
    yield* add(BarcodeMaps.code39StartStop, BarcodeMaps.code39Len);

    for (var code in data.codeUnits) {
      final codeValue = BarcodeMaps.code39[code];
      if (codeValue == null) {
        throw BarcodeException(
            'Unable to encode "${String.fromCharCode(code)}" to $name Barcode');
      }
      yield* add(codeValue, BarcodeMaps.code39Len);
    }

    yield* add(BarcodeMaps.code39StartStop, BarcodeMaps.code39Len);
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
    final text = '*$data*';

    for (var i = 0; i < text.length; i++) {
      yield BarcodeText(
        left: lineWidth * BarcodeMaps.code39Len * i,
        top: height - fontHeight,
        width: lineWidth * BarcodeMaps.code39Len,
        height: fontHeight,
        text: text[i],
        align: BarcodeTextAlign.center,
      );
    }
  }
}
