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

import 'barcode_1d.dart';
import 'barcode_exception.dart';
import 'barcode_maps.dart';

class BarcodeCode128 extends Barcode1D {
  const BarcodeCode128(this.useCode128A, this.useCode128B, this.useCode128C)
      : assert(useCode128A || useCode128B || useCode128C,
            'Enable at least one of the CODE 128 tables');

  final bool useCode128A;

  final bool useCode128B;

  final bool useCode128C;

  @override
  Iterable<int> get charSet =>
      BarcodeMaps.code128B.keys.where((int x) => x >= 0).followedBy(
          BarcodeMaps.code128A.keys.where((int x) => x >= 0 && x < 0x20));

  @override
  String get name => 'CODE 128';

  Iterable<int> shortestCode(List<int> data) {
    /// table is defined as:
    ///   0 = 000 no table set
    ///   1 = 001 table A
    ///   2 = 010 table B
    ///   4 = 100 table C
    int table = 0;

    /// the last table seen
    ///   0 = none
    ///   1 = table A
    ///   2 = table B
    ///   3 = table C
    int lastTable = 0;

    /// the number of chars for the current table
    int length = 0;
    int digitCount = 0;

    final List<int> result = <int>[];

    void addFrom(List<int> data, int start) {
      Map<int, int> t;
      if (table & 4 != 0 && digitCount & 1 == 0) {
        // New data from table C
        t = BarcodeMaps.code128C;
        if (lastTable == 1) {
          result.add(t[BarcodeMaps.code128CodeA]);
        } else if (lastTable == 2) {
          result.add(t[BarcodeMaps.code128CodeB]);
        }
        lastTable = 3;
      } else if (table & 1 != 0) {
        // New data from table A
        t = BarcodeMaps.code128A;
        if (lastTable == 2) {
          result.add(t[BarcodeMaps.code128CodeB]);
        } else if (lastTable == 3) {
          result.add(t[BarcodeMaps.code128CodeC]);
        }
        lastTable = 1;
      } else if (table & 2 != 0) {
        // New data from table B
        t = BarcodeMaps.code128B;
        if (lastTable == 1) {
          result.add(t[BarcodeMaps.code128CodeA]);
        } else if (lastTable == 3) {
          result.add(t[BarcodeMaps.code128CodeC]);
        }
        lastTable = 2;
      }

      // Add sublist(start, length + start)
      if (lastTable == 3) {
        // Encode Code 128C $digitCount
        for (int i = digitCount ~/ 2 - 1; i >= 0; i--) {
          final int digit = data[start + i * 2 + 1] -
              0x30 +
              (data[start + i * 2] - 0x30) * 10;
          result.add(t[digit]);
        }
      } else {
        for (int c in data.sublist(start, length + start).reversed) {
          result.add(t[c]);
        }
      }
    }

    for (int index = data.length - 1; index >= 0; index--) {
      final int code = data[index];

      final bool codeA = useCode128A && BarcodeMaps.code128A.containsKey(code);
      final bool codeB = useCode128B && BarcodeMaps.code128B.containsKey(code);
      final bool codeC = useCode128C && (code >= 0x30 && code <= 0x39);

      int available = 0;
      if (codeA) {
        available = 1;
      }
      if (codeB) {
        available |= 2;
      }
      if (codeC) {
        available |= 4;
      }

      if (available == 0) {
        throw BarcodeException(
            'Unable to encode "${String.fromCharCode(code)}" to $name Barcode');
      }

      if (codeC) {
        // It's a digit
        digitCount++;
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
            // First: Add $length chars using one of tables A or B
            table &= 3;
            if (table == 0) {
              throw BarcodeException(
                  'Unable to encode "${String.fromCharCodes(data)}" to $name Barcode');
            }
            addFrom(data, index + digitCount + 1);
          }
          // Then: Optimize $digitCount with table C');
          table = 4;
          addFrom(data, index + 1);
          table = 0;
          length = 0;
        }
        digitCount = 0;
      }

      if (table == 0) {
        // Add first $code to table $available
        table = available;
        length++;
      } else {
        final int newTable = table & available;
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
    }
    addFrom(data, 0);
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

  @override
  Iterable<bool> convert(String data) sync* {
    final List<int> checksum = <int>[];

    for (int codeIndex in shortestCode(data.codeUnits)) {
      final int codeValue = BarcodeMaps.code128[codeIndex];
      yield* add(codeValue, BarcodeMaps.code128Len);
      checksum.add(codeIndex);
    }

    // Checksum
    int sum = 0;
    for (int index = 0; index < checksum.length; index++) {
      final int code = checksum[index];
      final int mul = index == 0 ? 1 : index;
      sum += code * mul;
    }
    sum = sum % 103;
    yield* add(BarcodeMaps.code128[sum], BarcodeMaps.code128Len);

    // Stop
    yield* add(
        BarcodeMaps.code128[BarcodeMaps.code128Stop], BarcodeMaps.code128Len);

    // Termination Bars
    yield true;
    yield true;
  }
}
