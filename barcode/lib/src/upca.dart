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
import 'ean13.dart';

class BarcodeUpcA extends BarcodeEan13 {
  const BarcodeUpcA();

  @override
  String get name => 'UPC A';

  @override
  Iterable<bool> convert(String data) sync* {
    if (data.length == 11) {
      data += checkSumModulo10(data);
    } else {
      if (data.length != 12) {
        throw BarcodeException(
            'Unable to encode "$data" to $name Barcode, it is not 12 digits');
      }
      final String last = data.substring(11);
      final String checksum = checkSumModulo10(data.substring(0, 11));
      if (last != checksum) {
        throw BarcodeException(
            'Unable to encode "$data" to $name Barcode, checksum "$last" should be "$checksum"');
      }
    }

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
  Iterable<BarcodeText> makeText(
    String data,
    double width,
    double height,
    double fontHeight,
  ) {
    if (data.length == 11) {
      data += checkSumModulo10(data);
    }

    return super.makeText(data, width, height, fontHeight);
  }
}
