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

/// `Barcode` drawing operation
class BarcodeElement {
  const BarcodeElement({
    @required this.left,
    @required this.top,
    @required this.width,
    @required this.height,
  })  : assert(left != null),
        assert(top != null),
        assert(width != null),
        assert(height != null);

  /// left position of this element
  final double left;

  /// top position of this element
  final double top;

  /// width of this element
  final double width;

  /// height of this element
  final double height;

  /// right position of this element
  double get right => left + width;

  /// bottom position of this element
  double get bottom => top + height;

  @override
  String toString() => '$runtimeType $left $top $width $height';
}

/// Rectangle drawing operation
class BarcodeBar extends BarcodeElement {
  const BarcodeBar({
    @required double left,
    @required double top,
    @required double width,
    @required double height,
    @required this.black,
  }) : super(
          left: left,
          top: top,
          width: width,
          height: height,
        );

  /// Black or white color of this rectangle
  final bool black;

  @override
  String toString() =>
      '$runtimeType [${black ? 'X' : ' '}] $left $top $width $height';
}

/// Text drawing operation
class BarcodeText extends BarcodeElement {
  const BarcodeText({
    @required double left,
    @required double top,
    @required double width,
    @required double height,
    @required this.text,
  }) : super(
          left: left,
          top: top,
          width: width,
          height: height,
        );

  /// Text to display in this rectangle
  final String text;

  @override
  String toString() => '$runtimeType "$text" $left $top $width $height';
}
