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

import 'dart:math';
import 'dart:typed_data';

import 'barcode_2d.dart';
import 'barcode_exception.dart';
import 'pdf417_codewords.dart';

/// Error correction levels
enum Pdf417SecurityLevel {
  /// level 0
  level0,

  /// level 1
  level1,

  /// level 2
  level2,

  /// level 3
  level3,

  /// level 4
  level4,

  /// level 5
  level5,

  /// level 6
  level6,

  /// level 7
  level7,

  /// level 8
  level8
}

/// PDF417
///
/// PDF417 is a stacked linear barcode format used in a variety of applications
/// such as transport, identification cards, and inventory management.
class BarcodePDF417 extends Barcode2D {
  /// Create a [BarcodePDF417] object
  const BarcodePDF417(
      this.securityLevel, this.moduleHeight, this.preferredRatio);

  static const _minCols = 2;
  static const _maxCols = 60;
  static const _maxRows = 60;
  static const _minRows = 2;

  /// Height of the bars
  final double moduleHeight;

  /// width to height ratio
  final double preferredRatio;

  /// Error recovery level
  final Pdf417SecurityLevel securityLevel;

  @override
  Barcode2DMatrix convert(Uint8List data) {
    final dataWords = _highlevelEncode(data);

    final dim = _calcDimensions(
        dataWords.length, _errorCorrectionWordCount(securityLevel));
    if (dim.columns < _minCols ||
        dim.columns > _maxCols ||
        dim.rows < _minRows ||
        dim.rows > _maxRows) {
      throw const BarcodeException('Unable to fit data in barcode');
    }

    final codeWords =
        _encodeData(dataWords.toList(), dim.columns, securityLevel);

    final grid = <List<int>>[];
    for (var i = 0; i < codeWords.length; i += dim.columns) {
      grid.add(codeWords.sublist(i, min(i + dim.columns, codeWords.length)));
    }

    final codes = <List<int>>[];

    var rowNum = 0;
    for (final row in grid) {
      final table = rowNum % 3;
      final rowCodes = <int>[];

      rowCodes.add(start_word);
      rowCodes.add(_getCodeword(table,
          _getLeftCodeWord(rowNum, dim.rows, dim.columns, securityLevel)));

      for (final word in row) {
        rowCodes.add(_getCodeword(table, word));
      }

      rowCodes.add(_getCodeword(table,
          _getRightCodeWord(rowNum, dim.rows, dim.columns, securityLevel)));
      rowCodes.add(stop_word);

      codes.add(rowCodes);

      rowNum++;
    }

    final width = (dim.columns + 4) * 17 + 1;

    return Barcode2DMatrix(
      width,
      dim.rows,
      moduleHeight,
      _renderBarcode(codes),
    );
  }

  @override
  Iterable<int> get charSet => Iterable<int>.generate(256);

  @override
  String get name => 'PDF417';

  @override
  int get maxLength => 990;

  List<int> _encodeData(
      List<int> dataWords, int columns, Pdf417SecurityLevel securityLevel) {
    final dataCount = dataWords.length;

    final ecCount = _errorCorrectionWordCount(securityLevel);

    final padWords = _getPadding(dataCount, ecCount, columns);
    dataWords.addAll(padWords);

    final length = dataWords.length + 1;
    dataWords.insert(0, length);

    final ecWords = _computeErrorCorrection(securityLevel, dataWords);

    dataWords.addAll(ecWords);
    return dataWords;
  }

  int _getLeftCodeWord(
      int rowNum, int rows, int columns, Pdf417SecurityLevel securityLevel) {
    final tableId = rowNum % 3;

    int x;

    switch (tableId) {
      case 0:
        x = (rows - 3) ~/ 3;
        break;
      case 1:
        x = securityLevel.index * 3;
        x += (rows - 1) % 3;
        break;
      case 2:
        x = columns - 1;
        break;
    }

    return 30 * (rowNum ~/ 3) + x;
  }

