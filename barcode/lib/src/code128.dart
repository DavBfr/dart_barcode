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

import 'package:meta/meta.dart';

import 'barcode_1d.dart';
import 'barcode_exception.dart';
import 'barcode_maps.dart';
import 'barcode_operations.dart';

/// Functions available in [BarcodeCode128] used for special purposes
class BarcodeCode128Fnc {
  /// FNC1 at the beginning of a bar code indicates a GS1-128 bar code
  /// avaiable in Code128A, Code128B, and Code128C
  static const fnc1 = BarcodeMaps.code128FNC1String;

  /// Function 2 avaiable in Code128A and Code128B
  static const fnc2 = BarcodeMaps.code128FNC2String;

  /// Function 3 avaiable in Code128A and Code128B
  static const fnc3 = BarcodeMaps.code128FNC3String;

  /// Function 4 avaiable in Code128A and Code128B
  static const fnc4 = BarcodeMaps.code128FNC4String;
}

/// Code128 [Barcode]
///
/// Code 128 is a high-density linear barcode symbology defined in
/// ISO/IEC 15417:2007. It is used for alphanumeric or numeric-only barcodes.
///
/// It can encode all 128 characters of ASCII and, by use of an extension
/// symbol, the Latin-1 characters defined in ISO/IEC 8859-1.
///
/// The GS1-128 is an application standard of the GS1.
/// It uses a series of Application Identifiers to include additional data
/// such as best before dates, batch numbers, quantities, weights and many
/// other attributes needed by the user.
class BarcodeCode128 extends Barcode1D {
  /// Create a Code128 Barcode
  const BarcodeCode128(
    this.useCode128A,
    this.useCode128B,
    this.useCode128C,
    this.isGS1,
    this.escapes,
  ) : assert(useCode128A || useCode128B || useCode128C,
            'Enable at least one of the CODE 128 tables');

  /// Use Code 128 A table
  final bool useCode128A;

  /// Use Code 128 B table
  final bool useCode128B;

  /// Use Code 128 C table
  final bool useCode128C;

  /// Use {1} for fnc1, {2} for fnc2, {3} for fnc3, and {4} for fnc4
  final bool escapes;

  /// Generate a GS1-128 Barcode
  final bool isGS1;

  @override
  Iterable<int> get charSet => BarcodeMaps.code128B.keys
          .where((int x) => useCode128B && x >= 0)
          .followedBy(
              BarcodeMaps.code128A.keys.where((int x) => useCode128A && x >= 0))
          .followedBy(useCode128C
              ? List<int>.generate(10, (int index) => index + 0x30)
              : [])
          .followedBy([
        BarcodeMaps.code128FNC1,
        if (useCode128A || useCode128B) BarcodeMaps.code128FNC2,
        if (useCode128A || useCode128B) BarcodeMaps.code128FNC3,
        if (useCode128A || useCode128B) BarcodeMaps.code128FNC4,
        if (isGS1) ...[40, 41],
      ]).toSet();

  @override
  String get name => isGS1 ? 'GS1 128' : 'CODE 128';

