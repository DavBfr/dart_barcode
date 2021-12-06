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

import 'barcode_2d.dart';
import 'barcode_exception.dart';
import 'reedsolomon.dart';

/// Data Matrix
///
/// A Data Matrix is a two-dimensional barcode consisting of black and white
/// "cells" or modules arranged in either a square or rectangular pattern, also
/// known as a matrix.
class BarcodeDataMatrix extends Barcode2D {
  /// Create a [BarcodeDataMatrix] object
  const BarcodeDataMatrix();

  @override
  Barcode2DMatrix convert(Uint8List data) {
    var text = _encodeText(data);

    _CodeSize? size;
    for (final s in _CodeSize.codeSizes) {
      if (s.dataCodewords() >= text.length) {
        size = s;
        break;
      }
    }

    if (size == null) {
      throw const BarcodeException('Too much data to encode');
    }
    text = _addPadding(text, size.dataCodewords());
    text = _ErrorCorrection.ec.calcECC(text, size);
    final code = _render(text, size);

    return Barcode2DMatrix(
      size.columns,
      size.rows,
      1,
      code,
    );
  }

  @override
  Iterable<int> get charSet => Iterable<int>.generate(256);

  @override
  String get name => 'Data Matrix';

  @override
  int get maxLength => 1559;

  List<bool> _render(List<int> data, _CodeSize size) {
    final cl = _CodeLayout(size);
    cl.setValues(data);
    return cl.merge();
  }

  List<int> _encodeText(List<int> input) {
    final result = <int>[];

    for (var i = 0; i < input.length;) {
      final c = input[i];
      i++;

      if (c >= 0x30 &&
          c <= 0x39 &&
          i < input.length &&
          input[i] >= 0x30 &&
          input[i] <= 0x39) {
        // two numbers...
        final c2 = input[i];
        i++;
        final cw = ((c - 0x30) * 10 + (c2 - 0x30)) + 130;
        result.add(cw);
      } else if (c > 127) {
        // not correct... needs to be redone later...
        result.add(235);
        result.add(c - 127);
      } else {
        result.add(c + 1);
      }
    }
    return result;
  }

  List<int> _addPadding(List<int> data, int toCount) {
    if (data.length < toCount) {
      data.add(129);
    }

    while (data.length < toCount) {
      final r = ((149 * (data.length + 1)) % 253) + 1;
      data.add((129 + r) % 254);
    }

    return data;
  }
}

class _CodeLayout {
  _CodeLayout(this.size) {
    matrix = List<bool>.filled(size.matrixColumns() * size.matrixRows(), false);
    occupy = List<bool>.filled(size.matrixColumns() * size.matrixRows(), false);
  }

  late List<bool> matrix;
  late List<bool> occupy;
  final _CodeSize size;

  bool occupied(int row, int col) {
    return occupy[col + row * size.matrixColumns()];
  }

  void setXY(int row, int col, int value, int bitNum) {
    final val = ((value >> (7 - bitNum)) & 1) == 1;

    if (row < 0) {
      row += size.matrixRows();
      col += 4 - ((size.matrixRows() + 4) % 8);
    }

    if (col < 0) {
      col += size.matrixColumns();
      row += 4 - ((size.matrixColumns() + 4) % 8);
    }

    assert(!occupied(row, col), 'Field already occupied row: $row col: $col');

    occupy[col + row * size.matrixColumns()] = true;

    matrix[col + row * size.matrixColumns()] = val;
  }

  void setSimple(int row, int col, int value) {
    setXY(row - 2, col - 2, value, 0);
    setXY(row - 2, col - 1, value, 1);
    setXY(row - 1, col - 2, value, 2);
    setXY(row - 1, col - 1, value, 3);
    setXY(row - 1, col - 0, value, 4);
    setXY(row - 0, col - 2, value, 5);
    setXY(row - 0, col - 1, value, 6);
    setXY(row - 0, col - 0, value, 7);
  }

  void corner1(int value) {
    setXY(size.matrixRows() - 1, 0, value, 0);
    setXY(size.matrixRows() - 1, 1, value, 1);
    setXY(size.matrixRows() - 1, 2, value, 2);
    setXY(0, size.matrixColumns() - 2, value, 3);
    setXY(0, size.matrixColumns() - 1, value, 4);
    setXY(1, size.matrixColumns() - 1, value, 5);
    setXY(2, size.matrixColumns() - 1, value, 6);
    setXY(3, size.matrixColumns() - 1, value, 7);
  }

