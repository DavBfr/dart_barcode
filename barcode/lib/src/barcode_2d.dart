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

import 'barcode.dart';
import 'barcode_operations.dart';

/// Matrix representing the raw code pixels
class Barcode2DMatrix {
  /// Create a 2d barcode matrix
  const Barcode2DMatrix(this.width, this.height, this.ratio, this.pixels);

  /// Create a 2d barcode matrix from a function callback
  factory Barcode2DMatrix.fromXY(
    int width,
    int height,
    double ratio,
    bool Function(int x, int y) isDark,
  ) =>
      Barcode2DMatrix(
          width,
          height,
          ratio,
          Iterable<bool>.generate(width * height, (p) {
            final x = p % height;
            final y = p ~/ height;
            return isDark(y, x);
          }));

  /// The width of the matrix
  final int width;

  /// The height of the matrix
  final int height;

  /// The pixel ratio (width/height)
  final double ratio;

  /// The pixels of the matrix
  final Iterable<bool> pixels;
}

/// Two Dimension Barcode generation class
abstract class Barcode2D extends Barcode {
  /// Create a [Barcode2D] object
  const Barcode2D();

  @override
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

    final matrix = convert(data);

    double pixelW;
    double pixelH;
    double offsetX;
    double offsetY;

    if (width > height) {
      pixelW = height / matrix.height;
      pixelH = pixelW * matrix.ratio;
      offsetX = (width - height) / 2;
      offsetY = 0;
    } else {
      pixelW = width / matrix.width;
      pixelH = pixelW * matrix.ratio;
      offsetX = 0;
      offsetY = (height - width) / 2;
    }

    var start = 0;
    bool color;
    var x = 0;
    var y = 0;

    for (final pixel in matrix.pixels) {
      color ??= pixel;

      if (pixel != color) {
        yield BarcodeBar(
          left: offsetX + start * pixelW,
          top: offsetY + y * pixelH,
          width: (x - start) * pixelW,
          height: pixelH,
          black: color,
        );

        color = pixel;
        start = x;
      }

      x++;
      if (x >= matrix.width) {
        yield BarcodeBar(
          left: offsetX + start * pixelW,
          top: offsetY + y * pixelH,
          width: (matrix.width - start) * pixelW,
          height: pixelH,
          black: color,
        );
        color = null;
        start = 0;
        x = 0;
        y++;
      }
    }
  }

  /// Actual barcode computation method, returns a matrix of [bool]
  /// which represents the presence or absence of a pixel
  Barcode2DMatrix convert(String data);
}
