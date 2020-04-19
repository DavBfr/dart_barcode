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

import 'dart:convert';

import 'package:meta/meta.dart';

import 'barcode_exception.dart';
import 'barcode_operations.dart';
import 'code128.dart';
import 'code39.dart';
import 'code93.dart';
import 'ean13.dart';
import 'ean2.dart';
import 'ean5.dart';
import 'ean8.dart';
import 'isbn.dart';
import 'itf14.dart';
import 'qrcode.dart';
import 'telepen.dart';
import 'upca.dart';
import 'upce.dart';

export 'qrcode.dart' show BarcodeQRCorrectionLevel;

/// Supported barcode types
enum BarcodeType {
  /// ITF14 Barcode
  CodeITF14,

  /// EAN 13 barcode
  CodeEAN13,

  /// EAN 8 barcode
  CodeEAN8,

  /// EAN 5 barcode
  CodeEAN5,

  /// EAN 2 barcode
  CodeEAN2,

  /// ISBN barcode
  CodeISBN,

  /// Code 39 barcode
  Code39,

  /// Code 93 barcode
  Code93,

  /// UPC-A barcode
  CodeUPCA,

  /// UPC-E barcode
  CodeUPCE,

  /// Code 128 barcode
  Code128,

  /// GS1-128 barcode
  GS128,

  /// Telepen Barcode
  Telepen,

  /// QR Code
  QrCode,
}

/// Barcode generation class
@immutable
abstract class Barcode {
  /// Abstract constructor
  const Barcode();

