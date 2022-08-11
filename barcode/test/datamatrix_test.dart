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
import 'package:barcode/src/barcode_2d.dart';
import 'package:test/test.dart';

import 'golden_utils.dart';

void main() {
  final bc = Barcode.dataMatrix();

  test('Barcode DataMatrix', () {
    if (bc is! Barcode2D) {
      throw Exception('${bc.name} is not a Barcode2D');
    }

    expect(bc.toSvg('0'), matchesGoldenString('datamatrix/0.svg'));
    expect(
      bc.toSvg(String.fromCharCodes(
          Iterable<int>.generate(256 - 32).map((e) => e + 32))),
      matchesGoldenString('datamatrix/224.svg'),
    );
  });

  test('Barcode DataMatrix GS1', () {
    // https://online-barcode-reader.inliteresearch.com/
    expect(
        bc.toSvgBytes((DataMatrixEncoder()
              ..fnc1()
              ..ascii('01034531200000111719112510ABCD1234')
              ..fnc1()
              ..ascii('2110'))
            .toBytes()),
        matchesGoldenString('datamatrix/gs1.svg'));
  });
}
