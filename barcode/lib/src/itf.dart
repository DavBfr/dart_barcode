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

import 'barcode_exception.dart';
import 'barcode_maps.dart';
import 'barcode_operations.dart';
import 'ean.dart';

/// 2 of 5 Barcode
///
/// Interleaved 2 of 5 (ITF) is a continuous two-width barcode symbology
/// encoding digits. It is used commercially on 135 film, for ITF-14 barcodes,
/// and on cartons of some products, while the products inside are labeled
/// with UPC or EAN.
class BarcodeItf extends BarcodeEan {
  /// Create an ITF-14 Barcode
  const BarcodeItf(
    this.addChecksum,
  ) : assert(addChecksum != null);

  /// Add Modulo 10 checksum
  final bool addChecksum;

  @override
  String get name => 'ITF';

  @override
  Iterable<bool> convert(String data) sync* {
    if (addChecksum) {
      data += checkSumModulo10(data);
    }

    // Start
    yield* add(BarcodeMaps.itfStart, 4);

    final cu = data.codeUnits;
    for (var i = 0; i < cu.length / 2; i++) {
      final tuple = <int>[
        BarcodeMaps.itf[cu[i * 2]],
        BarcodeMaps.itf[cu[i * 2 + 1]]
      ];

      if (tuple[0] == null || tuple[1] == null) {
        throw BarcodeException(
            'Unable to encode "${String.fromCharCode(cu[i * 2])}${String.fromCharCode(cu[i * 2 + 1])}" to $name Barcode');
      }

      for (var n = 0; n < 10; n++) {
        final v = (tuple[n % 2] >> (n ~/ 2)) & 1;
        final c = n % 2 == 0;
        yield c;
        if (v != 0) {
          yield c;
          yield c;
        }
      }
    }

    // End
    yield* add(BarcodeMaps.itfEnd, 5);
  }

  @override
  Iterable<BarcodeElement> makeText(
    String data,
    double width,
    double height,
    double fontHeight,
    double lineWidth,
  ) {
    if (addChecksum) {
      data += checkSumModulo10(data);
    }

    return super.makeText(data, width, height, fontHeight, lineWidth);
  }

  @override
  void verify(String data) {
    if (addChecksum) {
      data += checkSumModulo10(data);
    }

    if (data.length % 2 != 0) {
      throw BarcodeException(
          '$name barcode can only encode an even number of digits.');
    }

    super.verify(data);
  }
}
