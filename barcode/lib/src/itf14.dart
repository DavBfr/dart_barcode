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

/// ITF-14 Barcode
///
/// ITF-14 is the GS1 implementation of an Interleaved 2 of 5 (ITF) bar code
/// to encode a Global Trade Item Number. ITF-14 symbols are generally used
/// on packaging levels of a product, such as a case box of 24 cans of soup.
/// The ITF-14 will always encode 14 digits.
class BarcodeItf14 extends BarcodeItf {
  /// Create an ITF-14 Barcode
  const BarcodeItf14(
    bool drawBorder,
    double? borderWidth,
    double? quietWidth,
  ) : super(true, true, drawBorder, borderWidth, quietWidth, 14);

  @override
  String get name => 'ITF 14';

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
        '${data.substring(0, 1)} ${data.substring(1, 3)} ${data.substring(3, 8)} ${data.substring(8, 13)} ${data.substring(13, 14)}';
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