  void corner2(int value) {
    setXY(size.matrixRows() - 3, 0, value, 0);
    setXY(size.matrixRows() - 2, 0, value, 1);
    setXY(size.matrixRows() - 1, 0, value, 2);
    setXY(0, size.matrixColumns() - 4, value, 3);
    setXY(0, size.matrixColumns() - 3, value, 4);
    setXY(0, size.matrixColumns() - 2, value, 5);
    setXY(0, size.matrixColumns() - 1, value, 6);
    setXY(1, size.matrixColumns() - 1, value, 7);
  }

  void corner3(int value) {
    setXY(size.matrixRows() - 3, 0, value, 0);
    setXY(size.matrixRows() - 2, 0, value, 1);
    setXY(size.matrixRows() - 1, 0, value, 2);
    setXY(0, size.matrixColumns() - 2, value, 3);
    setXY(0, size.matrixColumns() - 1, value, 4);
    setXY(1, size.matrixColumns() - 1, value, 5);
    setXY(2, size.matrixColumns() - 1, value, 6);
    setXY(3, size.matrixColumns() - 1, value, 7);
  }

  void corner4(int value) {
    setXY(size.matrixRows() - 1, 0, value, 0);
    setXY(size.matrixRows() - 1, size.matrixColumns() - 1, value, 1);
    setXY(0, size.matrixColumns() - 3, value, 2);
    setXY(0, size.matrixColumns() - 2, value, 3);
    setXY(0, size.matrixColumns() - 1, value, 4);
    setXY(1, size.matrixColumns() - 3, value, 5);
    setXY(1, size.matrixColumns() - 2, value, 6);
    setXY(1, size.matrixColumns() - 1, value, 7);
  }

  void setValues(List<int> data) {
    var idx = 0;
    var row = 4;
    var col = 0;

    while ((row < size.matrixRows()) || (col < size.matrixColumns())) {
      if ((row == size.matrixRows()) && (col == 0)) {
        corner1(data[idx]);
        idx++;
      }
      if ((row == size.matrixRows() - 2) &&
          (col == 0) &&
          (size.matrixColumns() % 4 != 0)) {
        corner2(data[idx]);
        idx++;
      }
      if ((row == size.matrixRows() - 2) &&
          (col == 0) &&
          (size.matrixColumns() % 8 == 4)) {
        corner3(data[idx]);
        idx++;
      }

      if ((row == size.matrixRows() + 4) &&
          (col == 2) &&
          (size.matrixColumns() % 8 == 0)) {
        corner4(data[idx]);
        idx++;
      }

      while (true) {
        if ((row < size.matrixRows()) && (col >= 0) && !occupied(row, col)) {
          setSimple(row, col, data[idx]);
          idx++;
        }
        row -= 2;
        col += 2;
        if ((row < 0) || (col >= size.matrixColumns())) {
          break;
        }
      }
      row += 1;
      col += 3;

      while (true) {
        if ((row >= 0) && (col < size.matrixColumns()) && !occupied(row, col)) {
          setSimple(row, col, data[idx]);
          idx++;
        }
        row += 2;
        col -= 2;
        if ((row >= size.matrixRows()) || (col < 0)) {
          break;
        }
      }
      row += 3;
      col += 1;
    }

    if (!occupied(size.matrixRows() - 1, size.matrixColumns() - 1)) {
      setXY(size.matrixRows() - 1, size.matrixColumns() - 1, 255, 0);
      setXY(size.matrixRows() - 2, size.matrixColumns() - 2, 255, 0);
    }
  }

  List<bool> merge() {
    final result = List<bool>.filled(size.rows * size.columns, false);

    void setXY(int x, int y, bool v) {
      result[x + y * size.columns] = v;
    }

    //dotted horizontal lines
    for (var r = 0; r < size.rows; r += size.regionRows() + 2) {
      for (var c = 0; c < size.columns; c += 2) {
        setXY(c, r, true);
      }
    }

    //solid horizontal line
    for (var r = size.regionRows() + 1;
        r < size.rows;
        r += size.regionRows() + 2) {
      for (var c = 0; c < size.columns; c++) {
        setXY(c, r, true);
      }
    }

    //dotted vertical lines
    for (var c = size.regionColumns() + 1;
        c < size.columns;
        c += size.regionColumns() + 2) {
      for (var r = 1; r < size.rows; r += 2) {
        setXY(c, r, true);
      }
    }

    //solid vertical line
    for (var c = 0; c < size.columns; c += size.regionColumns() + 2) {
      for (var r = 0; r < size.rows; r++) {
        setXY(c, r, true);
      }
    }

    for (var hRegion = 0; hRegion < size.regionCountHorizontal; hRegion++) {
      for (var vRegion = 0; vRegion < size.regionCountVertical; vRegion++) {
        for (var x = 0; x < size.regionColumns(); x++) {
          final colMatrix = (size.regionColumns() * hRegion) + x;
          final colResult = ((2 + size.regionColumns()) * hRegion) + x + 1;

          for (var y = 0; y < size.regionRows(); y++) {
            final rowMatrix = (size.regionRows() * vRegion) + y;
            final rowResult = ((2 + size.regionRows()) * vRegion) + y + 1;
            final val = matrix[colMatrix + rowMatrix * size.matrixColumns()];

            setXY(colResult, rowResult, val);
          }
        }
      }
    }

    return result;
  }
}

