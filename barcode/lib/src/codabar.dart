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

import 'barcode_1d.dart';
import 'barcode_exception.dart';
import 'barcode_maps.dart';

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
  const BarcodeCodabar(this.start, this.stop);

  /// Start symbol to use
  final BarcodeCodabarStartStop start;

  /// Stop symbol to use
  final BarcodeCodabarStartStop stop;

  @override
  Iterable<int> get charSet =>
      BarcodeMaps.codabar.keys.where((int x) => x < 0x40);

  @override
  String get name => 'CODABAR';

  @override
  Iterable<bool> convert(String data) sync* {
    final startStop = <int>[0x41, 0x42, 0x43, 0x44];

    // Start
    final _start = startStop[start.index];
    yield* add(BarcodeMaps.codabar[_start], BarcodeMaps.codabarLen[_start]);

    // Space between chars
    yield false;

    for (var code in data.codeUnits) {
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
    final _stop = startStop[stop.index];
    yield* add(BarcodeMaps.codabar[_stop], BarcodeMaps.codabarLen[_stop]);
  }
}
