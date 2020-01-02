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

import 'barcode_1d.dart';
import 'barcode_exception.dart';

abstract class BarcodeEan extends Barcode1D {
  const BarcodeEan();

  @override
  Iterable<int> get charSet =>
      List<int>.generate(10, (int index) => index + 0x30);

  @protected
  String checkLength(String data, int length) {
    if (data.length == length - 1) {
      data += checkSumModulo10(data);
    } else {
      if (data.length != length) {
        throw BarcodeException(
            'Unable to encode "$data" to $name Barcode, it is not $length digits');
      }

      final String last = data.substring(length - 1);
      final String checksum = checkSumModulo10(data.substring(0, length - 1));

      if (last != checksum) {
        throw BarcodeException(
            'Unable to encode "$data" to $name Barcode, checksum "$last" should be "$checksum"');
      }
    }

    return data;
  }

  String checkSumModulo10(String data) {
    int sum = 0;
    int fak = data.length;
    for (int c in data.codeUnits) {
      if (fak % 2 == 0) {
        sum = sum + (c - 0x30);
      } else {
        sum = sum + ((c - 0x30) * 3);
      }
      fak = fak - 1;
    }
    if (sum % 10 == 0) {
      return '0';
    } else {
      return String.fromCharCode(10 - (sum % 10) + 0x30);
    }
  }

  String checkSumModulo11(String data) {
    int sum = 0;
    int pos = 10;
    for (int c in data.codeUnits) {
      sum += (c - 0x30) * pos;
      pos--;
    }
    return String.fromCharCode(11 - (sum % 11) + 0x30);
  }
}
