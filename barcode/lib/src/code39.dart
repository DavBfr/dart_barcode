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

class BarcodeCode39 extends Barcode {
  const BarcodeCode39();

  @override
  Iterable<int> get charSet => _matrix.keys;

  @override
  String get name => 'CODE 39';

  @override
  Iterable<bool> convert(String data) sync* {
    yield* add(_startStop, _codeLen);

    for (int code in data.codeUnits) {
      final int codeValue = _matrix[code];
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

  /// Code 39 conversion bits
  static const Map<int, int> _matrix = <int, int>{
    0x30: 0xb65, // 0
    0x31: 0xd4b, // 1
    0x32: 0xd4d, // 2
    0x33: 0xa9b, // 3
    0x34: 0xd65, // 4
    0x35: 0xacb, // 5
    0x36: 0xacd, // 6
    0x37: 0xda5, // 7
    0x38: 0xb4b, // 8
    0x39: 0xb4d, // 9
    0x41: 0xd2b, // A
    0x42: 0xd2d, // B
    0x43: 0xa5b, // C
    0x44: 0xd35, // D
    0x45: 0xa6b, // E
    0x46: 0xa6d, // F
    0x47: 0xd95, // G
    0x48: 0xb2b, // H
    0x49: 0xb2d, // I
    0x4a: 0xb35, // J
    0x4b: 0xcab, // K
    0x4c: 0xcad, // L
    0x4d: 0x95b, // M
    0x4e: 0xcb5, // N
    0x4f: 0x96b, // O
    0x50: 0x96d, // P
    0x51: 0xcd5, // Q
    0x52: 0x9ab, // R
    0x53: 0x9ad, // S
    0x54: 0x9b5, // T
    0x55: 0xd53, // U
    0x56: 0xd59, // V
    0x57: 0xab3, // W
    0x58: 0xd69, // X
    0x59: 0xad3, // Y
    0x5a: 0xad9, // Z
    0x2d: 0xda9, // -
    0x2e: 0xb53, // .
    0x20: 0xb59, //
    0x24: 0xa49, // $
    0x2f: 0x949, // /
    0x2b: 0x929, // +
    0x25: 0x925, // %
  };

  static const int _startStop = 0xb69;

  static const int _codeLen = 13;
}
