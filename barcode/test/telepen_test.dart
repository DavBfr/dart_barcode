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
  test('Barcode Telepen', () {
    final bc = Barcode.telepen();
    if (bc is! Barcode1D) {
      throw Exception('bc is not a Barcode1D');
    }

    expect(bc.toHex('z'), 'aae2eeb8aae2b8aa');
  });

  test('Barcode Telepen limits', () {
    final bc = Barcode.telepen();
    if (bc is! Barcode1D) {
      throw Exception('bc is not a Barcode1D');
    }

    expect(bc.charSet, Iterable<int>.generate(128));
  });
}
