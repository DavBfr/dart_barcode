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

import 'barcode_exception.dart';
import 'barcode_maps.dart';
import 'barcode_operations.dart';
import 'ean.dart';
import 'upca.dart';

/// UPC-E Barcode
///
/// The Universal Product Code is a barcode symbology that is widely used in
/// the United States, Canada, Europe, Australia, New Zealand, and other
/// countries for tracking trade items in stores. To allow the use of UPC
/// barcodes on smaller packages, where a full 12-digit barcode may not fit,
/// a zero-suppressed version of UPC was developed, called UPC-E, in which
/// the number system digit, all trailing zeros in the manufacturer code,
/// and all leading zeros in the product code, are suppressed.
class BarcodeUpcE extends BarcodeEan {
  /// Create an UPC-E Barcode
  const BarcodeUpcE(this.fallback);

  /// Fallback to UPC-A if the code cannot be converted to UPC-E
  final bool fallback;

  @override
  String get name => 'UPC E';

  @override
  int get minLength => 6;

  @override
  int get maxLength => 12;

  @override
  void verifyBytes(Uint8List data) {
    var text = utf8.decoder.convert(data);

    if (text.length <= 8) {
      // Try to convert UPC-E to UPC-A
      text = upceToUpca(text);
    }

    if (text.length < 11) {
      throw BarcodeException(
          'Unable to encode "$text", minimum length is 11 for $name Barcode');
    }

    final upca = checkLength(text, maxLength);
    if (!fallback) {
      upcaToUpce(upca);
    }

    super.verifyBytes(utf8.encoder.convert(text));
  }

  /// Convert an UPC-A barcode to a short version UPC-E
  String upcaToUpce(String data) {
    //Basic checking of string headers and lengths.
    if ( RegExp(r'^[01]\d{11}$').firstMatch(data) == null) {
      throw BarcodeException('Unable to convert "$data" to $name Barcode');
    }

    //Refer to  https://www.keepautomation.com/upca/upca-to-upce-conversion.html
    //and https://en.wikipedia.org/wiki/Universal_Product_Code#UPC-E
    if([0x35, 0x36, 0x37, 0x38, 0x39].contains(data.codeUnits[10]) && data.substring(6,10) == '0000' && data[5] != '0') {
      //If the 11th code of UPC-A equals to 5, 6, 7, 8 or 9, the 7th to 10th code are all 0, and the 6th is not 0,
      //adding the 2nd to 6th code and 11th code of UPC-A to present the 1st to 6th of UPC-E.
      return data.substring(1,6) + data[10];
    }
    else if(data.substring(5,10) == '00000' && data[4] != '0'){
      // If the 6th to 10th code are all 0, and the 5th is not 0,
      // adding the 2nd to 5th code, 11th code of UPC-A and a digit 4 to present the 1st to 6th of UPC-E.
      return '${data.substring(1,5)}${data[10]}4';
    }
    else if([0x30, 0x31, 0x32].contains(data.codeUnits[3]) && data.substring(4,8) == '0000'){
      // If the 4th code is 0, 1, or 2, and the 5th to 8th code are all 0,
      // adding the 2nd, 3rd, 9th, 10th, 11th, and 4th code of UPC-A to present the 1st to 6th of UPC-E.
      return '${data.substring(1,3)}${data.substring(8,11)}${data[3]}';
    }
    else if([0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39].contains(data.codeUnits[3]) && data.substring(4,9) == '00000'){
      //If the 4th code is 3, 4, 5, 6, 7, 8, 9, and the 5th to 9th code are all 0,
      //adding the 2nd, 3rd, 4th, 10th, 11th code of UPC-A and a digit 3 to present the 1st to 6th of UPC-E.
      return '${data.substring(1,4)}${data.substring(9,11)}3';
    }
    else {
      throw BarcodeException('Unable to convert "$data" to $name Barcode');
    }
  }

  /// Convert a short version UPC-E barcode to a full length UPC-A
  String upceToUpca(String data) {
    final exp = RegExp(r'^\d{6,8}$');
    final match = exp.firstMatch(data);

    if (match == null) {
      throw BarcodeException('Unable to convert "$data" to UPC A Barcode');
    }

    var first = '0';
    String? checksum;

    switch (data.length) {
      case 8:
        checksum = data[7];
        first = data[0];
        data = data.substring(1, 7);
        break;
      case 7:
        first = data[0];
        data = data.substring(1, 7);
        break;
    }

    if (first != '0' && first != '1') {
      throw BarcodeException('Unable to convert "$data" to UPC A Barcode');
    }

    final d1 = data[0];
    final d2 = data[1];
    final d3 = data[2];
    final d4 = data[3];
    final d5 = data[4];
    final d6 = data[5];

    String manufacturer;
    String product;

    switch (d6) {
      case '0':
      case '1':
      case '2':
        manufacturer = '$d1$d2${d6}00';
        product = '00$d3$d4$d5';
        break;
      case '3':
        manufacturer = '$d1$d2${d3}00';
        product = '000$d4$d5';
        break;
      case '4':
        manufacturer = '$d1$d2$d3${d4}0';
        product = '0000$d5';
        break;
      default:
        manufacturer = '$d1$d2$d3$d4$d5';
        product = '0000$d6';
        break;
    }

    data = first + manufacturer + product;
    return data + (checksum ?? checkSumModulo10(data));
  }