  int _getRightCodeWord(
      int rowNum, int rows, int columns, Pdf417SecurityLevel securityLevel) {
    final tableId = rowNum % 3;

    int x;

    switch (tableId) {
      case 0:
        x = columns - 1;
        break;
      case 1:
        x = (rows - 1) ~/ 3;
        break;
      case 2:
        x = securityLevel.index * 3;
        x += (rows - 1) % 3;
        break;
    }

    return 30 * (rowNum ~/ 3) + x;
  }

  Iterable<int> _getPadding(int dataCount, int ecCount, int columns) sync* {
    final totalCount = dataCount + ecCount + 1;
    final mod = totalCount % columns;

    if (mod > 0) {
      final padCount = columns - mod;
      yield* Iterable<int>.generate(padCount, (_) => padding_codeword);
    }
  }

  Iterable<bool> _addBits(int b, int count) sync* {
    for (var i = count - 1; i >= 0; i--) {
      yield ((b >> i) & 1) == 1;
    }
  }

  Iterable<bool> _renderBarcode(List<List<int>> codes) sync* {
    for (final row in codes) {
      final lastIdx = row.length - 1;
      var i = 0;
      for (final col in row) {
        if (i == lastIdx) {
          yield* _addBits(col, 18);
        } else {
          yield* _addBits(col, 17);
        }
        i++;
      }
    }
  }

  int _calculateNumberOfRows(int m, int k, int c) {
    var r = ((m + 1 + k) ~/ c) + 1;
    if (c * r >= (m + 1 + k + c)) {
      r--;
    }
    return r;
  }

  _Pdf417Size _calcDimensions(int dataWords, int eccWords) {
    var ratio = 0.0;
    var cols = 0;
    var rows = 0;

    for (var c = _minCols; c <= _maxCols; c++) {
      final r = _calculateNumberOfRows(dataWords, eccWords, c);

      if (r < _minRows) {
        break;
      }

      if (r > _maxRows) {
        continue;
      }

      if (r != 0) {
        final newRatio = (17 * c + 69) / (r * moduleHeight);

        if ((newRatio - preferredRatio).abs() <
            (ratio - preferredRatio).abs()) {
          ratio = newRatio;
          cols = c;
          rows = r;
          continue;
        }

        break;
      }
    }

    if (rows == 0) {
      cols = _minCols;
      rows = _calculateNumberOfRows(dataWords, eccWords, cols);
      if (rows < _minRows) {
        rows = _minRows;
      }
    }

    return _Pdf417Size(cols, rows);
  }

  int _errorCorrectionWordCount(Pdf417SecurityLevel level) {
    return 1 << (level.index + 1);
  }

  List<int> _computeErrorCorrection(
      Pdf417SecurityLevel level, Iterable<int> data) {
    // Correction factors for the given level
    final factors = correctionFactors[level.index];

    // Number of correction code words
    final count = _errorCorrectionWordCount(level);

    // Correction code words array, prepopulated with zeros
    final ecWords = List<int>.filled(count, 0);

    for (final value in data) {
      final temp = (value + ecWords[0]) % 929;

      for (var i = count - 1; i >= 0; i--) {
        var add = 0;

        if (i > 0) {
          add = ecWords[count - i];
        }

        ecWords[count - 1 - i] = (add + 929 - (temp * factors[i]) % 929) % 929;
      }
    }

    var key = 0;
    for (final word in ecWords) {
      if (word > 0) {
        ecWords[key] = 929 - word;
      }
      key++;
    }

    return ecWords;
  }

  int _getCodeword(int tableId, int word) {
    return codewords[tableId][word];
  }

  int _determineConsecutiveDigitCount(Iterable<int> data) {
    var cnt = 0;
    for (final r in data) {
      if (r < 0x30 || r > 0x39) {
        break;
      }
      cnt++;
    }
    return cnt;
  }

