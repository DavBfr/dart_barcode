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

import '../barcode.dart';
import 'barcode_hm.dart';
import 'barcode_maps.dart';

/// POSTNET Barcode
///
/// POSTNET (Postal Numeric Encoding Technique) is a barcode symbology used by
/// the United States Postal Service to assist in directing mail.
class BarcodePostnet extends BarcodeHM {
  /// Create a POSTNET Barcode
  const BarcodePostnet() : super(tracker: 0);

  @override
  Iterable<int> get charSet => [45, ...BarcodeMaps.postnet.keys];

  @override
  String get name => 'POSTNET';

  @override
  Iterable<BarcodeHMBar> convertHM(String data) sync* {
    yield fromBits(BarcodeMaps.postnetStartStop);

    var sum = 0;
    for (final codeUnit in data.codeUnits) {
      if (codeUnit == 45) {
        continue;
      }
      final code = BarcodeMaps.postnet[codeUnit];
      if (code == null) {
        throw BarcodeException(
            'Unable to encode "${String.fromCharCode(codeUnit)}" to $name');
      }
      yield* addHW(code, BarcodeMaps.postnetLen);

      sum += codeUnit - 0x30;
    }

    final crc = (10 - (sum % 10)) % 10;
    yield* addHW(BarcodeMaps.postnet[crc + 0x30]!, BarcodeMaps.postnetLen);

    yield fromBits(BarcodeMaps.postnetStartStop);
  }
}
