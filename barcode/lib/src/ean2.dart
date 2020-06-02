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

/// EAN 2 Barcode Generator
///
/// The EAN-2 is a supplement to the EAN-13 and UPC-A barcodes.
/// It is often used on magazines and periodicals to indicate an issue number.
class BarcodeEan2 extends BarcodeEan {
  /// EAN 2 Barcode Generator
  const BarcodeEan2();

  @override
  String get name => 'EAN 2';

  @override
  int get minLength => 2;

  @override
  int get maxLength => 2;

  @override
  Iterable<bool> convert(String data) sync* {
    verify(data);
    int idata;
    try {
      idata = int.parse(data);
    } catch (e) {
      throw BarcodeException('Unable to encode "$data" to $name Barcode');
    }
    final pattern = idata % 4;

    // Start
    yield* add(BarcodeMaps.eanStartEan2, 5);

    var index = 0;
    for (var code in data.codeUnits) {
      final codes = BarcodeMaps.ean[code];

      if (codes == null) {
        throw BarcodeException(
            'Unable to encode "${String.fromCharCode(code)}" to $name Barcode');
      }

      if (index == 1) {
        yield* add(BarcodeMaps.eanCenterEan2, 2);
      }

      yield* add(codes[((pattern >> index) & 1) ^ 1], 7);
      index++;
    }
  }

  @override
  double marginTop(
    bool drawText,
    double width,
    double height,
    double fontHeight,
  ) =>
      drawText ? fontHeight : 0;

  @override
  double getHeight(int index, int count, double width, double height,
          double fontHeight, bool drawText) =>
      height;

  @override
  Iterable<BarcodeElement> makeText(String data, double width, double height,
      double fontHeight, double lineWidth) sync* {
    yield BarcodeText(
      left: 0,
      top: 0,
      width: width,
      height: fontHeight,
      text: data,
      align: BarcodeTextAlign.center,
    );
  }
}