class _CodeSize {
  const _CodeSize(this.rows, this.columns, this.regionCountHorizontal,
      this.regionCountVertical, this.eccCount, this.blockCount);

  final int rows;
  final int columns;
  final int regionCountHorizontal;
  final int regionCountVertical;
  final int eccCount;
  final int blockCount;

  int regionRows() {
    return (rows - (regionCountHorizontal * 2)) ~/ regionCountHorizontal;
  }

  int regionColumns() {
    return (columns - (regionCountVertical * 2)) ~/ regionCountVertical;
  }

  int matrixRows() {
    return regionRows() * regionCountHorizontal;
  }

  int matrixColumns() {
    return regionColumns() * regionCountVertical;
  }

  int dataCodewords() {
    return ((matrixColumns() * matrixRows()) ~/ 8) - eccCount;
  }

  int dataCodewordsForBlock(int idx) {
    if (rows == 144 && columns == 144) {
      // Special Case...
      if (idx < 8) {
        return 156;
      } else {
        return 155;
      }
    }
    return dataCodewords() ~/ blockCount;
  }

  int errorCorrectionCodewordsPerBlock() {
    return eccCount ~/ blockCount;
  }

  static const codeSizes = <_CodeSize>[
    _CodeSize(10, 10, 1, 1, 5, 1),
    _CodeSize(12, 12, 1, 1, 7, 1),
    _CodeSize(14, 14, 1, 1, 10, 1),
    _CodeSize(16, 16, 1, 1, 12, 1),
    _CodeSize(18, 18, 1, 1, 14, 1),
    _CodeSize(20, 20, 1, 1, 18, 1),
    _CodeSize(22, 22, 1, 1, 20, 1),
    _CodeSize(24, 24, 1, 1, 24, 1),
    _CodeSize(26, 26, 1, 1, 28, 1),
    _CodeSize(32, 32, 2, 2, 36, 1),
    _CodeSize(36, 36, 2, 2, 42, 1),
    _CodeSize(40, 40, 2, 2, 48, 1),
    _CodeSize(44, 44, 2, 2, 56, 1),
    _CodeSize(48, 48, 2, 2, 68, 1),
    _CodeSize(52, 52, 2, 2, 84, 2),
    _CodeSize(64, 64, 4, 4, 112, 2),
    _CodeSize(72, 72, 4, 4, 144, 4),
    _CodeSize(80, 80, 4, 4, 192, 4),
    _CodeSize(88, 88, 4, 4, 224, 4),
    _CodeSize(96, 96, 4, 4, 272, 4),
    _CodeSize(104, 104, 4, 4, 336, 6),
    _CodeSize(120, 120, 6, 6, 408, 6),
    _CodeSize(132, 132, 6, 6, 496, 8),
    _CodeSize(144, 144, 6, 6, 620, 10),
  ];
}

class _ErrorCorrection {
  _ErrorCorrection() {
    final gf = GaloisField(301, 256, 1);
    rs = ReedSolomonEncoder(gf);
  }

  late ReedSolomonEncoder rs;

  static final ec = _ErrorCorrection();

  List<int> calcECC(List<int> data, _CodeSize size) {
    final dataSize = data.length;

    // make some space for error correction codes
    data.addAll(List<int>.filled(size.eccCount, 0));

    for (var block = 0; block < size.blockCount; block++) {
      final dataCnt = size.dataCodewordsForBlock(block);

      final buff = List<int>.filled(dataCnt, 0);

      // copy the data for the current block to buff
      var j = 0;
      for (var i = block; i < dataSize; i += size.blockCount) {
        buff[j] = data[i];
        j++;
      }

      // calc the error correction codes
      final ecc = ec.rs.encode(buff, size.errorCorrectionCodewordsPerBlock());

      // and append them to the result
      j = 0;
      for (var i = block;
          i < size.errorCorrectionCodewordsPerBlock() * size.blockCount;
          i += size.blockCount) {
        data[dataSize + i] = ecc[j];
        j++;
      }
    }

    return data;
  }
}