  @override
  Iterable<bool> convert(String data) sync* {
    if (data.length <= 8) {
      // Try to convert UPC-E to UPC-A
      data = upceToUpca(data);
    }

    data = checkLength(data, maxLength);
    final first = data.codeUnitAt(0);
    final last = data.codeUnitAt(11);

    try {
      data = upcaToUpce(data);
    } on BarcodeException {
      if (fallback) {
        yield* const BarcodeUpcA().convert(data);
        return;
      }
      rethrow;
    }

    // Start
    yield* add(BarcodeMaps.eanStartEnd, 3);

    final parityRow = BarcodeMaps.upce[last];
    final parity = first == 0x30 ? parityRow : parityRow! ^ 0x3f;

    var index = 0;
    for (var code in data.codeUnits) {
      final codes = BarcodeMaps.ean[code];

      if (codes == null) {
        throw BarcodeException(
            'Unable to encode "${String.fromCharCode(code)}" to $name Barcode');
      }

      yield* add(codes[(parity! >> index) & 1 == 0 ? 1 : 0], 7);
      index++;
    }

    // Stop
    yield* add(BarcodeMaps.eanEndUpcE, 6);
  }

  @override
  double marginLeft(
    bool drawText,
    double width,
    double height,
    double fontHeight,
    double textPadding,
  ) {
    if (!drawText) {
      return 0;
    }

    return fontHeight;
  }

  @override
  double marginRight(
    bool drawText,
    double width,
    double height,
    double fontHeight,
    double textPadding,
  ) {
    if (!drawText) {
      return 0;
    }

    return fontHeight;
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
    if (!drawText) {
      return super.getHeight(
        index,
        count,
        width,
        height,
        fontHeight,
        textPadding,
        drawText,
      );
    }

    final h = height - fontHeight - textPadding;

    if (index + count < 4 || index > 44) {
      return h + fontHeight / 2 + textPadding;
    }

    return h;
  }

  @override
  Iterable<BarcodeElement> makeText(
    String data,
    double width,
    double height,
    double fontHeight,
    double textPadding,
    double lineWidth,
  ) sync* {
    if (data.length <= 8) {
      // Try to convert UPC-E to UPC-A
      data = upceToUpca(data);
    }

    data = checkLength(data, maxLength);
    final first = data.substring(0, 1);
    final last = data.substring(11, 12);

    try {
      data = upcaToUpce(data);
    } on BarcodeException {
      if (fallback) {
        yield* const BarcodeUpcA().makeText(
          data,
          width,
          height,
          fontHeight,
          textPadding,
          lineWidth,
        );
        return;
      }
      rethrow;
    }

    final w = lineWidth * 7;
    final left = marginLeft(true, width, height, fontHeight, textPadding);
    final right = marginRight(true, width, height, fontHeight, textPadding);

    yield BarcodeText(
      left: 0,
      top: height - fontHeight,
      width: left - lineWidth,
      height: fontHeight,
      text: first,
      align: BarcodeTextAlign.right,
    );

    var offset = left + lineWidth * 3;

    for (var i = 0; i < data.length; i++) {
      yield BarcodeText(
        left: offset,
        top: height - fontHeight,
        width: w,
        height: fontHeight,
        text: data[i],
        align: BarcodeTextAlign.center,
      );

      offset += w;
    }

    yield BarcodeText(
      left: width - right + lineWidth,
      top: height - fontHeight,
      width: right - lineWidth,
      height: fontHeight,
      text: last,
      align: BarcodeTextAlign.left,
    );
  }

  @override
  String normalize(String data) {
    if (data.length <= 8) {
      // Try to convert UPC-E to UPC-A
      data = upceToUpca(data.padRight(6, '0'));
    }

    data = checkLength(data, maxLength);
    final first = data.substring(0, 1);
    final last = data.substring(11, 12);

    try {
      data = upcaToUpce(data);
    } on BarcodeException {
      if (fallback) {
        return data;
      }
      rethrow;
    }

    return '$first$data$last';
  }
}
