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

import 'barcode_1d.dart';
import 'barcode_exception.dart';
import 'barcode_maps.dart';
import 'barcode_operations.dart';
import 'ean.dart';

/// 2 of 5 Barcode
///
/// Interleaved 2 of 5 (ITF) is a continuous two-width barcode symbology
/// encoding digits. It is used commercially on 135 film, for ITF-14 barcodes,
/// and on cartons of some products, while the products inside are labeled
/// with UPC or EAN.
class BarcodeItf extends BarcodeEan {
  /// Create an ITF-14 Barcode
  const BarcodeItf(
    this.addChecksum,
    this.zeroPrepend,
    this.drawBorder,
    this.borderWidth,
    this.quietWidth,
    this.fixedLength,
  ) : assert(fixedLength == null || fixedLength % 2 == 0);

  /// Add Modulo 10 checksum
  final bool addChecksum;

  /// Prepend with a '0' if the length is not odd
  final bool zeroPrepend;

  /// Draw a black border around the barcode
  final bool drawBorder;

  /// Width of the border around the barcode
  final double? borderWidth;

  /// width of the quiet zone before and after the barcode, inside the border
  final double? quietWidth;

  /// The Barcode length if fixed length
  final int? fixedLength;

  @override
  String get name => 'ITF';

  @override
  int get minLength => fixedLength != null ? fixedLength! - 1 : super.minLength;

  @override
  int get maxLength => fixedLength != null ? fixedLength! : super.maxLength;

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
    double textPadding,
  ) {
    return drawBorder ? _getBorderWidth(width) : 0;
  }

  @override
  double marginLeft(
    bool drawText,
    double width,
    double height,
    double fontHeight,
    double textPadding,
  ) {
    return drawBorder ? _getBorderWidth(width) + _getQuietWidth(width) : 0;
  }

  @override
  double marginRight(
    bool drawText,
    double width,
    double height,
    double fontHeight,
    double textPadding,
  ) {
    return drawBorder ? _getBorderWidth(width) + _getQuietWidth(width) : 0;
  }

  @override
  double getHeight(
    int index,
    int count,
    double width,
    double height,
    double fontHeight,
    double textPadding,
    bool drawText,
  ) {
    return super.getHeight(
          index,
          count,
          width,
          height,
          fontHeight,
          textPadding,
          drawText,
        ) -
        (drawBorder ? _getBorderWidth(width) : 0);
  }

  @override
  Iterable<bool> convert(String data) sync* {
    if (fixedLength != null) {
      data = checkLength(data, fixedLength!);
    } else {
      if (zeroPrepend && ((data.length % 2 != 0) != addChecksum)) {
        data = '0$data';
      }

      if (addChecksum) {
        data += checkSumModulo10(data);
      }

      if (data.length % 2 != 0) {
        throw BarcodeException(
            '$name barcode can only encode an even number of digits.');
      }
    }

    // Start
    yield* add(BarcodeMaps.itfStart, 4);

    final cu = data.codeUnits;
    for (var i = 0; i < cu.length / 2; i++) {
      final tuple = <int?>[
        BarcodeMaps.itf[cu[i * 2]],
        BarcodeMaps.itf[cu[i * 2 + 1]]
      ];

      if (tuple[0] == null || tuple[1] == null) {
        throw BarcodeException(
            'Unable to encode "${String.fromCharCode(cu[i * 2])}${String.fromCharCode(cu[i * 2 + 1])}" to $name Barcode');
      }

      for (var n = 0; n < 10; n++) {
        final v = (tuple[n % 2]! >> (n ~/ 2)) & 1;
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

  @override
  Iterable<BarcodeElement> makeBytes(
    Uint8List data, {
    required double width,
    required double height,
    bool drawText = false,
    double? fontHeight,
    double? textPadding,
  }) sync* {
    assert(width > 0);
    assert(height > 0);
    assert(!drawText || fontHeight != null);
    fontHeight ??= 0;
    textPadding ??= Barcode1D.defaultTextPadding;

    yield* super.makeBytes(
      data,
      width: width,
      height: height,
      drawText: drawText,
      fontHeight: fontHeight,
      textPadding: textPadding,
    );

    if (drawBorder) {
      final bw = _getBorderWidth(width);
      final hp = drawText ? fontHeight + textPadding : 0;

      yield BarcodeBar(left: 0, top: 0, width: width, height: bw, black: true);
      yield BarcodeBar(
          left: 0,
          top: height - hp - bw,
          width: width,
          height: bw,
          black: true);
      yield BarcodeBar(
          left: 0,
          top: bw,
          width: bw,
          height: height - hp - bw * 2,
          black: true);
      yield BarcodeBar(
          left: width - bw,
          top: bw,
          width: bw,
          height: height - hp - bw * 2,
          black: true);
    }
  }

  @override
  Iterable<BarcodeElement> makeText(
    String data,
    double width,
    double height,
    double fontHeight,
    double textPadding,
    double lineWidth,
  ) {
    if (fixedLength != null) {
    } else {
      if (zeroPrepend && ((data.length % 2 != 0) != addChecksum)) {
        data = '0$data';
      }

      if (addChecksum) {
        data += checkSumModulo10(data);
      }
    }

    return super.makeText(
      data,
      width,
      height,
      fontHeight,
      textPadding,
      lineWidth,
    );
  }

  @override
  void verifyBytes(Uint8List data) {
    var text = utf8.decoder.convert(data);

    if (fixedLength != null) {
      text = checkLength(text, maxLength);
    } else {
      if (zeroPrepend && ((text.length % 2 != 0) != addChecksum)) {
        text = '0$text';
      }

      if (addChecksum) {
        text += checkSumModulo10(text);
      }
    }

    if (text.length % 2 != 0) {
      throw BarcodeException(
          '$name barcode can only encode an even number of digits.');
    }

    super.verifyBytes(utf8.encoder.convert(text));
  }

  @override
  String normalize(String data) {
    if (fixedLength != null) {
      return checkLength(
          zeroPrepend
              ? data.padRight(minLength, '0').substring(0, minLength)
              : data,
          maxLength);
    }

    if (zeroPrepend && ((data.length % 2 != 0) != addChecksum)) {
      data = '0$data';
    }

    if (addChecksum) {
      data += checkSumModulo10(data);
    }

    return data;
  }
}
