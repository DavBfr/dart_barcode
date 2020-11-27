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
  test('BarcodeException', () {
    expect(const BarcodeException('message').toString(),
        equals('BarcodeException: message'));
  });

  test('Barcode operations', () {
    final bc = Barcode.code39();
    final operations =
        bc.make('ABC', width: 200, height: 50, drawText: true, fontHeight: 10);

    for (var op in operations) {
      expect(op.toString(), const TypeMatcher<String>());
    }
  });

  test('BarcodeElement', () {
    const be = BarcodeElement(width: 1, height: 2, left: 3, top: 4);

    expect(be.toString(), const TypeMatcher<String>());

    expect(be.right, equals(4.0));
    expect(be.bottom, equals(6.0));
  });

  test('BarcodeSvg', () {
    final bc = Barcode.code128();
    bc.toSvg('12345');
  });
}
