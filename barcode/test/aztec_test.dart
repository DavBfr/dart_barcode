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
  test('Barcode Aztec', () {
    final bc = Barcode.aztec();
    if (bc is! Barcode2D) {
      throw Exception('bc is not a Barcode2D');
    }

    expect(bc.toSvg('0'), matchesGoldenString('aztec/0.svg'));
    expect(
      bc.toSvg(String.fromCharCodes(Iterable.generate(256))),
      matchesGoldenString('aztec/256.svg'),
    );
  });

  test('Barcode Aztec High error correction level', () {
    final bc = Barcode.aztec(minECCPercent: 80);
    if (bc is! Barcode2D) {
      throw Exception('bc is not a Barcode2D');
    }

    expect(bc.toSvg('0'), matchesGoldenString('aztec/high_error_level.svg'));
  });

  test('Barcode Aztec manual type', () {
    final bc = Barcode.aztec(userSpecifiedLayers: 5);
    if (bc is! Barcode2D) {
      throw Exception('bc is not a Barcode2D');
    }

    expect(bc.toSvg('0'), matchesGoldenString('aztec/manual.svg'));
  });

  test('Barcode Aztec limits', () {
    final bc = Barcode.aztec();
    if (bc is! Barcode2D) {
      throw Exception('bc is not a Barcode2D');
    }

    expect(bc.charSet, equals(List<int>.generate(256, (e) => e)));
    expect(bc.minLength, equals(1));
    expect(bc.maxLength, greaterThan(1024));
  });
}
