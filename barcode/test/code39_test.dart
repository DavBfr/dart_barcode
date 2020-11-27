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
import 'package:barcode/src/code39.dart';
import 'package:test/test.dart';

void main() {
  test('Barcode CODE 39 full alphabet', () {
    final bc = Barcode.code39();
    if (bc is! Barcode1D) {
      throw Exception('bc is not a Barcode1D');
    }

    expect(bc.toHex(r'0'), equals('da529b6a4b'));
    expect(bc.toHex(r'1'), equals('dad24a6b4b'));
    expect(bc.toHex(r'2'), equals('dad2ca6a4b'));
    expect(bc.toHex(r'3'), equals('da52656b4b'));
    expect(bc.toHex(r'4'), equals('dad29a6a4b'));
    expect(bc.toHex(r'5'), equals('da524d6b4b'));
    expect(bc.toHex(r'6'), equals('da52cd6a4b'));
    expect(bc.toHex(r'7'), equals('dad2966a4b'));
    expect(bc.toHex(r'8'), equals('da524b6b4b'));
    expect(bc.toHex(r'9'), equals('da52cb6a4b'));
    expect(bc.toHex(r'A'), equals('dad2526b4b'));
    expect(bc.toHex(r'B'), equals('dad2d26a4b'));
    expect(bc.toHex(r'C'), equals('da52696b4b'));
    expect(bc.toHex(r'D'), equals('dad2b26a4b'));
    expect(bc.toHex(r'E'), equals('da52596b4b'));
    expect(bc.toHex(r'F'), equals('da52d96a4b'));
    expect(bc.toHex(r'G'), equals('dad2a66a4b'));
    expect(bc.toHex(r'H'), equals('da52536b4b'));
    expect(bc.toHex(r'I'), equals('da52d36a4b'));
    expect(bc.toHex(r'J'), equals('da52b36a4b'));
    expect(bc.toHex(r'K'), equals('dad2546b4b'));
    expect(bc.toHex(r'L'), equals('dad2d46a4b'));
    expect(bc.toHex(r'M'), equals('da526a6b4b'));
  });

  test('Barcode CODE 39 operations', () {
    final bc = Barcode.code39();
    expect(bc.make('A', width: 1, height: 1).toList().length, equals(30));
  });

  test('Barcode CODE 39 error', () {
    final bc = Barcode.code39();
    expect(() => bc.make('Léo', width: 1, height: 1),
        throwsA(const TypeMatcher<BarcodeException>()));
  });

  test('Barcode CODE 39 fromType', () {
    expect(Barcode.fromType(BarcodeType.Code39),
        equals(const TypeMatcher<BarcodeCode39>()));
  });
}
