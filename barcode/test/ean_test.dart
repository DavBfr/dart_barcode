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
    final BarcodeEan bc = Barcode.ean13();

    expect(bc.checkSumModulo10('987234'), equals('9'));
    expect(bc.checkSumModulo11('987234'), equals('5'));
  });

  test('Barcode EAN normalize', () {
    final BarcodeEan ean13 = Barcode.ean13();
    expect(ean13.normalize('453987234345'), equals('4539872343459'));

    final BarcodeEan ean8 = Barcode.ean8();
    expect(ean8.normalize('90834824'), equals('90834820'));

    final BarcodeEan ean2 = Barcode.ean2();
    expect(ean2.normalize('34'), equals('34'));

    final BarcodeEan itf = Barcode.itf(addChecksum: true);
    expect(itf.normalize('987'), equals('9874'));

    final BarcodeEan itf14 = Barcode.itf14();
    expect(itf14.normalize('9872349874432'), equals('98723498744328'));

    final BarcodeEan upca = Barcode.upcA();
    expect(upca.normalize('98345987562'), equals('983459875620'));

    final BarcodeEan upce = Barcode.upcE(fallback: true);
    expect(upce.normalize('18740000915'), equals('87419'));
    expect(upce.normalize('48347295752'), equals('483472957520'));
  });

  test('Barcode EAN normalize zeros', () {
    final BarcodeEan ean13 = Barcode.ean13();
    expect(ean13.normalize('4'), equals('4000000000006'));

    final BarcodeEan ean8 = Barcode.ean8();
    expect(ean8.normalize('2'), equals('20000004'));

    final BarcodeEan ean2 = Barcode.ean2();
    expect(ean2.normalize('1'), equals('10'));

    final BarcodeEan ean5 = Barcode.ean5();
    expect(ean5.normalize('5'), equals('50000'));

    final BarcodeEan itf14 = Barcode.itf14();
    expect(itf14.normalize('7'), equals('70000000000009'));

    final BarcodeEan upca = Barcode.upcA();
    expect(upca.normalize('3'), equals('300000000001'));

    final BarcodeEan upce = Barcode.upcE(fallback: true);
    expect(upce.normalize('1'), equals('100000000007'));
  });
}
