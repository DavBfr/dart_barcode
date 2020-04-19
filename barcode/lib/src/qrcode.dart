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

import 'package:qr/qr.dart';

import 'barcode_2d.dart';

/// QR Code Correction Level
enum BarcodeQRCorrectionLevel {
  /// 7% of codewords can be restored.
  low,

  /// 15% of codewords can be restored.
  medium,

  /// 25% of codewords can be restored.
  quartile,

  /// 30% of codewords can be restored
  high,
}

/// QR Code
///
/// QR code (abbreviated from Quick Response code) is the trademark for a
/// type of matrix barcode (or two-dimensional barcode) first designed in 1994
/// for the automotive industry in Japan.
class BarcodeQR extends Barcode2D {
  /// Create a [BarcodeQR] object
  const BarcodeQR(
    this.typeNumber,
    this.errorCorrectLevel,
  )   : assert(typeNumber == null || (typeNumber >= 1 && typeNumber <= 40)),
        assert(errorCorrectLevel != null);

  /// QR code version number 1 to 40
  final int typeNumber;

  /// The QR Code Correction Level
  final BarcodeQRCorrectionLevel errorCorrectLevel;

  @override
  Barcode2DMatrix convert(String data) {
    final errorLevel = QrErrorCorrectLevel.levels[errorCorrectLevel.index];

    final qrCode = typeNumber == null
        ? QrCode.fromData(data: data, errorCorrectLevel: errorLevel)
        : (QrCode(typeNumber, QrErrorCorrectLevel.L)..addData(data));

    qrCode.make();

    return Barcode2DMatrix.fromXY(
      qrCode.moduleCount,
      qrCode.moduleCount,
      1,
      qrCode.isDark,
    );
  }

  @override
  Iterable<int> get charSet => Iterable<int>.generate(256);

  @override
  String get name => 'QR-Code';

  @override
  int get maxLength => 2953;
}