  /// Find the shortest code using a mix of tables A B or C
  Iterable<int> shortestCode(List<int> data) {
    // table is defined as:
    //   0 = 000 no table set
    //   1 = 001 table A
    //   2 = 010 table B
    //   4 = 100 table C
    var table = 0;

    // the last table seen
    //   0 = none
    //   1 = table A
    //   2 = table B
    //   3 = table C
    var lastTable = 0;

    // the number of chars for the current table
    var length = 0;
    var digitCount = 0;
    // var fnc1Count = 0;

    final result = <int>[];

    void addFrom(List<int> data, int start) {
      Map<int, int>? t;
      if (table & 4 != 0 && digitCount & 1 == 0 /*&& digitCount > 0*/) {
        // New data from table C
        t = BarcodeMaps.code128C;
        if (lastTable == 1) {
          result.add(t[BarcodeMaps.code128CodeA]!);
        } else if (lastTable == 2) {
          result.add(t[BarcodeMaps.code128CodeB]!);
        }
        lastTable = 3;
      } else if (table & 1 != 0) {
        // New data from table A
        t = BarcodeMaps.code128A;
        if (lastTable == 2) {
          result.add(t[BarcodeMaps.code128CodeB]!);
        } else if (lastTable == 3) {
          result.add(t[BarcodeMaps.code128CodeC]!);
        }
        lastTable = 1;
      } else if (table & 2 != 0) {
        // New data from table B
        t = BarcodeMaps.code128B;
        if (lastTable == 1) {
          result.add(t[BarcodeMaps.code128CodeA]!);
        } else if (lastTable == 3) {
          result.add(t[BarcodeMaps.code128CodeC]!);
        }
        lastTable = 2;
      }

      if (t == null) {
        throw BarcodeException(
            'Unable to encode "${String.fromCharCodes(data)}" to $name Barcode');
      }

      // Add sublist(start, length + start)
      if (lastTable == 3) {
        // Encode Code 128C $digitCount
        for (var i = start + length - 1; i >= start; i--) {
          if (data[i] == BarcodeMaps.code128FNC1) {
            result.add(t[BarcodeMaps.code128FNC1]!);
          } else {
            final digit = data[i] - 0x30 + (data[i - 1] - 0x30) * 10;
            assert(t[digit] != null);
            result.add(t[digit]!);
            i--;
          }
        }
      } else {
        for (final c in data.sublist(start, start + length).reversed) {
          assert(t[c] != null);
          result.add(t[c]!);
        }
      }
    }

    for (var index = data.length - 1; index >= 0; index--) {
      final code = data[index];

      final codeA = useCode128A && BarcodeMaps.code128A.containsKey(code);
      final codeB = useCode128B && BarcodeMaps.code128B.containsKey(code);
      final isFnc1 = code == BarcodeMaps.code128FNC1;
      final codeC = useCode128C && (code >= 0x30 && code <= 0x39);

      var available = 0;
      if (codeA) {
        available = 1;
      }
      if (codeB) {
        available |= 2;
      }
      if (codeC || isFnc1) {
        available |= 4;
      }

      if (available == 0) {
        throw BarcodeException(
            'Unable to encode "${String.fromCharCode(code)}" to $name Barcode');
      }

      if (codeC) {
        // It's a digit
        digitCount++;
      } else if (isFnc1) {
        length++;
        addFrom(data, index);
        length = 0;
        digitCount = 0;
        continue;
      } else {
        if (digitCount >= 4) {
          // Use to CODE C to output 4 digits or more

          if (digitCount & 1 != 0) {
            // if Odd number, remove the first digit
            digitCount--;
          } else {
            // addFrom(data, index + 1);
          }
          if (length > digitCount) {
            length -= digitCount;
            // First: Add $length chars using one of the tables A or B
            table &= 3;
            if (table == 0) {
              throw BarcodeException(
                  'Unable to encode "${String.fromCharCodes(data)}" to $name Barcode');
            }
            addFrom(data, index + digitCount + 1);
            length = digitCount;
          }
          // Then: Optimize $digitCount with table C');
          table = 4;
          addFrom(data, index + 1);
          table = 0;
          length = 0;
        }
        digitCount = 0;
        // fnc1Count = 0;
      }

      if (table == 0) {
        // Add first $code to table $available
        table = available;
        length++;
      } else {
        final newTable = table & available;
        if (newTable == 0) {
          // Change table to any of $table
          addFrom(data, index + 1);
          length = 0;
          table = available;
        } else {
          table = newTable;
        }
        length++;
      }
    }

    if (digitCount >= 2 && digitCount & 1 != 0) {
      // Odd number of digits, add the last one
      length -= digitCount - 1;
      addFrom(data, digitCount - 1);
      digitCount--;
      table = 4;
      length = digitCount;
    }
    if (length > 0) {
      // Add remaining data
      addFrom(data, 0);
    }

    // Add the start code
    if (lastTable == 1) {
      result.add(BarcodeMaps.code128StartCodeA);
    } else if (lastTable == 2) {
      result.add(BarcodeMaps.code128StartCodeB);
    } else if (lastTable == 3) {
      result.add(BarcodeMaps.code128StartCodeC);
    }

    return result.reversed;
  }

  /// Update the string to insert FNC1
  @visibleForTesting
  String adaptData(String data, [bool text = false]) {
    if (isGS1) {
      // Add FNC1 at parenthesis boundaries
      final result = StringBuffer();
      var start = 0;
      for (final match in RegExp(r'\(.+?\)').allMatches(data)) {
        result.write(data.substring(start, match.start));
        result.write(BarcodeMaps.code128FNC1String);
        result.write(data.substring(match.start + 1, match.end - 1));
        if (text) {
          result.write(' ');
        }
        start = match.end;
      }
      result.write(data.substring(start));
      data = result.toString();
    }

    if (escapes) {
      final result = StringBuffer();
      var start = 0;
      for (final match in RegExp(r'{\d}').allMatches(data)) {
        result.write(data.substring(start, match.start));
        switch (match.group(0)) {
          case '{1}':
            result.write(BarcodeMaps.code128FNC1String);
            break;
          case '{2}':
            result.write(BarcodeMaps.code128FNC2String);
            break;
          case '{3}':
            result.write(BarcodeMaps.code128FNC3String);
            break;
          case '{4}':
            result.write(BarcodeMaps.code128FNC4String);
            break;
          default:
            result.write(match.group(0));
        }
        // result.write(data.substring(match.start + 1, match.end - 1));
        start = match.end;
      }
      result.write(data.substring(start));
      data = result.toString();
    }

    return data;
  }

  @override
  Iterable<bool> convert(String data) sync* {
    data = adaptData(data);

    final checksum = <int>[];

    for (var codeIndex in shortestCode(data.codeUnits)) {
      final codeValue = BarcodeMaps.code128[codeIndex]!;
      yield* add(codeValue, BarcodeMaps.code128Len);
      checksum.add(codeIndex);
    }

    // Checksum
    var sum = 0;
    for (var index = 0; index < checksum.length; index++) {
      final code = checksum[index];
      final mul = index == 0 ? 1 : index;
      sum += code * mul;
    }
    sum = sum % 103;
    yield* add(BarcodeMaps.code128[sum]!, BarcodeMaps.code128Len);

    // Stop
    yield* add(
        BarcodeMaps.code128[BarcodeMaps.code128Stop]!, BarcodeMaps.code128Len);

    // Termination Bars
    yield true;
    yield true;
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
    data = adaptData(data, true).replaceAll(RegExp('[^ -\u{7f}]'), ' ').trim();

    return super.makeText(
      data,
      width,
      height,
      fontHeight,
      textPadding,
      lineWidth,
    );
  }

  @override
  void verifyBytes(Uint8List data) {
    final text = Uint8List.fromList(
      adaptData(utf8.decoder.convert(data)).codeUnits,
    );
    shortestCode(text);
    super.verifyBytes(text);
  }
}
