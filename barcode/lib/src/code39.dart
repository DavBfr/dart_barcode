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

import 'package:barcode/src/barcode_operations.dart';

import 'barcode.dart';
import 'barcode_exception.dart';
import 'barcode_maps.dart';

class BarcodeCode39 extends Barcode {
  const BarcodeCode39();

  @override
  Iterable<int> get charSet => BarcodeMaps.code39.keys;

  @override
  String get name => 'CODE 39';

  @override
  Iterable<bool> convert(String data) sync* {
    yield* add(_startStop, _codeLen);

    for (int code in data.codeUnits) {
      final int codeValue = BarcodeMaps.code39[code];
      if (codeValue == null) {
        throw BarcodeException(
            'Unable to encode "${String.fromCharCode(code)}" to $name Barcode');
      }
      yield* add(codeValue, _codeLen);
    }

    yield* add(_startStop, _codeLen);
  }

  @override
  Iterable<BarcodeText> makeText(
    String data,
    double width,
    double height,
    double fontHeight,
  ) sync* {
    final String text = '*$data*';
    final double lineWidth = width / (text.length * _codeLen);

    for (int i = 0; i < text.length; i++) {
      yield BarcodeText(
        left: lineWidth * _codeLen * i,
        top: height - fontHeight,
        width: lineWidth * _codeLen,
        height: fontHeight,
        text: text[i],
      );
    }
  }

  static const int _startStop = 0xb69;

  static const int _codeLen = 13;
}
