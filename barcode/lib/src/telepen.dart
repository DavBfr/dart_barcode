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

import 'barcode_1d.dart';
import 'barcode_exception.dart';
import 'barcode_maps.dart';

class BarcodeTelepen extends Barcode1D {
  const BarcodeTelepen();

  @override
  Iterable<int> get charSet => Iterable<int>.generate(128);

  @override
  String get name => 'Telepen';

  @override
  Iterable<bool> convert(String data) sync* {
    // Start
    yield* add(
      BarcodeMaps.telepen[BarcodeMaps.telepenStart],
      BarcodeMaps.telepenLen,
    );

    int checksum = 0;

    for (int code in data.codeUnits) {
      final int codeValue = BarcodeMaps.telepen[code];
      if (codeValue == null) {
        throw BarcodeException(
            'Unable to encode "${String.fromCharCode(code)}" to $name Barcode');
      }
      yield* add(codeValue, BarcodeMaps.telepenLen);
      checksum += codeValue;
    }

    // Checksum
    checksum = 127 - (checksum % 127);
    if (checksum == 127) {
      checksum = 0;
    }
    yield* add(
      BarcodeMaps.telepen[checksum],
      BarcodeMaps.telepenLen,
    );

    // Stop
    yield* add(
      BarcodeMaps.telepen[BarcodeMaps.telepenEnd],
      BarcodeMaps.telepenLen,
    );
  }
}
