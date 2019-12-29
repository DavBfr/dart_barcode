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

// ignore_for_file: omit_local_variable_types

import 'package:meta/meta.dart';

import 'barcode_operations.dart';
import 'code128.dart';
import 'code39.dart';
import 'code93.dart';
import 'ean13.dart';
import 'ean8.dart';
import 'isbn.dart';

/// Supported barcode types
enum BarcodeType {
  CodeEAN13,
  CodeEAN8,
  CodeISBN,
  Code39,
  Code93,
  // CodeUPCA,
  // CodeUPCE,
  Code128,
}

/// Barcode generation class
@immutable
abstract class Barcode {
  /// Abstract constructor
  const Barcode();

  /// Create a specific `Barcode` instance based on the `BarcodeType`
  /// this uses only the default barcode settings.
  /// For finer-grained usage, use the static methods:
  /// * Barcode.code39()
  /// * Barcode.code93()
  /// * Barcode.code128()
  /// * ...
  factory Barcode.fromType(BarcodeType type) {
    assert(type != null);

    switch (type) {
      case BarcodeType.Code39:
        return const BarcodeCode39();
      case BarcodeType.Code93:
        return const BarcodeCode93();
      case BarcodeType.Code128:
        return const BarcodeCode128();
      case BarcodeType.CodeEAN13:
        return const BarcodeEan13();
      case BarcodeType.CodeEAN8:
        return const BarcodeEan8();
      case BarcodeType.CodeISBN:
        return const BarcodeIsbn();
      default:
        throw UnimplementedError('Barcode $type not supported');
    }
  }

  /// Create a CODE 39 `Barcode` instance:
  /// ![CODE 39](https://raw.githubusercontent.com/DavBfr/dart_barcode/master/img/code-39.png)
  static Barcode code39() => const BarcodeCode39();

  /// Create a CODE 93 `Barcode` instance:
  /// ![CODE 93](https://raw.githubusercontent.com/DavBfr/dart_barcode/master/img/code-93.png)
  static Barcode code93() => const BarcodeCode93();

  /// Create a CODE 128 `Barcode` instance
  /// ![CODE 128 B](https://raw.githubusercontent.com/DavBfr/dart_barcode/master/img/code-128b.png)
  static Barcode code128() => const BarcodeCode128();

  /// Create an EAN 13 `Barcode` instance
  /// ![EAN 13](https://raw.githubusercontent.com/DavBfr/dart_barcode/master/img/ean-13.png)
  static Barcode ean13() => const BarcodeEan13();

  /// Create an EAN 8 `Barcode` instance
  /// ![EAN 8](https://raw.githubusercontent.com/DavBfr/dart_barcode/master/img/ean-8.png)
  static Barcode ean8() => const BarcodeEan8();

  /// Create an ISBN `Barcode` instance
  /// ![EAN 8](https://raw.githubusercontent.com/DavBfr/dart_barcode/master/img/isbn.png)
  static Barcode isbn() => const BarcodeIsbn();

  /// Main method to produce the barcode graphic desctiotion.
  /// Returns a stream of drawing operations required to properly
  /// display the barcode.
  ///
  /// Use it with:
  /// ```dart
  /// for (var op in Barcode.code39().make('HELLO', width: 200, height: 300)) {
  ///   print(op);
  /// }
  /// ```
  Iterable<BarcodeElement> make(
    String data, {
    @required double width,
    @required double height,
    bool drawText = false,
    double fontHeight,
  }) sync* {
    assert(data != null);
    assert(width != null && width > 0);
    assert(height != null && height > 0);
    assert(!drawText || fontHeight != null);

    final List<bool> bits = convert(data).toList();

    if (bits.isEmpty) {
      return;
    }

    final double lineWidth = width / bits.length;

    bool color = bits.first;
    int count = 1;

    for (int i = 1; i < bits.length; i++) {
      if (color == bits[i]) {
        count++;
        continue;
      }

      yield BarcodeBar(
        left: (i - count) * lineWidth,
        top: 0,
        width: count * lineWidth,
        height: height - (drawText ? fontHeight : 0),
        black: color,
      );

      color = bits[i];
      count = 1;
    }

    yield BarcodeBar(
      left: (bits.length - count) * lineWidth,
      top: 0,
      width: count * lineWidth,
      height: height - (drawText ? fontHeight : 0),
      black: color,
    );

    if (drawText) {
      yield* makeText(data, width, height, fontHeight);
    }
  }

  /// Stream the text operations required to draw the
  /// barcode texts. This is automatically called by `make`
  @protected
  Iterable<BarcodeText> makeText(
    String data,
    double width,
    double height,
    double fontHeight,
  ) sync* {
    yield BarcodeText(
      left: 0,
      top: height - fontHeight,
      width: width,
      height: fontHeight,
      text: data,
    );
  }

  /// Build a stream of `bool` that represents a white or black bar
  /// from a bit encoded `int` with count as the number of bars to draw
  @protected
  Iterable<bool> add(int data, int count) sync* {
    for (int i = 0; i < count; i++) {
      yield (1 & (data >> i)) == 1;
    }
  }

  /// Computes a hexadecimal representation of the barcode, mostly for
  /// testing purposes
  String toHex(String data) {
    String intermediate = '';
    for (bool bit in convert(data)) {
      intermediate += bit ? '1' : '0';
    }

    String result = '';
    while (intermediate.length > 8) {
      final String sub = intermediate.substring(intermediate.length - 8);
      result += int.parse(sub, radix: 2).toRadixString(16);
      intermediate = intermediate.substring(0, intermediate.length - 8);
    }
    result += int.parse(intermediate, radix: 2).toRadixString(16);

    return result;
  }

  /// Actual barcode computation method, returns a stream of `bool`
  /// which represents the presence or absence of a bar
  @protected
  Iterable<bool> convert(String data);

  /// Returns the list of accepted codePoints for this `Barcode`
  Iterable<int> get charSet;

  /// Returns the name of this `Barcode`
  String get name;
}
