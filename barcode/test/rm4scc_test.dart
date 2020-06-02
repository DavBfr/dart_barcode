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
  test('Barcode RM4SCC full alphabet', () {
    final Barcode1D bc = Barcode.rm4scc();

    expect(bc.toHex(r'0'), equals('43c3f'));
    expect(bc.toHex(r'1'), equals('49c9f'));
    expect(bc.toHex(r'2'), equals('4b4b7'));
    expect(bc.toHex(r'3'), equals('61e1f'));
    expect(bc.toHex(r'4'), equals('63637'));
    expect(bc.toHex(r'5'), equals('69697'));
    expect(bc.toHex(r'6'), equals('46c6f'));
    expect(bc.toHex(r'7'), equals('4cccf'));
    expect(bc.toHex(r'8'), equals('4e4e7'));
    expect(bc.toHex(r'9'), equals('64e4f'));
    expect(bc.toHex(r'A'), equals('66667'));
    expect(bc.toHex(r'B'), equals('6c6c7'));
    expect(bc.toHex(r'C'), equals('4787b'));
    expect(bc.toHex(r'D'), equals('4d8db'));
    expect(bc.toHex(r'E'), equals('4f0f3'));
    expect(bc.toHex(r'F'), equals('65a5b'));
    expect(bc.toHex(r'G'), equals('67273'));
    expect(bc.toHex(r'H'), equals('6d2d3'));
    expect(bc.toHex(r'I'), equals('52d2f'));
    expect(bc.toHex(r'J'), equals('58d8f'));
    expect(bc.toHex(r'K'), equals('5a5a7'));
    expect(bc.toHex(r'L'), equals('70f0f'));
    expect(bc.toHex(r'M'), equals('72727'));
    expect(bc.toHex(r'N'), equals('78787'));
    expect(bc.toHex(r'O'), equals('5393b'));
    expect(bc.toHex(r'P'), equals('5999b'));
    expect(bc.toHex(r'Q'), equals('5b1b3'));
    expect(bc.toHex(r'R'), equals('71b1b'));
    expect(bc.toHex(r'S'), equals('73333'));
    expect(bc.toHex(r'T'), equals('79393'));
    expect(bc.toHex(r'U'), equals('5696b'));
    expect(bc.toHex(r'V'), equals('5c9cb'));
    expect(bc.toHex(r'W'), equals('5e1e3'));
    expect(bc.toHex(r'X'), equals('74b4b'));
    expect(bc.toHex(r'Y'), equals('76363'));
    expect(bc.toHex(r'Z'), equals('7c3c3'));
  });
}
