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
      expect(bc.upcaToUpce('012340000053'), equals('123454'));
      expect(bc.upcaToUpce('012345000058'), equals('123455'));
      expect(bc.upcaToUpce('012345000065'), equals('123456'));
      expect(bc.upcaToUpce('012345000072'), equals('123457'));
      expect(bc.upcaToUpce('012345000089'), equals('123458'));
      expect(bc.upcaToUpce('012345000096'), equals('123459'));
      expect(bc.upcaToUpce('000010000052'), equals('000154'));
      expect(bc.upcaToUpce('010200000809'), equals('100802'));
    }
    //For output data, please refer to https://barcodeqrcode.com/convert-upc-a-to-upc-e/
  });

  test('Barcode UPC-E', () {
    final bc = Barcode.upcE();

    expect(bc.isValid('123456'), isTrue);
    expect(bc.isValid('1234567'), isTrue);
    expect(bc.isValid('11234593'), isTrue);
    expect(bc.isValid('123456789'), isFalse);
  });

  test('Barcode UPC-E normalize (fallback)', () {
    final bc = Barcode.upcE(fallback: true);
    if (bc is BarcodeUpcE) {
      expect(bc.normalize('18740000015'), equals('18741538'));
      expect(bc.normalize('48347295752'), equals('483472957520'));
      expect(bc.normalize('555555'), equals('05555550'));
      expect(bc.normalize('212345678992'), equals('212345678992'));
      expect(bc.normalize('014233365553'), equals('014233365553'));
    }
  });

  test('Barcode UPC-E normalize', () {
    final bc = Barcode.upcE();
    if (bc is BarcodeUpcE) {
      expect(bc.normalize('01008029'), equals('01008029'));
      expect(bc.normalize('0100802'), equals('01008029'));
      expect(bc.normalize('100802'), equals('01008029'));
      expect(bc.normalize('1'), equals('01000009'));

      expect(bc.normalize('100902'), equals('01009028'));
      expect(bc.normalize('100965'), equals('01009651'));
      expect(bc.normalize('107444'), equals('01074448'));
      expect(bc.normalize('000100'), equals('00001009'));

      expect(bc.normalize('042100005264'), equals('04252614'));
      expect(bc.normalize('020600000019'), equals('02060139'));
      expect(bc.normalize('040350000077'), equals('04035747'));
      expect(bc.normalize('020201000050'), equals('02020150'));
      expect(bc.normalize('020204000064'), equals('02020464'));
      expect(bc.normalize('023456000073'), equals('02345673'));
      expect(bc.normalize('020204000088'), equals('02020488'));
      expect(bc.normalize('020201000098'), equals('02020198'));
      expect(bc.normalize('127200002013'), equals('12720123'));
      expect(bc.normalize('042100005264'), equals('04252614'));

      //For special case : input '000105' etc.
      //It's converted to '000010000052' ('L-MMMM0-0000P-C').
      //This UPC-E code ends in 5, but its UPC-A manufacturer code is "00010" and its last digit should not be zero.
      //'000010000052' should be paired with the last code of UPC-E being 4.
      //'000010000052' converted to UPC-E will be '00001542'

      //'000105' does not comply with the encoding principles for conversion from UPC-A to UPC-E,
      //but it can applies to the conversion rules.
      //It will be normalized to a new value when converting back to UPC-E.
      //'000105' , '00001052' will be normalized to '00001542' , not '00001052'.
      expect(bc.normalize('000105'), equals('00001542'));
      expect(bc.normalize('00001052'), equals('00001542'));
      expect(bc.normalize('000154'), equals('00001542'));
      expect(bc.normalize('00001542'), equals('00001542'));
      expect(bc.normalize('000010000052'), equals('00001542'));
      expect(bc.normalize('001054'), equals('00000514')); //another special case
    }
  });
}
