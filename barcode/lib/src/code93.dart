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

import 'barcode.dart';
import 'barcode_exception.dart';

class BarcodeCode93 extends Barcode {
  const BarcodeCode93();

  @override
  Iterable<int> get charSet => _matrix.keys.where((int x) => x > 0);

  @override
  String get name => 'CODE 93';

  @override
  Iterable<bool> convert(String data) sync* {
    // Start
    yield* add(_startStop, _codeLen);

    final List<int> keys = _matrix.keys.toList();

    for (int code in data.codeUnits) {
      final int codeValue = _matrix[code];
      if (codeValue == null) {
        throw BarcodeException(
            'Unable to encode "${String.fromCharCode(code)}" to $name Barcode');
      }
      yield* add(codeValue, _codeLen);
    }

    // Checksum
    int sumC = 0;
    int sumK = 0;
    int indexC = 1;
    int indexK = 2;

    for (int index = data.codeUnits.length - 1; index >= 0; index--) {
      final int code = data.codeUnits[index];
      sumC += keys.indexOf(code) * indexC;
      sumK += keys.indexOf(code) * indexK;

      indexC++;
      if (indexC > 20) {
        indexC = 1;
      }
      indexK++;
      if (indexK > 15) {
        indexK = 1;
      }
    }

    sumC = sumC % 47;
    yield* add(_matrix[keys[sumC]], _codeLen);

    sumK = (sumK + sumC) % 47;
    yield* add(_matrix[keys[sumK]], _codeLen);

    // Stop
    yield* add(_startStop, _codeLen);

    // Termination Bar
    yield true;
  }

  /// Code 93 conversion bits
  static const Map<int, int> _matrix = <int, int>{
    0x30: 0x51, // 0
    0x31: 0x25, // 1
    0x32: 0x45, // 2
    0x33: 0x85, // 3
    0x34: 0x29, // 4
    0x35: 0x49, // 5
    0x36: 0x89, // 6
    0x37: 0x15, // 7
    0x38: 0x91, // 8
    0x39: 0xa1, // 9
    0x41: 0x2b, // A
    0x42: 0x4b, // B
    0x43: 0x8b, // C
    0x44: 0x53, // D
    0x45: 0x93, // E
    0x46: 0xa3, // F
    0x47: 0x2d, // G
    0x48: 0x4d, // H
    0x49: 0x8d, // I
    0x4a: 0x59, // J
    0x4b: 0xb1, // K
    0x4c: 0x35, // L
    0x4d: 0x65, // M
    0x4e: 0xc5, // N
    0x4f: 0x69, // O
    0x50: 0xd1, // P
    0x51: 0x5b, // Q
    0x52: 0x9b, // R
    0x53: 0x97, // S
    0x54: 0xcb, // T
    0x55: 0xd3, // U
    0x56: 0xb3, // V
    0x57: 0x6d, // W
    0x58: 0xcd, // X
    0x59: 0xd9, // Y
    0x5a: 0xb9, // Z
    0x2d: 0xe9, // -
    0x2e: 0x57, // .
    0x20: 0x97, //
    0x24: 0xa7, // $
    0x2f: 0xed, // /
    0x2b: 0xdd, // +
    0x25: 0xeb, // %
    -0x24: 0xc9, // ($)
    -0x25: 0xb7, // (%)
    -0x2f: 0xd7, // (/)
    -0x2b: 0x99, // (+)
  };

  static const int _startStop = 0xf5;

  static const int _codeLen = 9;
}
