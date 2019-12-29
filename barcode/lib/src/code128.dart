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
import 'barcode_maps.dart';

class BarcodeCode128 extends Barcode {
  const BarcodeCode128();

  @override
  Iterable<int> get charSet =>
      BarcodeMaps.code128B.keys.where((int x) => x > 0);

  @override
  String get name => 'CODE 128';

  @override
  Iterable<bool> convert(String data) sync* {
    final List<int> checksum = <int>[];
    // Start
    yield* add(BarcodeMaps.code128[BarcodeMaps.code128StartCodeB],
        BarcodeMaps.code128Len);
    checksum.add(BarcodeMaps.code128StartCodeB);

    for (int code in data.codeUnits) {
      final int codeIndex = BarcodeMaps.code128B[code];
      if (codeIndex == null) {
        throw BarcodeException(
            'Unable to encode "${String.fromCharCode(code)}" to $name Barcode');
      }

      final int codeValue = BarcodeMaps.code128[codeIndex];
      if (codeValue == null) {
        throw BarcodeException(
            'Unable to encode "${String.fromCharCode(code)}" to $name Barcode');
      }
      yield* add(codeValue, BarcodeMaps.code128Len);
      checksum.add(codeIndex);
    }

    // Checksum
    int sum = 0;
    for (int index = 0; index < checksum.length; index++) {
      final int code = checksum[index];
      final int mul = index == 0 ? 1 : index;
      sum += code * mul;
    }
    sum = sum % 103;
    yield* add(BarcodeMaps.code128[sum], BarcodeMaps.code128Len);

    // Stop
    yield* add(
        BarcodeMaps.code128[BarcodeMaps.code128Stop], BarcodeMaps.code128Len);

    // Termination Bars
    yield true;
    yield true;
  }
}