  /// Create a specific [Barcode] instance based on the [BarcodeType]
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
        return Barcode.code39();
      case BarcodeType.Code93:
        return Barcode.code93();
      case BarcodeType.Code128:
        return Barcode.code128();
      case BarcodeType.GS128:
        return Barcode.gs128();
      case BarcodeType.CodeITF14:
        return Barcode.itf14();
      case BarcodeType.CodeEAN13:
        return Barcode.ean13();
      case BarcodeType.CodeEAN8:
        return Barcode.ean8();
      case BarcodeType.CodeEAN5:
        return Barcode.ean5();
      case BarcodeType.CodeEAN2:
        return Barcode.ean2();
      case BarcodeType.CodeISBN:
        return Barcode.isbn();
      case BarcodeType.CodeUPCA:
        return Barcode.upcA();
      case BarcodeType.CodeUPCE:
        return Barcode.upcE();
      case BarcodeType.Telepen:
        return Barcode.telepen();
      case BarcodeType.QrCode:
        return Barcode.qrCode();
      default:
        throw UnimplementedError('Barcode $type not supported');
    }
  }

  /// Create a CODE 39 [Barcode] instance:
  /// ![CODE 39](https://raw.githubusercontent.com/DavBfr/dart_barcode/master/img/code-39.svg?sanitize=true)
  static Barcode code39() => const BarcodeCode39();

  /// Create a CODE 93 [Barcode] instance:
  /// ![CODE 93](https://raw.githubusercontent.com/DavBfr/dart_barcode/master/img/code-93.svg?sanitize=true)
  static Barcode code93() => const BarcodeCode93();

  /// Create a CODE 128 [Barcode] instance
  /// ![CODE 128 B](https://raw.githubusercontent.com/DavBfr/dart_barcode/master/img/code-128b.svg?sanitize=true)
  static Barcode code128(
          {bool useCode128A = true,
          bool useCode128B = true,
          bool useCode128C = true}) =>
      BarcodeCode128(useCode128A, useCode128B, useCode128C, false);

  /// Create a GS1-128 [Barcode] instance
  /// ![GS1-128](https://raw.githubusercontent.com/DavBfr/dart_barcode/master/img/gs1-128.svg?sanitize=true)
  static Barcode gs128() => const BarcodeCode128(true, true, true, true);

  /// Create an ITF 14 [Barcode] instance
  /// ![ITF 14](https://raw.githubusercontent.com/DavBfr/dart_barcode/master/img/itf-14.svg?sanitize=true)
  static Barcode itf14({
    bool drawBorder = true,
    double borderWidth,
    double quietWidth,
  }) =>
      BarcodeItf14(drawBorder, borderWidth, quietWidth);

  /// Create an EAN 13 [Barcode] instance
  /// ![EAN 13](https://raw.githubusercontent.com/DavBfr/dart_barcode/master/img/ean-13.svg?sanitize=true)
  static Barcode ean13({bool drawEndChar = false}) => BarcodeEan13(drawEndChar);

  /// Create an EAN 8 [Barcode] instance
  /// ![EAN 8](https://raw.githubusercontent.com/DavBfr/dart_barcode/master/img/ean-8.svg?sanitize=true)
  static Barcode ean8({bool drawSpacers = false}) => BarcodeEan8(drawSpacers);

  /// Create an EAN 5 [Barcode] instance
  /// ![EAN 5](https://raw.githubusercontent.com/DavBfr/dart_barcode/master/img/ean-5.svg?sanitize=true)
  static Barcode ean5() => const BarcodeEan5();

  /// Create an EAN 2 [Barcode] instance
  /// ![EAN 2](https://raw.githubusercontent.com/DavBfr/dart_barcode/master/img/ean-2.svg?sanitize=true)
  static Barcode ean2() => const BarcodeEan2();

  /// Create an ISBN [Barcode] instance
  /// ![EAN 8](https://raw.githubusercontent.com/DavBfr/dart_barcode/master/img/isbn.svg?sanitize=true)
  static Barcode isbn({bool drawEndChar = false, bool drawIsbn = true}) =>
      BarcodeIsbn(drawEndChar, drawIsbn);

  /// Create an UPC A [Barcode] instance
  /// ![UPC A](https://raw.githubusercontent.com/DavBfr/dart_barcode/master/img/upc-a.svg?sanitize=true)
  static Barcode upcA() => const BarcodeUpcA();

  /// Create an UPC E [Barcode] instance
  /// * set fallback to true to silently try UPC-A if the code is not compatible with UPC-E
  /// ![UPC E](https://raw.githubusercontent.com/DavBfr/dart_barcode/master/img/upc-e.svg?sanitize=true)
  static Barcode upcE({bool fallback = false}) => BarcodeUpcE(fallback);

  /// Create a Telepen [Barcode] instance
  /// ![Telepen](https://raw.githubusercontent.com/DavBfr/dart_barcode/master/img/telepen.svg?sanitize=true)
  static Barcode telepen() => const BarcodeTelepen();

  /// Create a QR-Code [Barcode] instance
  /// ![QR-Code](https://raw.githubusercontent.com/DavBfr/dart_barcode/master/img/qr-code.svg?sanitize=true)
  static Barcode qrCode(
          {int typeNumber,
          BarcodeQRCorrectionLevel errorCorrectLevel =
              BarcodeQRCorrectionLevel.low}) =>
      BarcodeQR(typeNumber: typeNumber, errorCorrectLevel: errorCorrectLevel);

  /// Main method to produce the barcode graphic description.
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
  });

  /// Check if the Barcode is valid
  bool isValid(String data) {
    try {
      verify(data);
    } catch (_) {
      return false;
    }

    return true;
  }

  /// Check if the Barcode is valid. Throws [BarcodeException] with a proper
  /// message in case of error
  @mustCallSuper
  void verify(String data) {
    if (data.length > maxLength) {
      throw BarcodeException(
          'Unable to encode "$data", maximum length is $maxLength for $name Barcode');
    }

    if (data.length < minLength) {
      throw BarcodeException(
          'Unable to encode "$data", minimum length is $minLength for $name Barcode');
    }

    final chr = charSet.toSet();

    for (var code in data.codeUnits) {
      if (!chr.contains(code)) {
        throw BarcodeException(
            'Unable to encode "${String.fromCharCode(code)}" to $name Barcode');
      }
    }
  }

  String _d(double d) {
    assert(d != double.infinity);
    return d.toStringAsFixed(5);
  }

  String _s(String s) {
    const esc = HtmlEscape();
    return esc.convert(s);
  }

  String _c(int c) {
    return '#' + (c & 0xffffff).toRadixString(16).padLeft(6, '0');
  }

  /// Create a SVG file with this Barcode
  String toSvg(
    String data, {
    double x = 0,
    double y = 0,
    double width = 200,
    double height = 80,
    bool drawText = true,
    String fontFamily = 'monospace',
    double fontHeight,
    int color = 0x000000,
    bool fullSvg = true,
    double baseline = .75,
  }) {
    assert(data != null);
    assert(x != null);
    assert(y != null);
    assert(width != null);
    assert(height != null);
    assert(fontFamily != null);
    assert(color != null);
    assert(baseline != null);

    fontHeight ??= height * 0.2;

    final path = StringBuffer();
    final tspan = StringBuffer();

    // Draw the barcode
    for (var elem in make(
      data,
      width: width.toDouble(),
      height: height.toDouble(),
      drawText: drawText,
      fontHeight: fontHeight,
    )) {
      if (elem is BarcodeBar) {
        if (elem.black) {
          path.write('M ${_d(x + elem.left)} ${_d(y + elem.top)} ');
          path.write('h ${_d(elem.width)} ');
          path.write('v ${_d(elem.height)} ');
          path.write('h ${_d(-elem.width)} ');
          path.write('z ');
        }
      } else if (elem is BarcodeText) {
        final _y = y + elem.top + elem.height * baseline;

        double _x;
        String anchor;
        switch (elem.align) {
          case BarcodeTextAlign.left:
            _x = x + elem.left;
            anchor = 'start';
            break;
          case BarcodeTextAlign.center:
            _x = x + elem.left + elem.width / 2;
            anchor = 'middle';
            break;
          case BarcodeTextAlign.right:
            _x = x + elem.left + elem.width;
            anchor = 'end';
            break;
        }

        tspan.write(
            '<tspan style="text-anchor: $anchor" x="${_d(_x)}" y="${_d(_y)}">${_s(elem.text)}</tspan>');
      }
    }

    final output = StringBuffer();
    if (fullSvg) {
      output.write(
          '<svg viewBox="${_d(x)} ${_d(y)} ${_d(width)} ${_d(height)}" xmlns="http://www.w3.org/2000/svg">');
    }

    output.write('<path d="$path" style="fill: ${_c(color)}"/>');
    output.write(
        '<text style="fill: ${_c(color)}; font-family: &quot;${_s(fontFamily)}&quot;; font-size: ${_d(fontHeight)}px" x="${_d(x)}" y="${_d(y)}">$tspan</text>');

    if (fullSvg) {
      output.write('</svg>');
    }

    return output.toString();
  }

  /// Returns the list of accepted codePoints for this [Barcode]
  Iterable<int> get charSet;

  /// Returns the name of this [Barcode]
  String get name;

  static const int _infiniteMaxLength = 1000;

  /// Returns maximum number of characters this [Barcode] can encode
  int get maxLength => _infiniteMaxLength;

  /// Returns minimum number of characters this [Barcode] can encode
  int get minLength => 1;

  @override
  String toString() => 'Barcode $name';
}
