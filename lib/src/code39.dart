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

class BarcodeCode39 extends Barcode {
  BarcodeCode39({
    BarcodeDraw draw,
  }) : super(draw);

  void _drawMatrix(int data, int position, double lineWidth, double height) {
    for (int i = 0; i < 12; i++) {
      draw.fillRect(
        (13 * position + i) * lineWidth,
        0,
        lineWidth,
        height,
        (0x800 & (data << i)) == 0x800,
      );
    }
  }

  @override
  void make(String data, double width, double height) {
    final double lineWidth = width / (26 + 13 * data.length);

    _drawMatrix(_matrix[0], 0, lineWidth, height);

    int index = 1;
    for (int code in data.codeUnits) {
      final int codeValue = _matrix[code];
      if (codeValue == null) {
        throw BarcodeException(
            'Unable to encode "${String.fromCharCode(code)}" to CODE 39 Barcode');
      }
      _drawMatrix(codeValue, index, lineWidth, height);
      index++;
    }

    _drawMatrix(_matrix[0], index, lineWidth, height);
  }

  static const Map<int, int> _matrix = <int, int>{
    0: 0x96d, // <start/end>
    48: 0xa6d, // 0
    49: 0xd2b, // 1
    50: 0xb2b, // 2
    51: 0xd95, // 3
    52: 0xa6b, // 4
    53: 0xd35, // 5
    54: 0xb35, // 6
    55: 0xa5b, // 7
    56: 0xd2d, // 8
    57: 0xb2d, // 9
    65: 0xd4b, // A
    66: 0xb4b, // B
    67: 0xda5, // C
    68: 0xacb, // D
    69: 0xd65, // E
    70: 0xb65, // F
    71: 0xa9b, // G
    72: 0xd4d, // H
    73: 0xb4d, // I
    74: 0xacd, // J
    75: 0xd53, // K
    76: 0xb53, // L
    77: 0xda9, // M
    78: 0xad3, // N
    79: 0xd69, // O
    80: 0xb69, // P
    81: 0xab3, // Q
    82: 0xd59, // R
    83: 0xb59, // S
    84: 0xad9, // T
    85: 0xcab, // U
    86: 0x9ab, // V
    87: 0xcd5, // W
    88: 0x96b, // X
    89: 0xcb5, // Y
    90: 0x9b5, // Z
    45: 0x95b, // -
    46: 0xcad, // .
    32: 0x9ad, // <space>
    36: 0x925, // $
    47: 0x929, // /
    43: 0x949, // +
    37: 0xa49, // %
  };
}
