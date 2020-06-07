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
import 'package:barcode/src/upce.dart';
import 'package:test/test.dart';

void main() {
  test('Barcode UPC-E upceToUpca', () {
    final bc = Barcode.upcE();
    if (bc is BarcodeUpcE) {
      expect(bc.upceToUpca('123450'), equals('012000003455'));
      expect(bc.upceToUpca('123451'), equals('012100003454'));
      expect(bc.upceToUpca('123452'), equals('012200003453'));
      expect(bc.upceToUpca('123453'), equals('012300000451'));
      expect(bc.upceToUpca('123454'), equals('012340000053'));
      expect(bc.upceToUpca('123405'), equals('012340000053'));
      expect(bc.upceToUpca('123455'), equals('012345000058'));
      expect(bc.upceToUpca('123456'), equals('012345000065'));
      expect(bc.upceToUpca('123457'), equals('012345000072'));
      expect(bc.upceToUpca('123458'), equals('012345000089'));
      expect(bc.upceToUpca('123459'), equals('012345000096'));

      expect(bc.upceToUpca('1123459'), equals('112345000093'));
      expect(bc.upceToUpca('11234593'), equals('112345000093'));
    }
  });

  test('Barcode UPC-E upcaToUpce', () {
    final bc = Barcode.upcE();
    if (bc is BarcodeUpcE) {
      expect(bc.upcaToUpce('012000003455'), equals('123450'));
      expect(bc.upcaToUpce('012100003454'), equals('123451'));
      expect(bc.upcaToUpce('012200003453'), equals('123452'));
      expect(bc.upcaToUpce('012300000451'), equals('123453'));
      expect(bc.upcaToUpce('012340000053'), equals('123405'));
      expect(bc.upcaToUpce('012345000058'), equals('123455'));
      expect(bc.upcaToUpce('012345000065'), equals('123456'));
      expect(bc.upcaToUpce('012345000072'), equals('123457'));
      expect(bc.upcaToUpce('012345000089'), equals('123458'));
      expect(bc.upcaToUpce('012345000096'), equals('123459'));
    }
  });

  test('Barcode UPC-E', () {
    final bc = Barcode.upcE();

    expect(bc.isValid('123456'), isTrue);
    expect(bc.isValid('1234567'), isTrue);
    expect(bc.isValid('11234593'), isTrue);
    expect(bc.isValid('123456789'), isFalse);
  });
}
