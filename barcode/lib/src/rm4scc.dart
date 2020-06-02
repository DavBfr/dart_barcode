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

/// RM4SCC Barcode
///
/// The RM4SCC is used for the Royal Mail Cleanmail service. It enables UK
/// postcodes as well as Delivery Point Suffixes (DPSs) to be easily read by
/// a machine at high speed.
class BarcodeRm4scc extends BarcodeHM {
  /// Create an RM4SCC Barcode
  const BarcodeRm4scc();

  @override
  Iterable<int> get charSet => BarcodeMaps.rm4scc.keys;

  @override
  String get name => 'RM4SCC';

  @override
  Iterable<BarcodeHMBar> convertHM(String data) sync* {
    yield fromBits(BarcodeMaps.rm4sccStart);

    var sumTop = 0;
    var sumBottom = 0;
    final keys = BarcodeMaps.rm4scc.keys.toList();

    for (final codeUnit in data.codeUnits) {
      final code = BarcodeMaps.rm4scc[codeUnit];
      if (code == null) {
        throw BarcodeException(
            'Unable to encode "${String.fromCharCode(codeUnit)}" to $name');
      }
      yield* addHW(code, BarcodeMaps.rm4sccLen);

      final index = keys.indexOf(codeUnit);
      sumTop += (index ~/ 6 + 1) % 6;
      sumBottom += (index + 1) % 6;
    }

    final crc = ((sumTop - 1) % 6) * 6 + (sumBottom - 1) % 6;
    yield* addHW(BarcodeMaps.rm4scc[keys[crc]], BarcodeMaps.rm4sccLen);

    yield fromBits(BarcodeMaps.rm4sccStop);
  }
}
