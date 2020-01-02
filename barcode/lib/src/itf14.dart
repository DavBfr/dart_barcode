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

import 'barcode_exception.dart';
import 'barcode_maps.dart';
import 'barcode_operations.dart';
import 'ean.dart';

class BarcodeItf14 extends BarcodeEan {
  const BarcodeItf14(this.drawBorder, this.borderWidth, this.quietWidth);

  final bool drawBorder;

  final double borderWidth;

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

    final List<int> cu = data.codeUnits;
    for (int i = 0; i < cu.length / 2; i++) {
      final List<int> tuple = <int>[
        BarcodeMaps.itf14[cu[i * 2]],
        BarcodeMaps.itf14[cu[i * 2 + 1]]
      ];

      if (tuple[0] == null || tuple[1] == null) {
        throw BarcodeException(
            'Unable to encode "${String.fromCharCode(cu[i * 2])}${String.fromCharCode(cu[i * 2 + 1])}" to $name Barcode');
      }

      for (int n = 0; n < 10; n++) {
        final int v = (tuple[n % 2] >> (n ~/ 2)) & 1;
        final bool c = n % 2 == 0;
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

  double getBorderWidth(double width) {
    return borderWidth ?? width * .015;
  }

  double getQuietWidth(double width) {
    return quietWidth ?? width * .07;
  }

  @override
  double marginTop(
    bool drawText,
    double width,
    double height,
    double fontHeight,
  ) {
    return drawBorder ? getBorderWidth(width) : 0;
  }

  @override
  double marginLeft(
    bool drawText,
    double width,
    double height,
    double fontHeight,
  ) {
    return drawBorder ? getBorderWidth(width) + getQuietWidth(width) : 0;
  }

  @override
  double marginRight(
      bool drawText, double width, double height, double fontHeight) {
    return drawBorder ? getBorderWidth(width) + getQuietWidth(width) : 0;
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
        (drawBorder ? getBorderWidth(width) : 0);
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

    final double bw = getBorderWidth(width);

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
  Iterable<BarcodeText> makeText(
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
