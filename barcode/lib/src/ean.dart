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

import 'barcode_1d.dart';
import 'barcode_exception.dart';

/// Base class to generate EAN Barcodes
///
/// International Article Number (also European Article Number or EAN),
/// a standard describing a barcode symbology and numbering system
abstract class BarcodeEan extends Barcode1D {
  /// Create an EAN Barcode
  const BarcodeEan();

  @override
  Iterable<int> get charSet =>
      List<int>.generate(10, (int index) => index + 0x30);

  /// Check the EAN Barcode length and verify the checksum.
  /// if the checksum is omitted, calculate and append it to the data.
  @protected
  String checkLength(String data, int length) {
    if (data.length == length - 1) {
      data += checkSumModulo10(data);
    } else {
      if (data.length != length) {
        throw BarcodeException(
            'Unable to encode "$data" to $name Barcode, it is not $length digits');
      }

      final last = data.substring(length - 1);
      final checksum = checkSumModulo10(data.substring(0, length - 1));

      if (last != checksum) {
        throw BarcodeException(
            'Unable to encode "$data" to $name Barcode, checksum "$last" should be "$checksum"');
      }
    }

    return data;
  }

  /// Calculate the Checksum using a modulo 10
  String checkSumModulo10(String data) {
    var sum = 0;
    var fak = data.length;
    for (var c in data.codeUnits) {
      if (fak % 2 == 0) {
        sum += c - 0x30;
      } else {
        sum += (c - 0x30) * 3;
      }
      fak--;
    }
    if (sum % 10 == 0) {
      return '0';
    } else {
      return String.fromCharCode(10 - (sum % 10) + 0x30);
    }
  }

  /// Calculate the Checksum using a modulo 11
  String checkSumModulo11(String data) {
    var sum = 0;
    var pos = 10;
    for (var c in data.codeUnits) {
      sum += (c - 0x30) * pos;
      pos--;
    }
    return String.fromCharCode(11 - (sum % 11) + 0x30);
  }

  /// Returns the barcode string with the correct checksum
  String normalize(String data) => checkLength(
      data.padRight(minLength, '0').substring(0, minLength), maxLength);
}
