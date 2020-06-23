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
import 'dart:typed_data';

import 'package:meta/meta.dart';

import 'barcode_operations.dart';
import 'itf.dart';

/// ITF-14 Barcode
///
/// ITF-14 is the GS1 implementation of an Interleaved 2 of 5 (ITF) bar code
/// to encode a Global Trade Item Number. ITF-14 symbols are generally used
/// on packaging levels of a product, such as a case box of 24 cans of soup.
/// The ITF-14 will always encode 14 digits.
class BarcodeItf14 extends BarcodeItf {
  /// Create an ITF-14 Barcode
  const BarcodeItf14(
    this.drawBorder,
    this.borderWidth,
    this.quietWidth,
  )   : assert(drawBorder != null),
        super(false, false);

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
  void verifyBytes(Uint8List data) {
    final text = utf8.decoder.convert(data);
    data = utf8.encoder.convert(checkLength(text, maxLength));
    super.verifyBytes(data);
  }

  @override
  Iterable<bool> convert(String data) {
    data = checkLength(data, maxLength);
    return super.convert(data);
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
  Iterable<BarcodeElement> makeBytes(
    Uint8List data, {
    @required double width,
    @required double height,
    bool drawText = false,
    double fontHeight,
  }) sync* {
    yield* super.makeBytes(data,
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
