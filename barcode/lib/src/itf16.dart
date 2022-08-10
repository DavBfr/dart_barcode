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

import 'barcode_operations.dart';
import 'itf.dart';

/// ITF-16 Barcode
///
/// ITF-16 is a standardized version of the Interleaved 2 of 5 barcode,
/// also known as UPC Shipping Container Symbol. It is used to mark cartons,
/// cases, or pallets that contain products. It containins 16 digits, the last
/// being a check digit.
class BarcodeItf16 extends BarcodeItf {
  /// Create an ITF-16 Barcode
  const BarcodeItf16(
    bool drawBorder,
    double? borderWidth,
    double? quietWidth,
  ) : super(true, true, drawBorder, borderWidth, quietWidth, 16);

  @override
  String get name => 'ITF 16';

  @override
  Iterable<BarcodeElement> makeText(
    String data,
    double width,
    double height,
    double fontHeight,
    double textPadding,
    double lineWidth,
  ) {
    data = checkLength(data, maxLength);
    data =
        '${data.substring(0, 1)} ${data.substring(1, 3)} ${data.substring(3, 5)} ${data.substring(5, 10)} ${data.substring(10, 15)} ${data.substring(15, 16)}';
    return super.makeText(
      data,
      width,
      height,
      fontHeight,
      textPadding,
      lineWidth,
    );
  }
}
