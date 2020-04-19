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
import 'ean2.dart';

/// EAN 5 Barcode Generator
class BarcodeEan5 extends BarcodeEan2 {
  /// EAN 5 Barcode Generator
  const BarcodeEan5();

  @override
  String get name => 'EAN 5';

  @override
  int get minLength => 5;

  @override
  int get maxLength => 5;

  @override
  String checkSumModulo10(String data) {
    int sum = 0;
    int fak = data.length;
    for (int c in data.codeUnits) {
      if (fak % 2 == 0) {
        sum += (c - 0x30) * 9;
      } else {
        sum += (c - 0x30) * 3;
      }
      fak--;
    }
    return String.fromCharCode((sum % 10) + 0x30);
  }

  @override
  Iterable<bool> convert(String data) sync* {
    verify(data);
    final String checksum = checkSumModulo10(data);
    final int pattern = BarcodeMaps.ean5Checksum[checksum.codeUnitAt(0)];

    // Start
    yield* add(BarcodeMaps.eanStartEan2, 5);

    int index = 0;
    for (int code in data.codeUnits) {
      final List<int> codes = BarcodeMaps.ean[code];

      if (codes == null) {
        throw BarcodeException(
            'Unable to encode "${String.fromCharCode(code)}" to $name Barcode');
      }

      if (index >= 1) {
        yield* add(BarcodeMaps.eanCenterEan2, 2);
      }

      yield* add(codes[(pattern >> index) & 1], 7);
      index++;
    }
  }
}
