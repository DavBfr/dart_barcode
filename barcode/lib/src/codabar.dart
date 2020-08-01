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

import 'dart:typed_data';

import 'barcode_1d.dart';
import 'barcode_exception.dart';
import 'barcode_maps.dart';
import 'barcode_operations.dart';

/// Start and Stop symbols for BCodabar
enum BarcodeCodabarStartStop {
  /// A or E
  A,

  /// B or N
  B,

  /// C or *
  C,

  /// D or T
  D,
}

/// Codabar Barcode
///
/// Codabar was designed to be accurately read even when printed on dot-matrix
/// printers for multi-part forms such as FedEx airbills and blood bank forms,
/// where variants are still in use as of 2007.
class BarcodeCodabar extends Barcode1D {
  /// Create a Codabar Barcode
  const BarcodeCodabar(
    this.start,
    this.stop,
    this.printStartStop,
    this.explicitStartStop,
  );

  /// Start symbol to use
  final BarcodeCodabarStartStop start;

  /// Stop symbol to use
  final BarcodeCodabarStartStop stop;

  /// Outputs the Start and Stop characters as text under the barcode
  final bool printStartStop;

  /// The caller must explicitly specify the Start and Stop characters
  /// as letters (ABCDETN*) in the data. In this case, start and stop
  /// settings are ignored
  final bool explicitStartStop;

  @override
  Iterable<int> get charSet =>
      BarcodeMaps.codabar.keys.where((int x) => x < 0x40);

  @override
  String get name => 'CODABAR';

  @override
  Iterable<bool> convert(String data) sync* {
    final startStop = <int>[0x41, 0x42, 0x43, 0x44];

    var _start = startStop[start.index];
    var _stop = startStop[stop.index];

    if (explicitStartStop) {
      _start = _getStartStopByte(data.codeUnitAt(0));
      _stop = _getStartStopByte(data.codeUnitAt(data.length - 1));
      data = data.substring(1, data.length - 1);
    }

    // Start
    yield* add(BarcodeMaps.codabar[_start], BarcodeMaps.codabarLen[_start]);

    // Space between chars
    yield false;

    for (var code in data.codeUnits) {
      if (code > 0x40 || code == 0x2a) {
        throw BarcodeException(
            'Unable to encode "${String.fromCharCode(code)}" to $name Barcode');
      }

      final codeValue = BarcodeMaps.codabar[code];
      if (codeValue == null) {
        throw BarcodeException(
            'Unable to encode "${String.fromCharCode(code)}" to $name Barcode');
      }
      final codeLen = BarcodeMaps.codabarLen[code];
      yield* add(codeValue, codeLen);

      // Space between chars
      yield false;
    }

    // Stop
    yield* add(BarcodeMaps.codabar[_stop], BarcodeMaps.codabarLen[_stop]);
  }

  int _getStartStopByte(int value) {
    switch (value) {
      case 0x54:
        return 0x41;
      case 0x4e:
        return 0x42;
      case 0x2a:
        return 0x43;
      case 0x45:
        return 0x44;
    }
    return value;
  }

  @override
  void verifyBytes(Uint8List data) {
    if (explicitStartStop) {
      const validStartStop = [0x41, 0x42, 0x43, 0x44, 0x4e, 0x54, 0x2a, 0x45];

      if (data.length < 3) {
        throw BarcodeException(
            'Unable to encode $name Barcode: missing start and/or stop chars');
      }

      if (!validStartStop.contains(data[0])) {
        throw BarcodeException(
            'Unable to encode $name Barcode: "${String.fromCharCode(data[0])}" is an invalid start char');
      }

      if (!validStartStop.contains(data[data.length - 1])) {
        throw BarcodeException(
            'Unable to encode $name Barcode: "${String.fromCharCode(data[data.length - 1])}" is an invalid start char');
      }

      data = data.sublist(1, data.length - 1);
    }

    super.verifyBytes(data);
  }

  @override
  Iterable<BarcodeElement> makeText(
    String data,
    double width,
    double height,
    double fontHeight,
    double textPadding,
    double lineWidth,
  ) {
    if (printStartStop && !explicitStartStop) {
      data = String.fromCharCode(start.index + 0x41) +
          data +
          String.fromCharCode(stop.index + 0x41);
    } else if (!printStartStop && explicitStartStop) {
      data = data.substring(1, data.length - 1);
    }

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
