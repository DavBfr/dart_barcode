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

import 'barcode.dart';
import 'barcode_exception.dart';
import 'barcode_operations.dart';

class BarcodeEan13 extends Barcode {
  const BarcodeEan13();

  @override
  Iterable<int> get charSet =>
      List<int>.generate(10, (int index) => index + 0x30);

  @override
  String get name => 'EAN 13';

  String _checkSumModulo10(String data) {
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

  @override
  Iterable<bool> convert(String data) sync* {
    if (data.length == 12) {
      data += _checkSumModulo10(data);
    } else {
      if (data.length != 13) {
        throw BarcodeException(
            'Unable to encode "$data" to $name Barcode, it is not 13 digits');
      }
      final String last = data.substring(12);
      final String checksum = _checkSumModulo10(data.substring(0, 12));
      if (last != checksum) {
        throw BarcodeException(
            'Unable to encode "$data" to $name Barcode, checksum "$last" should be "$checksum"');
      }
    }

    // Start
    yield* add(_startEnd, 3);

    int index = 0;
    final int first = _first[data.codeUnits.first];
    if (first == null) {
      throw BarcodeException(
          'Unable to encode "${String.fromCharCode(data.codeUnits.first)}" to $name Barcode');
    }

    for (int code in data.codeUnits.sublist(1)) {
      final List<int> codes = _matrix[code];

      if (codes == null) {
        throw BarcodeException(
            'Unable to encode "${String.fromCharCode(code)}" to $name Barcode');
      }

      if (index == 6) {
        yield* add(_center, 5);
      }

      if (index < 6) {
        yield* add(codes[(first >> index) & 1], 7);
      } else {
        yield* add(codes[2], 7);
      }

      index++;
    }

    // Stop
    yield* add(_startEnd, 3);
  }

  @override
  Iterable<BarcodeText> makeText(
    String data,
    double width,
    double height,
    double fontHeight,
  ) {
    if (data.length == 12) {
      data += _checkSumModulo10(data);
    }

    return super.makeText(data, width, height, fontHeight);
  }

  /// EAN 13 conversion bits
  static const Map<int, List<int>> _matrix = <int, List<int>>{
    0x30: <int>[0x58, 0x72, 0x27],
    0x31: <int>[0x4c, 0x66, 0x33],
    0x32: <int>[0x64, 0x6c, 0x1b],
    0x33: <int>[0x5e, 0x42, 0x21],
    0x34: <int>[0x62, 0x5c, 0x1d],
    0x35: <int>[0x46, 0x4e, 0x39],
    0x36: <int>[0x7a, 0x50, 0x5],
    0x37: <int>[0x6e, 0x44, 0x11],
    0x38: <int>[0x76, 0x48, 0x9],
    0x39: <int>[0x68, 0x74, 0x17],
  };

  /// EAN 13 first digit
  static const Map<int, int> _first = <int, int>{
    0x30: 0x0, // LLLLLL
    0x31: 0x34, // LLGLGG
    0x32: 0x2c, // LLGGLG
    0x33: 0x1c, // LLGGGL
    0x34: 0x32, // LGLLGG
    0x35: 0x26, // LGGLLG
    0x36: 0xe, // LGGGLL
    0x37: 0x2a, // LGLGLG
    0x38: 0x1a, // LGLGGL
    0x39: 0x16, // LGGLGL
  };

  static const int _startEnd = 0x5;
  static const int _center = 0xa;
}

class BarcodeEan8 extends BarcodeEan13 {
  const BarcodeEan8();

  @override
  String get name => 'EAN 8';

  @override
  Iterable<bool> convert(String data) sync* {
    if (data.length == 7) {
      data += _checkSumModulo10(data);
    } else {
      if (data.length != 8) {
        throw BarcodeException(
            'Unable to encode "$data" to $name Barcode, it is not 8 digits');
      }
      final String last = data.substring(7);
      final String checksum = _checkSumModulo10(data.substring(0, 7));
      if (last != checksum) {
        throw BarcodeException(
            'Unable to encode "$data" to $name Barcode, checksum "$last" should be "$checksum"');
      }
    }

    // Start
    yield* add(BarcodeEan13._startEnd, 3);

    int index = 0;
    for (int code in data.codeUnits) {
      final List<int> codes = BarcodeEan13._matrix[code];

      if (codes == null) {
        throw BarcodeException(
            'Unable to encode "${String.fromCharCode(code)}" to $name Barcode');
      }

      if (index == 4) {
        yield* add(BarcodeEan13._center, 5);
      }

      yield* add(codes[index < 4 ? 0 : 2], 7);
      index++;
    }

    // Stop
    yield* add(BarcodeEan13._startEnd, 3);
  }

  @override
  Iterable<BarcodeText> makeText(
    String data,
    double width,
    double height,
    double fontHeight,
  ) {
    if (data.length == 7) {
      data += _checkSumModulo10(data);
    }

    return super.makeText(data, width, height, fontHeight);
  }
}

class BarcodeIsbn extends BarcodeEan13 {
  const BarcodeIsbn();

  @override
  String get name => 'ISBN';

  String _checkSumModulo11(String data) {
    int sum = 0;
    int pos = 10;
    for (int c in data.codeUnits) {
      sum += (c - 0x30) * pos;
      pos--;
    }
    return String.fromCharCode(11 - (sum % 11) + 0x30);
  }
}
