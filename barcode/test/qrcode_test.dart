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

import 'package:barcode/barcode.dart';
import 'package:barcode/src/barcode_2d.dart';
import 'package:test/test.dart';

void main() {
  test('Barcode QR', () {
    final Barcode2D bc = Barcode.qrCode();
    expect(bc.toHex('0').hashCode, equals(1026374156));
    expect(
      bc.toHex(String.fromCharCodes(Iterable.generate(256))).hashCode,
      equals(999908717),
    );
  });

  test('Barcode QR High error correction level', () {
    final Barcode2D bc =
        Barcode.qrCode(errorCorrectLevel: BarcodeQRCorrectionLevel.high);
    expect(bc.toHex('0').hashCode, equals(366615520));
  });

  test('Barcode QR manual type', () {
    final Barcode2D bc = Barcode.qrCode(typeNumber: 2);
    expect(bc.toHex('0').hashCode, equals(118397412));
  });

  test('Barcode QR limits', () {
    final Barcode2D bc = Barcode.qrCode();
    expect(bc.charSet, equals(List<int>.generate(256, (e) => e)));
    expect(bc.minLength, equals(1));
    expect(bc.maxLength, greaterThan(1024));
  });
}
