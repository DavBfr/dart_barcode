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

import 'code39.dart';

enum BarcodeType {
  CodeEAN13,
  CodeEAN8,
  Code39,
  Code93,
  CodeUPCA,
  CodeUPCE,
  Code128,
}

abstract class Barcode {
  Barcode(this.draw) : assert(draw != null);

  factory Barcode.fromType({
    @required BarcodeType type,
    @required BarcodeDraw draw,
  }) {
    assert(type != null);

    switch (type) {
      case BarcodeType.CodeEAN13:
      case BarcodeType.CodeEAN8:
      case BarcodeType.Code93:
      case BarcodeType.CodeUPCA:
      case BarcodeType.CodeUPCE:
      case BarcodeType.Code128:
      case BarcodeType.Code39:
      default:
        return BarcodeCode39(draw: draw);
    }
  }

  factory Barcode.code39({BarcodeDraw draw}) => BarcodeCode39(draw: draw);

  final BarcodeDraw draw;

  void make(String data, double width, double height);
}

abstract class BarcodeDraw {
  void fillRect(
      double left, double top, double width, double height, bool black);
}

class BarcodeException implements Exception {
  const BarcodeException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}