  Iterable<int> _encodeNumeric(List<int> digits) sync* {
    final digitCount = digits.length;
    var chunkCount = digitCount ~/ 44;
    if (digitCount % 44 != 0) {
      chunkCount++;
    }

    for (var i = 0; i < chunkCount; i++) {
      final start = i * 44;
      var end = start + 44;
      if (end > digitCount) {
        end = digitCount;
      }
      final chunk = digits.sublist(start, end);

      var chunkNum = BigInt.parse('1' + String.fromCharCodes(chunk), radix: 10);

      final cws = <int>[];

      while (chunkNum > BigInt.zero) {
        final newChunk = chunkNum ~/ BigInt.from(900);
        final cw = chunkNum % BigInt.from(900);

        chunkNum = newChunk;
        cws.insert(0, cw.toInt());
      }

      yield* cws;
    }
  }

  bool _isText(int ch) {
    return ch == 0x9 || ch == 0xa || ch == 0xd || (ch >= 32 && ch <= 126);
  }

  int _determineConsecutiveTextCount(List<int> msg) {
    var result = 0;

    var i = 0;
    for (final ch in msg) {
      final numericCount = _determineConsecutiveDigitCount(msg.sublist(i));
      if (numericCount >= min_numeric_count ||
          (numericCount == 0 && !_isText(ch))) {
        break;
      }

      result++;
      i++;
    }
    return result;
  }

  bool _isAlphaUpper(int ch) {
    return ch == 0x20 || (ch >= 0x41 && ch <= 0x5a);
  }

  bool _isAlphaLower(int ch) {
    return ch == 0x20 || (ch >= 0x61 && ch <= 0x7a);
  }

  bool _isMixed(int ch) {
    return mixedMap.containsKey(ch);
  }

  bool _isPunctuation(int ch) {
    return punctMap.containsKey(ch);
  }

  _SubMode _encodeText(List<int> text, _SubMode submode, List<int> result) {
    var idx = 0;
    final tmp = <int>[];

    while (idx < text.length) {
      final ch = text[idx];
      switch (submode) {
        case _SubMode.subUpper:
          if (_isAlphaUpper(ch)) {
            if (ch == 0x20) {
              tmp.add(26); // space
            } else {
              tmp.add(ch - 0x41); // ch - 'A'
            }
          } else {
            if (_isAlphaLower(ch)) {
              submode = _SubMode.subLower;
              tmp.add(27); // lower latch
              continue;
            } else if (_isMixed(ch)) {
              submode = _SubMode.subMixed;
              tmp.add(28); // mixed latch
              continue;
            } else {
              tmp.add(29); // punctuation switch
              tmp.add(punctMap[ch]);
              break;
            }
          }
          break;
        case _SubMode.subLower:
          if (_isAlphaLower(ch)) {
            if (ch == 0x20) {
              tmp.add(26); //space
            } else {
              tmp.add(ch - 0x61); // ch - 'a'
            }
          } else {
            if (_isAlphaUpper(ch)) {
              tmp.add(27); // upper switch
              tmp.add(ch - 0x41); // ch - 'A'
              break;
            } else if (_isMixed(ch)) {
              submode = _SubMode.subMixed;
              tmp.add(28); //mixed latch
              continue;
            } else {
              tmp.add(29); //punctuation switch
              tmp.add(punctMap[ch]);
              break;
            }
          }
          break;
        case _SubMode.subMixed:
          if (_isMixed(ch)) {
            tmp.add(mixedMap[ch]);
          } else {
            if (_isAlphaUpper(ch)) {
              submode = _SubMode.subUpper;
              tmp.add(28); //upper latch
              continue;
            } else if (_isAlphaLower(ch)) {
              submode = _SubMode.subLower;
              tmp.add(27); //lower latch
              continue;
            } else {
              if (idx + 1 < text.length) {
                final next = text[idx + 1];
                if (_isPunctuation(next)) {
                  submode = _SubMode.subPunct;
                  tmp.add(25); //punctuation latch
                  continue;
                }
              }
              tmp.add(29); //punctuation switch
              tmp.add(punctMap[ch]);
            }
          }
          break;
        default: //subPunct
          if (_isPunctuation(ch)) {
            tmp.add(punctMap[ch]);
          } else {
            submode = _SubMode.subUpper;
            tmp.add(29); //upper latch
            continue;
          }
      }
      idx++;
    }

    var h = 0;
    var i = 0;
    for (final val in tmp) {
      if (i % 2 != 0) {
        h = (h * 30) + val;
        result.add(h);
      } else {
        h = val;
      }
      i++;
    }
    if (tmp.length % 2 != 0) {
      result.add((h * 30) + 29);
    }
    return submode;
  }

