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

import 'package:test/test.dart';

void main() {
  test('Barcode EAN', () {
    final bc = Barcode.ean13();
    if (bc is! BarcodeEan) {
      throw Exception('bc is not a BarcodeEan');
    }

    expect(bc.checkSumModulo10('987234'), equals('9'));
    expect(bc.checkSumModulo11('987234'), equals('5'));
  });

  test('Barcode EAN normalize', () {
    final ean13 = Barcode.ean13();
    if (ean13 is! BarcodeEan) {
      throw Exception('ean13 is not a BarcodeEan');
    }

    expect(ean13.normalize('453987234345'), equals('4539872343459'));

    final ean8 = Barcode.ean8();
    if (ean8 is! BarcodeEan) {
      throw Exception('ean8 is not a BarcodeEan');
    }

    expect(ean8.normalize('90834824'), equals('90834820'));

    final ean2 = Barcode.ean2();
    if (ean2 is! BarcodeEan) {
      throw Exception('ean2 is not a BarcodeEan');
    }

    expect(ean2.normalize('34'), equals('34'));

    final itf = Barcode.itf(addChecksum: true);
    if (itf is! BarcodeEan) {
      throw Exception('itf is not a BarcodeEan');
    }

    expect(itf.normalize('987'), equals('9874'));

    final itf14 = Barcode.itf14();
    if (itf14 is! BarcodeEan) {
      throw Exception('itf14 is not a BarcodeEan');
    }

    expect(itf14.normalize('9872349874432'), equals('98723498744328'));

    final upca = Barcode.upcA();
    if (upca is! BarcodeEan) {
      throw Exception('upca is not a BarcodeEan');
    }

    expect(upca.normalize('98345987562'), equals('983459875620'));

    final upce = Barcode.upcE(fallback: true);
    if (upce is! BarcodeEan) {
      throw Exception('upce is not a BarcodeEan');
    }

    expect(upce.normalize('18740000015'), equals('18741538'));
    expect(upce.normalize('48347295752'), equals('483472957520'));
    expect(upce.normalize('555555'), equals('05555550'));
  });

  test('Barcode EAN normalize zeros', () {
    final ean13 = Barcode.ean13();
    if (ean13 is! BarcodeEan) {
      throw Exception('ean13 is not a BarcodeEan');
    }

    expect(ean13.normalize('4'), equals('4000000000006'));

    final ean8 = Barcode.ean8();
    if (ean8 is! BarcodeEan) {
      throw Exception('ean8 is not a BarcodeEan');
    }

    expect(ean8.normalize('2'), equals('20000004'));

    final ean2 = Barcode.ean2();
    if (ean2 is! BarcodeEan) {
      throw Exception('ean2 is not a BarcodeEan');
    }

    expect(ean2.normalize('1'), equals('10'));

    final ean5 = Barcode.ean5();
    if (ean5 is! BarcodeEan) {
      throw Exception('ean5 is not a BarcodeEan');
    }

    expect(ean5.normalize('5'), equals('50000'));

    final itf14 = Barcode.itf14();
    if (itf14 is! BarcodeEan) {
      throw Exception('itf14 is not a BarcodeEan');
    }

    expect(itf14.normalize('7'), equals('70000000000009'));

    final upca = Barcode.upcA();
    if (upca is! BarcodeEan) {
      throw Exception('upca is not a BarcodeEan');
    }

    expect(upca.normalize('3'), equals('300000000001'));

    final upce = Barcode.upcE(fallback: true);
    if (upce is! BarcodeEan) {
      throw Exception('upce is not a BarcodeEan');
    }

    expect(upce.normalize('1'), equals('010000000009'));
  });
}
