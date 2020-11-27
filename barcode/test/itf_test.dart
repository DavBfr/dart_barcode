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
  test('Barcode ITF', () {
    final bc = Barcode.itf();
    if (bc is! Barcode1D) {
      throw Exception('bc is not a Barcode1D');
    }

    expect(bc.toHex('00'), equals('5d1c575'));
    expect(bc.toHex('10'), equals('dd11755'));
    expect(bc.toHex('42'), equals('1dd7515'));
    expect(bc.toHex('63'), equals('5d1d475'));
    expect(bc.toHex('24'), equals('1d175d5'));
    expect(bc.toHex('59'), equals('5d74745'));
    expect(bc.toHex('56'), equals('5d71745'));
  });

  test('Barcode ITF limits', () {
    final bc = Barcode.itf();
    expect(bc.charSet, equals([48, 49, 50, 51, 52, 53, 54, 55, 56, 57]));
    expect(bc.minLength, equals(1));
    expect(bc.maxLength, greaterThanOrEqualTo(1000));
  });

  test('Barcode ITF check', () {
    final bc = Barcode.itf();
    expect(bc.isValid('1'), isFalse);
    expect(bc.isValid('1111'), isTrue);
    expect(bc.isValid('ITF'), isFalse);
  });

  test('Barcode ITF addChecksum and zeroPrepend', () {
    final bc1 = Barcode.itf(addChecksum: false, zeroPrepend: false);
    if (bc1 is! Barcode1D) {
      throw Exception('bc1 is not a Barcode1D');
    }

    expect(bc1.isValid('1'), isFalse);
    expect(bc1.toHex('0451'), '1d7571745c15');

    final bc2 = Barcode.itf(addChecksum: true, zeroPrepend: false);
    if (bc2 is! Barcode1D) {
      throw Exception('bc2 is not a Barcode1D');
    }

    expect(bc2.isValid('1'), isTrue);
    expect(bc2.toHex('045'), '1d7571745c15');

    final bc3 = Barcode.itf(addChecksum: false, zeroPrepend: true);
    if (bc3 is! Barcode1D) {
      throw Exception('bc3 is not a Barcode1D');
    }

    expect(bc3.isValid('1'), isTrue);
    expect(bc3.toHex('451'), '1d7571745c15');

    final bc4 = Barcode.itf(addChecksum: true, zeroPrepend: true);
    if (bc4 is! Barcode1D) {
      throw Exception('bc4 is not a Barcode1D');
    }

    expect(bc4.isValid('1'), isTrue);
    expect(bc4.toHex('45'), '1d7571745c15');
  });
}
