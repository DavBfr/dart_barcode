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
  test('Barcode POSTNET full alphabet', () {
    final bc = Barcode.postnet();
    if (bc is! Barcode1D) {
      throw Exception('bc is not a Barcode1D');
    }

    expect(bc.toHex(r'0'), equals('feafab'));
    expect(bc.toHex(r'1'), equals('eafee3'));
    expect(bc.toHex(r'2'), equals('ebbebb'));
    expect(bc.toHex(r'3'), equals('ebeeaf'));
    expect(bc.toHex(r'4'), equals('eebbeb'));
    expect(bc.toHex(r'5'), equals('eeebbb'));
    expect(bc.toHex(r'6'), equals('efabaf'));
    expect(bc.toHex(r'7'), equals('fabafb'));
    expect(bc.toHex(r'8'), equals('faeaef'));
    expect(bc.toHex(r'9'), equals('fb8abf'));
  });

  test('Barcode POSTNET example', () {
    final bc = Barcode.postnet();
    if (bc is! Barcode1D) {
      throw Exception('bc is not a Barcode1D');
    }

    expect(bc.toHex(r'55555-1237'), equals('eeebbaeebbaeeabebbafbabaef'));
  });
}