  int _determineConsecutiveBinaryCount(List<int> msg) {
    var result = 0;

    for (var i = 0; i < msg.length; i++) {
      final numericCount = _determineConsecutiveDigitCount(msg.sublist(i));
      if (numericCount >= min_numeric_count) {
        break;
      }
      final textCount = _determineConsecutiveTextCount(msg.sublist(i));
      if (textCount > 5) {
        break;
      }
      result++;
    }
    return result;
  }

  Iterable<int> _encodeBinary(List<int> data, _EncodingMode startmode) sync* {
    final count = data.length;
    if (count == 1 && startmode == _EncodingMode.encText) {
      yield shift_to_byte;
    } else if ((count % 6) == 0) {
      yield latch_to_byte;
    } else {
      yield latch_to_byte_padded;
    }

    var idx = 0;
    // Encode sixpacks
    if (count >= 6) {
      final words = List<int>(5);
      while ((count - idx) >= 6) {
        var t = 0;
        for (var i = 0; i < 6; i++) {
          t = t << 8;
          t += data[idx + i];
        }
        for (var i = 0; i < 5; i++) {
          words[4 - i] = t % 900;
          t = t ~/ 900;
        }
        yield* words;
        idx += 6;
      }
    }
    //Encode rest (remaining n<5 bytes if any)
    for (var i = idx; i < count; i++) {
      yield data[i] & 0xff;
    }
  }

  Iterable<int> _highlevelEncode(List<int> data) sync* {
    var encodingMode = _EncodingMode.encText;
    var textSubMode = _SubMode.subUpper;

    while (data.isNotEmpty) {
      final numericCount = _determineConsecutiveDigitCount(data);
      if (numericCount >= min_numeric_count || numericCount == data.length) {
        yield latch_to_numeric;
        encodingMode = _EncodingMode.encNumeric;
        textSubMode = _SubMode.subUpper;
        final numData = _encodeNumeric(data.sublist(0, numericCount));
        yield* numData;
        data = data.sublist(numericCount);
      } else {
        final textCount = _determineConsecutiveTextCount(data);
        if (textCount >= 5 || textCount == data.length) {
          if (encodingMode != _EncodingMode.encText) {
            yield latch_to_text;
            encodingMode = _EncodingMode.encText;
            textSubMode = _SubMode.subUpper;
          }
          final txtData = <int>[];
          textSubMode =
              _encodeText(data.sublist(0, textCount), textSubMode, txtData);
          yield* txtData;
          data = data.sublist(textCount);
        } else {
          var binaryCount = _determineConsecutiveBinaryCount(data);
          if (binaryCount == 0) {
            binaryCount = 1;
          }
          final bytes = data.sublist(0, binaryCount);
          if (bytes.length != 1 || encodingMode != _EncodingMode.encText) {
            encodingMode = _EncodingMode.encBinary;
            textSubMode = _SubMode.subUpper;
          }
          final byteData = _encodeBinary(bytes, encodingMode);
          yield* byteData;
          data = data.sublist(binaryCount);
        }
      }
    }
  }
}

enum _EncodingMode { encText, encNumeric, encBinary }

enum _SubMode { subUpper, subLower, subMixed, subPunct }

class _Pdf417Size {
  _Pdf417Size(this.columns, this.rows);

  final int columns;
  final int rows;
}
