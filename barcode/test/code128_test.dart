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
import 'package:barcode/src/code128.dart';
import 'package:test/test.dart';

void main() {
  test('Barcode CODE 128 charsets', () {
    final bc = Barcode.code128();
    if (bc is BarcodeCode128) {
      expect(bc.shortestCode(<int>[0x04]), equals(<int>[0x67, 0x44]));

      expect(
        bc.shortestCode(<int>[0x34, 0x73, 0x45, 0x06, 0x32, 0x35, 0x36, 0x39]),
        equals(<int>[104, 20, 83, 101, 37, 70, 99, 25, 69]),
      );

      expect(
        bc.shortestCode('mn429872349870t'.codeUnits),
        equals(<int>[104, 77, 78, 99, 42, 98, 72, 34, 98, 70, 100, 84]),
      );

      expect(
        bc.shortestCode('098x1234567y23'.codeUnits),
        equals(<int>[105, 9, 100, 24, 88, 99, 12, 34, 56, 100, 23, 89, 18, 19]),
      );

      expect(
        bc.shortestCode('42184020500'.codeUnits),
        equals(<int>[105, 42, 18, 40, 20, 50, 101, 16]),
      );

      expect(
        bc.shortestCode('HELLO12312312312'.codeUnits),
        equals(<int>[103, 40, 37, 44, 44, 47, 99, 12, 31, 23, 12, 31, 101, 18]),
      );
    }
  });
}
