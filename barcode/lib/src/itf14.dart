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

import 'package:meta/meta.dart';

import 'barcode_exception.dart';
import 'barcode_maps.dart';
import 'barcode_operations.dart';
import 'ean.dart';

/// ITF-14 Barcode
///
/// ITF-14 is the GS1 implementation of an Interleaved 2 of 5 (ITF) bar code
/// to encode a Global Trade Item Number. ITF-14 symbols are generally used
/// on packaging levels of a product, such as a case box of 24 cans of soup.
/// The ITF-14 will always encode 14 digits.
class BarcodeItf14 extends BarcodeEan {
  /// Create an ITF-14 Barcode
  const BarcodeItf14(this.drawBorder, this.borderWidth, this.quietWidth);

  /// Draw a black border around the barcode
  final bool drawBorder;

  /// Width of the border around the barcode
  final double borderWidth;

  /// width of the quiet zone before and after the barcode, inside the border
  final double quietWidth;

  @override
  String get name => 'ITF 14';

  @override
  int get minLength => 13;

  @override
  int get maxLength => 14;

  @override
  void verify(String data) {
    checkLength(data, maxLength);
    super.verify(data);
  }

  @override
  Iterable<bool> convert(String data) sync* {
    data = checkLength(data, maxLength);

    // Start
    yield* add(BarcodeMaps.itfStart, 4);

    final cu = data.codeUnits;
    for (var i = 0; i < cu.length / 2; i++) {
      final tuple = <int>[
        BarcodeMaps.itf14[cu[i * 2]],
        BarcodeMaps.itf14[cu[i * 2 + 1]]
      ];

      if (tuple[0] == null || tuple[1] == null) {
        throw BarcodeException(
            'Unable to encode "${String.fromCharCode(cu[i * 2])}${String.fromCharCode(cu[i * 2 + 1])}" to $name Barcode');
      }

      for (var n = 0; n < 10; n++) {
        final v = (tuple[n % 2] >> (n ~/ 2)) & 1;
        final c = n % 2 == 0;
        yield c;
        if (v != 0) {
          yield c;
          yield c;
        }
      }
    }

    // End
    yield* add(BarcodeMaps.itfEnd, 5);
  }

  double _getBorderWidth(double width) {
    return borderWidth ?? width * .015;
  }

  double _getQuietWidth(double width) {
    return quietWidth ?? width * .07;
  }

  @override
  double marginTop(
    bool drawText,
    double width,
    double height,
    double fontHeight,
  ) {
    return drawBorder ? _getBorderWidth(width) : 0;
  }

  @override
  double marginLeft(
    bool drawText,
    double width,
    double height,
    double fontHeight,
  ) {
    return drawBorder ? _getBorderWidth(width) + _getQuietWidth(width) : 0;
  }

  @override
  double marginRight(
      bool drawText, double width, double height, double fontHeight) {
    return drawBorder ? _getBorderWidth(width) + _getQuietWidth(width) : 0;
  }

  @override
  double getHeight(
    int index,
    int count,
    double width,
    double height,
    double fontHeight,
    bool drawText,
  ) {
    return super.getHeight(index, count, width, height, fontHeight, drawText) -
        (drawBorder ? _getBorderWidth(width) : 0);
  }

  @override
  Iterable<BarcodeElement> make(
    String data, {
    @required double width,
    @required double height,
    bool drawText = false,
    double fontHeight,
  }) sync* {
    yield* super.make(data,
        width: width,
        height: height,
        drawText: drawText,
        fontHeight: fontHeight);

    final bw = _getBorderWidth(width);

    if (drawBorder) {
      yield BarcodeBar(left: 0, top: 0, width: width, height: bw, black: true);
      yield BarcodeBar(
          left: 0,
          top: height - fontHeight - bw,
          width: width,
          height: bw,
          black: true);
      yield BarcodeBar(
          left: 0,
          top: bw,
          width: bw,
          height: height - fontHeight - bw * 2,
          black: true);
      yield BarcodeBar(
          left: width - bw,
          top: bw,
          width: bw,
          height: height - fontHeight - bw * 2,
          black: true);
    }
  }

  @override
  Iterable<BarcodeElement> makeText(
    String data,
    double width,
    double height,
    double fontHeight,
    double lineWidth,
  ) {
    data = checkLength(data, maxLength);
    data = data.substring(0, 1) +
        ' ' +
        data.substring(1, 3) +
        ' ' +
        data.substring(3, 8) +
        ' ' +
        data.substring(8, 13) +
        ' ' +
        data.substring(13, 14);
    return super.makeText(data, width, height, fontHeight, lineWidth);
  }
}
