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
import 'package:barcode/src/barcode_maps.dart';
import 'package:barcode/src/code128.dart';
import 'package:test/test.dart';

void main() {
  test('Barcode CODE 128', () {
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
        bc.shortestCode('4218'.codeUnits),
        equals(<int>[105, 42, 18]),
      );

      expect(
        bc.shortestCode('053172STB'.codeUnits),
        equals(<int>[105, 5, 31, 72, 101, 51, 52, 34]),
      );

      expect(
        bc.shortestCode('0531721STB'.codeUnits),
        equals(<int>[105, 5, 31, 72, 101, 17, 51, 52, 34]),
      );

      expect(
        bc.shortestCode('hello\nTEST'.codeUnits),
        equals(<int>[104, 72, 69, 76, 76, 79, 101, 74, 52, 37, 51, 52]),
      );

      expect(
        bc.shortestCode('TEST\nhello'.codeUnits),
        equals(<int>[103, 52, 37, 51, 52, 74, 100, 72, 69, 76, 76, 79]),
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

  test('Barcode CODE 128 B+C', () {
    final bc = Barcode.code128(useCode128A: false);

    if (bc is BarcodeCode128) {
      expect(
        bc.shortestCode('053172STB'.codeUnits),
        equals(<int>[105, 5, 31, 72, 100, 51, 52, 34]),
      );
    }
  });

  test('Barcode CODE 128 B', () {
    final bc = Barcode.code128(useCode128A: false, useCode128C: false);

    if (bc is BarcodeCode128) {
      expect(
        bc.shortestCode('053172STB'.codeUnits),
        equals(<int>[104, 16, 21, 19, 17, 23, 18, 51, 52, 34]),
      );
    }
  });

  test('Barcode Code-128 with FNC', () {
    final bc = Barcode.gs128();
    if (bc is BarcodeCode128) {
      expect(
        bc.shortestCode('${BarcodeCode128Fnc.fnc1}309245'.codeUnits),
        equals(<int>[105, 102, 30, 92, 45]),
      );
      expect(
        bc.shortestCode(
            '${BarcodeCode128Fnc.fnc1}30${BarcodeCode128Fnc.fnc1}9245'
                .codeUnits),
        equals(<int>[105, 102, 30, 102, 92, 45]),
      );
      expect(
        bc.shortestCode(
            '${BarcodeCode128Fnc.fnc1}301${BarcodeCode128Fnc.fnc1}92'
                .codeUnits),
        equals(<int>[103, 102, 19, 16, 17, 99, 102, 92]),
      );
      expect(
        bc.shortestCode(
            '${BarcodeCode128Fnc.fnc1}3010${BarcodeCode128Fnc.fnc1}92'
                .codeUnits),
        equals(<int>[105, 102, 30, 10, 102, 92]),
      );
      expect(
        bc.shortestCode(
            '${BarcodeCode128Fnc.fnc1}3B10${BarcodeCode128Fnc.fnc1}92'
                .codeUnits),
        equals(<int>[103, 102, 19, 34, 17, 16, 99, 102, 92]),
      );

      expect(
        bc.shortestCode('He${BarcodeCode128Fnc.fnc2}llo'.codeUnits),
        equals(<int>[104, 40, 69, 97, 76, 76, 79]),
      );

      expect(
        bc.shortestCode('He${BarcodeCode128Fnc.fnc3}llo'.codeUnits),
        equals(<int>[104, 40, 69, 96, 76, 76, 79]),
      );

      expect(
        bc.shortestCode('He${BarcodeCode128Fnc.fnc4}llo'.codeUnits),
        equals(<int>[104, 40, 69, 100, 76, 76, 79]),
      );
    }
  });

  test('Barcode Code-128 escapes', () {
    final bc = Barcode.code128(escapes: true);
    if (bc is BarcodeCode128) {
      expect(
        bc.adaptData('test{1}123'),
        equals('test${BarcodeCode128Fnc.fnc1}123'),
      );

      expect(
        bc.adaptData('test{2}123'),
        equals('test${BarcodeCode128Fnc.fnc2}123'),
      );

      expect(
        bc.adaptData('test{3}123'),
        equals('test${BarcodeCode128Fnc.fnc3}123'),
      );

      expect(
        bc.adaptData('test{4}123'),
        equals('test${BarcodeCode128Fnc.fnc4}123'),
      );

      expect(
        bc.adaptData('te{2}st{4}1{3}{1}3'),
        equals(
            'te${BarcodeCode128Fnc.fnc2}st${BarcodeCode128Fnc.fnc4}1${BarcodeCode128Fnc.fnc3}${BarcodeCode128Fnc.fnc1}3'),
      );
    }
  });

  test('Barcode GS1-128', () {
    final bc = Barcode.gs128();
    if (bc is BarcodeCode128) {
      expect(
        bc.adaptData('(3)0(92)'),
        equals('${BarcodeCode128Fnc.fnc1}30${BarcodeCode128Fnc.fnc1}92'),
      );

      expect(
        bc.adaptData('x(3)0(92)x'),
        equals('x${BarcodeCode128Fnc.fnc1}30${BarcodeCode128Fnc.fnc1}92x'),
      );

      expect(
        bc.adaptData('x(30(92)x'),
        equals('x${BarcodeCode128Fnc.fnc1}30(92x'),
      );
    }
  });

  test('Barcode CODE-128 charSet', () {
    const code128A = <int>{
      32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, //
      50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, //
      68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, //
      86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, //
      10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, //
      28, 29, 30, 31, BarcodeMaps.code128FNC1, BarcodeMaps.code128FNC2,
      BarcodeMaps.code128FNC3, BarcodeMaps.code128FNC4
    };

    const code128B = <int>{
      32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, //
      50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, //
      68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, //
      86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, //
      103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, //
      117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127,
      BarcodeMaps.code128FNC1, BarcodeMaps.code128FNC2,
      BarcodeMaps.code128FNC3, BarcodeMaps.code128FNC4
    };

    const code128C = <int>{
      48, 49, 50, 51, 52, 53, 54, 55, 56, 57, BarcodeMaps.code128FNC1 //
    };

    expect(
      Barcode.code128().charSet,
      equals(<int>{...code128A, ...code128B, ...code128C}),
    );

    expect(
      Barcode.code128(useCode128A: true, useCode128B: false, useCode128C: false)
          .charSet,
      equals(<int>{...code128A}),
    );

    expect(
      Barcode.code128(useCode128A: true, useCode128B: true, useCode128C: false)
          .charSet,
      equals(<int>{...code128A, ...code128B}),
    );

    expect(
      Barcode.code128(useCode128A: false, useCode128B: true, useCode128C: false)
          .charSet,
      equals(<int>{...code128B}),
    );

    expect(
      Barcode.code128(useCode128A: false, useCode128B: false, useCode128C: true)
          .charSet,
      equals(<int>{...code128C}),
    );

    expect(
      Barcode.code128(useCode128A: true, useCode128B: false, useCode128C: true)
          .charSet,
      equals(<int>{...code128A, ...code128C}),
    );

    expect(
      Barcode.code128(useCode128A: false, useCode128B: true, useCode128C: true)
          .charSet,
      equals(<int>{...code128B, ...code128C}),
    );

    expect(
      Barcode.code128(useCode128A: true, useCode128B: true, useCode128C: true)
          .charSet,
      equals(<int>{...code128A, ...code128B, ...code128C}),
    );
  });
}
