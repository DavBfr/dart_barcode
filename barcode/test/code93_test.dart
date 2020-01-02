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

import 'package:barcode/barcode.dart';
import 'package:barcode/src/barcode_1d.dart';
import 'package:barcode/src/code93.dart';
import 'package:test/test.dart';

void main() {
  test('Barcode CODE 93 full alphabet', () {
    final Barcode1D bc = Barcode.code93();
    expect(bc.toHex(r'0'), equals('bd52a448d12b'));
    expect(bc.toHex(r'1'), equals('bda458ad42b'));
    expect(bc.toHex(r'2'), equals('bd8a244ad42b'));
    expect(bc.toHex(r'3'), equals('bd2a142ad42b'));
    expect(bc.toHex(r'4'), equals('bd8a4689d22b'));
    expect(bc.toHex(r'5'), equals('bd2a2649d22b'));
    expect(bc.toHex(r'6'), equals('bd8a1529d22b'));
    expect(bc.toHex(r'7'), equals('bd6285ad52b'));
    expect(bc.toHex(r'8'), equals('bdb29428d12b'));
    expect(bc.toHex(r'9'), equals('bdca56a8d02b'));
    expect(bc.toHex(r'A'), equals('bd5a468dda2b'));
    expect(bc.toHex(r'B'), equals('bd9a254dda2b'));
    expect(bc.toHex(r'C'), equals('bdba142dda2b'));
    expect(bc.toHex(r'D'), equals('bd2aa74cd92b'));
    expect(bc.toHex(r'E'), equals('bdba962cd92b'));
    expect(bc.toHex(r'F'), equals('bd5a57acd82b'));
    expect(bc.toHex(r'G'), equals('bd22458bd62b'));
    expect(bc.toHex(r'H'), equals('bda2244bd62b'));
    expect(bc.toHex(r'I'), equals('bd42152bd62b'));
    expect(bc.toHex(r'J'), equals('bda2a649d32b'));
    expect(bc.toHex(r'K'), equals('bd52d6a8d12b'));
    expect(bc.toHex(r'L'), equals('bda2c58ad52b'));
    expect(bc.toHex(r'M'), equals('bdd264cad42b'));
    expect(bc.toHex(r'N'), equals('bd32356ad42b'));
    expect(bc.toHex(r'O'), equals('bd5a64c9d22b'));
    expect(bc.toHex(r'P'), equals('bdb2b668d12b'));
    expect(bc.toHex(r'Q'), equals('bd6aa64ddb2b'));
    expect(bc.toHex(r'R'), equals('bdda942ddb2b'));
    expect(bc.toHex(r'S'), equals('bd5267cdda2b'));
    expect(bc.toHex(r'T'), equals('bdba356dda2b'));
    expect(bc.toHex(r'U'), equals('bd9ab46cd92b'));
    expect(bc.toHex(r'V'), equals('bdcad4acd92b'));
    expect(bc.toHex(r'W'), equals('bd1265cbd62b'));
    expect(bc.toHex(r'X'), equals('bd92346bd62b'));
    expect(bc.toHex(r'Y'), equals('bd4ab469d32b'));
    expect(bc.toHex(r'Z'), equals('bd92d6a9d32b'));
    expect(bc.toHex(r'-'), equals('bd4a76e9d22b'));
    expect(bc.toHex(r'.'), equals('bd92a54edd2b'));
    expect(bc.toHex(r' '), equals('bd6a942edd2b'));
    expect(bc.toHex(r'$'), equals('bd1a55aedc2b'));
    expect(bc.toHex(r'/'), equals('bdd276ebd62b'));
    expect(bc.toHex(r'+'), equals('bd9ab66bd72b'));
    expect(bc.toHex(r'%'), equals('bdb275edda2b'));
  });

  test('Barcode CODE 93 operations', () {
    final Barcode bc = Barcode.code93();
    expect(
      bc.make('A', width: 1, height: 1).toList().length,
      equals(31),
    );
  });

  test('Barcode CODE 93 error', () {
    final Barcode bc = Barcode.code93();
    expect(
      () => bc.make('Léo', width: 1, height: 1),
      throwsA(const TypeMatcher<BarcodeException>()),
    );
  });

  test('Barcode CODE 93 fromType', () {
    expect(
      Barcode.fromType(BarcodeType.Code93),
      equals(const TypeMatcher<BarcodeCode93>()),
    );
  });

  test('Barcode CODE 93 > 15 chars', () {
    final Barcode1D bc = Barcode.code93();
    expect(
      bc.toHex('EXACTLY 14 CHR'),
      equals('bd32852a9bac68e928914ab789d5b468d466257b5'),
    );

    expect(
      bc.toHex('EXACTLY 15 CHAR'),
      equals('bd5a942c1b3559d1d24922956e13ab69d1a8cd4af6a'),
    );

    expect(
      bc.toHex('MORE THAN 15 CHAR'),
      equals('bdb2d5291b3559d1d24922956e143559d3d225cb66c9d42b'),
    );
  });
}
