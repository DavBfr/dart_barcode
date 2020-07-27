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
import 'package:barcode/src/barcode_1d.dart';
import 'package:test/test.dart';

void main() {
  test('Barcode CODABAR full alphabet', () {
    final Barcode1D bc = Barcode.codabar();
    expect(bc.toHex(r'0'), equals('4b9a2a59'));
    expect(bc.toHex(r'1'), equals('4bca2a59'));
    expect(bc.toHex(r'2'), equals('4b5a2a59'));
    expect(bc.toHex(r'3'), equals('4baa2c59'));
    expect(bc.toHex(r'4'), equals('4b4a2b59'));
    expect(bc.toHex(r'5'), equals('4b4a2d59'));
    expect(bc.toHex(r'6'), equals('4b5a2959'));
    expect(bc.toHex(r'7'), equals('4b6a2959'));
    expect(bc.toHex(r'8'), equals('4baa2959'));
    expect(bc.toHex(r'9'), equals('4b2a2d59'));
    expect(bc.toHex(r'$'), equals('4b2a2b59'));
    expect(bc.toHex(r'-'), equals('4b6a2a59'));
    expect(bc.toHex(r':'), equals('4bda5ab2'));
    expect(bc.toHex(r'/'), equals('4b5a5bb2'));
    expect(bc.toHex(r'.'), equals('4b6a5bb2'));
    expect(bc.toHex(r'+'), equals('4bda56b2'));
  });

  test('Barcode CODABAR start/stop', () {
    const results = [
      'c94a2d59', 'c94a6d49', 'c94a6d52', 'c94a2d53', '4b4a2d59', '4b4a6d49', //
      '4b4a6d52', '4b4a2d53', '934a2d59', '934a6d49', '934a6d52', '934a2d53', //
      '994a2d59', '994a6d49', '994a6d52', '994a2d53'
    ];

    for (var n = 0; n < 16; n++) {
      final Barcode1D bc = Barcode.codabar(
        start: BarcodeCodabarStartStop.values[n % 4],
        stop: BarcodeCodabarStartStop.values[n ~/ 4],
      );
      expect(bc.toHex(r'5'), equals(results[n]));
    }
  });

  test('Barcode CODABAR error', () {
    final bc = Barcode.codabar();
    expect(() => bc.make('AABBCCDD', width: 1, height: 1),
        throwsA(const TypeMatcher<BarcodeException>()));
  });

  test('Barcode CODABAR explicit Start Stop', () {
    final Barcode1D bc = Barcode.codabar(
      explicitStartStop: true,
    );

    expect(bc.isValid(r'B5C'), isTrue);
    expect(bc.toHex(r'B5C'), equals('934a6d49'));
    expect(bc.toHex(r'N5*'), equals('934a6d49'));
  });

  test('Barcode CODABAR text', () {
    Barcode1D bc = Barcode.codabar();
    expect(bc.getText(r'32983'), equals('32983'));

    bc = Barcode.codabar(explicitStartStop: true);
    expect(bc.getText(r'N987562*'), equals('987562'));

    bc = Barcode.codabar(printStartStop: true);
    expect(bc.getText(r'6346368'), equals('A6346368B'));

    bc = Barcode.codabar(
        printStartStop: true,
        start: BarcodeCodabarStartStop.B,
        stop: BarcodeCodabarStartStop.D);
    expect(bc.getText(r'923985'), equals('B923985D'));

    bc = Barcode.codabar(printStartStop: true, explicitStartStop: true);
    expect(bc.getText(r'N0923765*'), equals('N0923765*'));
  });
}
