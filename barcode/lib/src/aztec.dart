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

import '../barcode.dart';
import 'barcode_2d.dart';
import 'barcode_exception.dart';
import 'reedsolomon.dart';

/// Aztec
///
/// Named after the resemblance of the central finder pattern to an
/// Aztec pyramid.
class BarcodeAztec extends Barcode2D {
  /// Create a [BarcodeAztec] object
  const BarcodeAztec(
    this.minECCPercent,
    this.userSpecifiedLayers,
  )   : assert(minECCPercent >= 0 && minECCPercent <= 100),
        assert(userSpecifiedLayers >= 0);

  /// Default Error correction percent
  static const defaultEcPercent = 33;

  /// Default number of layers
  static const defaultLayers = 0;

  /// Error correction percent
  final int minECCPercent;

  /// Number of layers
  final int userSpecifiedLayers;

  static const _maxNbBits = 32;

  static const _maxNbBitsCompact = 4;

  static const _wordSize = <int>[
    4, 6, 6, 8, 8, 8, 8, 8, 8, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, //
    10, 10, 10, 10, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12,
  ];

  static bool _initialized = false;

  static late Map<_EncodingMode, List<int?>> _charMap;

  static void _init() {
    _charMap = <_EncodingMode, List<int?>>{};

    _charMap[_EncodingMode.mode_upper] = List<int?>.filled(256, null);
    _charMap[_EncodingMode.mode_lower] = List<int?>.filled(256, null);
    _charMap[_EncodingMode.mode_digit] = List<int?>.filled(256, null);
    _charMap[_EncodingMode.mode_mixed] = List<int?>.filled(256, null);
    _charMap[_EncodingMode.mode_punct] = List<int?>.filled(256, null);

    _charMap[_EncodingMode.mode_upper]![0x20] = 1;
    for (var c = 0x41; c <= 0x5a; c++) {
      _charMap[_EncodingMode.mode_upper]![c] = c - 0x41 + 2;
    }

    _charMap[_EncodingMode.mode_lower]![0x20] = 1;
    for (var c = 0x61; c <= 0x7a; c++) {
      _charMap[_EncodingMode.mode_lower]![c] = c - 0x61 + 2;
    }
    _charMap[_EncodingMode.mode_digit]![0x20] = 1;
    for (var c = 0x30; c <= 0x39; c++) {
      _charMap[_EncodingMode.mode_digit]![c] = c - 0x30 + 2;
    }
    _charMap[_EncodingMode.mode_digit]![0x2c] = 12;
    _charMap[_EncodingMode.mode_digit]![0x2e] = 13;

    final mixedTable = <int>[
      0, 0x20, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 27, 28, 29, 30, 31, //
      0x40, 0x5c, 0x5e, 0x5f, 0x60, 0x7c, 0x7e, 127,
    ];
    for (var i = 0; i < mixedTable.length; i++) {
      final v = mixedTable[i];
      _charMap[_EncodingMode.mode_mixed]![v] = i;
    }

    const punctTable = <int>[
      0, 0xd, 0, 0, 0, 0, 0x21, 0x27, 0x23, 0x24, 0x25, 0x26, 0x27, 0x28,
      0x29, //
      0x2a, 0x2b, 0x2c, 0x2d, 0x2e, 0x2f, 0x3a, 0x3b, 0x3c, 0x3d, 0x3e, 0x3f,
      0x5b, 0x5d, 0x7b, 0x7d,
    ];

    for (var i = 0; i < punctTable.length; i++) {
      final v = punctTable[i];
      if (v > 0) {
        _charMap[_EncodingMode.mode_punct]![v] = i;
      }
    }
  }

  @override
  Barcode2DMatrix convert(Uint8List data) {
    if (!_initialized) {
      _init();
      _initialized = true;
    }

    final m = _encode(data);

    return Barcode2DMatrix(
      m.matrixSize,
      m.matrixSize,
      1,
      m.bits,
    );
  }

  @override
  Iterable<int> get charSet => Iterable<int>.generate(256);

  @override
  String get name => 'Aztec';

  @override
  int get maxLength => 2335;

  List<int> _bitsToWords(List<bool> stuffedBits, int wordSize, int wordCount) {
    final message = List<int>.filled(wordCount, 0);

    for (var i = 0; i < wordCount; i++) {
      var value = 0;
      for (var j = 0; j < wordSize; j++) {
        if (stuffedBits[i * wordSize + j]) {
          value |= 1 << (wordSize - j - 1);
        }
      }
      message[i] = value;
    }
    return message;
  }

  List<bool> _generateCheckWords(List<bool> bits, int totalBits, int wordSize) {
    final rs = ReedSolomonEncoder(_getGF(wordSize));

    // bits is guaranteed to be a multiple of the wordSize, so no padding needed
    final messageWordCount = bits.length ~/ wordSize;
    final totalWordCount = totalBits ~/ wordSize;
    final eccWordCount = totalWordCount - messageWordCount;

    final messageWords = _bitsToWords(bits, wordSize, messageWordCount);
    final eccWords = rs.encode(messageWords, eccWordCount);
    final startPad = totalBits % wordSize;

    final messageBits = <bool>[];
    messageBits.addAll(_addBits(0, startPad));

    for (final messageWord in messageWords) {
      messageBits.addAll(_addBits(messageWord, wordSize));
    }
    for (final eccWord in eccWords) {
      messageBits.addAll(_addBits(eccWord, wordSize));
    }
    return messageBits;
  }

  GaloisField _getGF(int wordSize) {
    switch (wordSize) {
      case 4:
        return GaloisField(0x13, 16, 1);
      case 6:
        return GaloisField(0x43, 64, 1);
      case 8:
        return GaloisField(0x012D, 256, 1);
      case 10:
        return GaloisField(0x409, 1024, 1);
      case 12:
        return GaloisField(0x1069, 4096, 1);
      default:
        throw const BarcodeException('Unable to find the Galois field');
    }
  }

  List<bool> _highlevelEncode(List<int> data) {
    var states = <_State>[_State.initialState];

    for (var index = 0; index < data.length; index++) {
      var pairCode = 0;
      var nextChar = 0;
      if (index + 1 < data.length) {
        nextChar = data[index + 1];
      }

      final cur = data[index];
      if (cur == 0xd && nextChar == 0xa) {
        pairCode = 2;
      } else if (cur == 0x2e && nextChar == 0x20) {
        pairCode = 3;
      } else if (cur == 0x2c && nextChar == 0x20) {
        pairCode = 4;
      } else if (cur == 0x3a && nextChar == 0x20) {
        pairCode = 5;
      }

      if (pairCode > 0) {
        // We have one of the four special PUNCT pairs.  Treat them specially.
        // Get a new set of states for the two new characters.
        states = _updateStateListForPair(states, data, index, pairCode);
        index++;
      } else {
        // Get a new set of states for the new character.
        states = _updateStateListForChar(states, data, index);
      }
    }
    int? minBitCnt;
    _State? result;
    for (final s in states) {
      if (minBitCnt == null || s.bitCount < minBitCnt) {
        minBitCnt = s.bitCount;
        result = s;
      }
    }
    if (result != null) {
      return result.toBitList(data);
    } else {
      return <bool>[];
    }
  }

  List<_State> _simplifyStates(List<_State> states) {
    var result = <_State>[];
    for (final newState in states) {
      var add = true;
      final newResult = <_State>[];

      for (final oldState in result) {
        if (add && oldState.isBetterThanOrEqualTo(newState)) {
          add = false;
        }
        if (!(add && newState.isBetterThanOrEqualTo(oldState))) {
          newResult.add(oldState);
        }
      }

      if (add) {
        result.add(newState);
      } else {
        result = newResult;
      }
    }

    return result;
  }

// We update a set of states for a new character by updating each state
// for the new character, merging the results, and then removing the
// non-optimal states.
  List<_State> _updateStateListForChar(
      List<_State> states, List<int> data, int index) {
    final result = <_State>[];
    for (final s in states) {
      final r = _updateStateForChar(s, data, index);
      if (r.isNotEmpty) {
        result.addAll(r);
      }
    }
    return _simplifyStates(result);
  }

// Return a set of states that represent the possible ways of updating this
// state for the next character.  The resulting set of states are added to
// the "result" list.
  List<_State> _updateStateForChar(_State s, List<int> data, int index) {
    final result = <_State>[];
    final ch = data[index] & 0xff;
    final charInCurrentTable = _charMap[s.mode]![ch] != null;

    _State? stateNoBinary;
    var firstTime = true;

    for (var mode in _EncodingMode.values) {
      final charInMode = _charMap[mode]![ch];
      if (charInMode != null && charInMode > 0) {
        if (firstTime) {
          // Only create stateNoBinary the first time it's required.
          stateNoBinary ??= s.endBinaryShift(index);
          firstTime = false;
        }
        // Try generating the character by latching to its mode
        if (!charInCurrentTable ||
            mode == s.mode ||
            mode == _EncodingMode.mode_digit) {
          // If the character is in the current table, we don't want to latch to
          // any other mode except possibly digit (which uses only 4 bits).  Any
          // other latch would be equally successful *after* this character, and
          // so wouldn't save any bits.
          if (stateNoBinary != null) {
            final res = stateNoBinary.latchAndAppend(mode, charInMode);
            result.add(res);
          }
        }
        // Try generating the character by switching to its mode.
        if (!charInCurrentTable &&
            _shiftTable[s.mode] != null &&
            _shiftTable[s.mode]![mode] != null &&
            _shiftTable[s.mode]![mode]! >= 0) {
          // It never makes sense to temporarily shift to another mode if the
          // character exists in the current mode.  That can never save bits.
          if (stateNoBinary != null) {
            final res = stateNoBinary.shiftAndAppend(mode, charInMode);
            result.add(res);
          }
        }
      }
    }
    if (s.bShiftByteCount > 0 ||
        _charMap[s.mode]![ch] == null ||
        _charMap[s.mode]![ch] == 0) {
      // It's never worthwhile to go into binary shift mode if you're not already
      // in binary shift mode, and the character exists in your current mode.
      // That can never save bits over just outputting the char in the current mode.
      final res = s.addBinaryShiftChar(index);
      result.add(res);
    }
    return result;
  }

// We update a set of states for a new character by updating each state
// for the new character, merging the results, and then removing the
// non-optimal states.
  List<_State> _updateStateListForPair(
      List<_State> states, List<int> data, int index, int pairCode) {
    final result = <_State>[];
    for (final s in states) {
      final r = _updateStateForPair(s, data, index, pairCode);
      if (r.isNotEmpty) {
        result.addAll(r);
      }
    }
    return _simplifyStates(result);
  }

  List<_State> _updateStateForPair(
      _State s, List<int> data, int index, int pairCode) {
    final result = <_State>[];
    final stateNoBinary = s.endBinaryShift(index);
    // Possibility 1.  Latch to MODE_PUNCT, and then append this code
    result
        .add(stateNoBinary.latchAndAppend(_EncodingMode.mode_punct, pairCode));
    if (s.mode != _EncodingMode.mode_punct) {
      // Possibility 2.  Shift to MODE_PUNCT, and then append this code.
      // Every state except MODE_PUNCT (handled above) can shift
      result.add(
          stateNoBinary.shiftAndAppend(_EncodingMode.mode_punct, pairCode));
    }
    if (pairCode == 3 || pairCode == 4) {
      // both characters are in DIGITS.  Sometimes better to just add two digits
      final digitState = stateNoBinary
          .latchAndAppend(_EncodingMode.mode_digit, 16 - pairCode)
          . // period or comma in DIGIT
          latchAndAppend(_EncodingMode.mode_digit, 1); // space in DIGIT
      result.add(digitState);
    }
    if (s.bShiftByteCount > 0) {
      // It only makes sense to do the characters as binary if we're already
      // in binary mode.
      result.add(s.addBinaryShiftChar(index).addBinaryShiftChar(index + 1));
    }
    return result;
  }

  int _totalBitsInLayer(int layers, bool compact) {
    var tmp = 112;
    if (compact) {
      tmp = 88;
    }
    return (tmp + 16 * layers) * layers;
  }

  List<bool> _stuffBits(List<bool> bits, int wordSize) {
    final out = <bool>[];
    final n = bits.length;
    final mask = (1 << wordSize) - 2;
    for (var i = 0; i < n; i += wordSize) {
      var word = 0;
      for (var j = 0; j < wordSize; j++) {
        if (i + j >= n || bits[i + j]) {
          word |= 1 << (wordSize - 1 - j);
        }
      }
      if ((word & mask) == mask) {
        out.addAll(_addBits(word & mask, wordSize));
        i--;
      } else if ((word & mask) == 0) {
        out.addAll(_addBits(word | 1, wordSize));
        i--;
      } else {
        out.addAll(_addBits(word, wordSize));
      }
    }
    return out;
  }

  List<bool> _generateModeMessage(
      bool compact, int layers, int messageSizeInWords) {
    var modeMessage = <bool>[];
    if (compact) {
      modeMessage.addAll(_addBits(layers - 1, 2));
      modeMessage.addAll(_addBits(messageSizeInWords - 1, 6));
      modeMessage = _generateCheckWords(modeMessage, 28, 4);
    } else {
      modeMessage.addAll(_addBits(layers - 1, 5));
      modeMessage.addAll(_addBits(messageSizeInWords - 1, 11));
      modeMessage = _generateCheckWords(modeMessage, 40, 4);
    }
    return modeMessage;
  }

  void _drawModeMessage(
      _AztecCode matrix, bool compact, int matrixSize, List<bool> modeMessage) {
    final center = matrixSize ~/ 2;

    if (compact) {
      for (var i = 0; i < 7; i++) {
        final offset = center - 3 + i;
        if (modeMessage[i]) {
          matrix.set(offset, center - 5);
        }
        if (modeMessage[i + 7]) {
          matrix.set(center + 5, offset);
        }
        if (modeMessage[20 - i]) {
          matrix.set(offset, center + 5);
        }
        if (modeMessage[27 - i]) {
          matrix.set(center - 5, offset);
        }
      }
    } else {
      for (var i = 0; i < 10; i++) {
        final offset = center - 5 + i + i ~/ 5;
        if (modeMessage[i]) {
          matrix.set(offset, center - 7);
        }
        if (modeMessage[i + 10]) {
          matrix.set(center + 7, offset);
        }
        if (modeMessage[29 - i]) {
          matrix.set(offset, center + 7);
        }
        if (modeMessage[39 - i]) {
          matrix.set(center - 7, offset);
        }
      }
    }
  }

  void _drawBullsEye(_AztecCode matrix, int center, int size) {
    for (var i = 0; i < size; i += 2) {
      for (var j = center - i; j <= center + i; j++) {
        matrix.set(j, center - i);
        matrix.set(j, center + i);
        matrix.set(center - i, j);
        matrix.set(center + i, j);
      }
    }
    matrix.set(center - size, center - size);
    matrix.set(center - size + 1, center - size);
    matrix.set(center - size, center - size + 1);
    matrix.set(center + size, center - size);
    matrix.set(center + size, center - size + 1);
    matrix.set(center + size, center + size - 1);
  }

// Encode returns an aztec barcode with the given content
  _AztecCode _encode(Uint8List data) {
    final bits = _highlevelEncode(data);
    final eccBits = ((bits.length * minECCPercent) ~/ 100) + 11;
    final totalSizeBits = bits.length + eccBits;
    int layers;
    int wordSize;
    int totalBitsInLayer;
    bool compact;
    List<bool>? stuffedBits;
    if (userSpecifiedLayers != defaultLayers) {
      compact = userSpecifiedLayers < 0;
      if (compact) {
        layers = -userSpecifiedLayers;
      } else {
        layers = userSpecifiedLayers;
      }
      if ((compact && layers > _maxNbBitsCompact) ||
          (!compact && layers > _maxNbBits)) {
        throw BarcodeException('Illegal value $userSpecifiedLayers for layers');
      }
      totalBitsInLayer = _totalBitsInLayer(layers, compact);
      wordSize = _wordSize[layers];
      final usableBitsInLayers =
          totalBitsInLayer - (totalBitsInLayer % wordSize);
      stuffedBits = _stuffBits(bits, wordSize);
      if (stuffedBits.length + eccBits > usableBitsInLayers) {
        throw const BarcodeException('Data too large for user specified layer');
      }
      if (compact && stuffedBits.length > wordSize * 64) {
        throw const BarcodeException('Data too large for user specified layer');
      }
    } else {
      wordSize = 0;
      stuffedBits = null;
      // We look at the possible table sizes in the order Compact1, Compact2, Compact3,
      // Compact4, Normal4,...  Normal(i) for i < 4 isn't typically used since Compact(i+1)
      // is the same size, but has more data.
      for (var i = 0;; i++) {
        if (i > _maxNbBits) {
          throw const BarcodeException('Data too large for an aztec code');
        }
        compact = i <= 3;
        layers = i;
        if (compact) {
          layers = i + 1;
        }
        totalBitsInLayer = _totalBitsInLayer(layers, compact);
        if (totalSizeBits > totalBitsInLayer) {
          continue;
        }
        // [Re]stuff the bits if this is the first opportunity, or if the
        // wordSize has changed
        if (wordSize != _wordSize[layers]) {
          wordSize = _wordSize[layers];
          stuffedBits = _stuffBits(bits, wordSize);
        }
        final usableBitsInLayers =
            totalBitsInLayer - (totalBitsInLayer % wordSize);
        if (compact && stuffedBits!.length > wordSize * 64) {
          // Compact format only allows 64 data words, though C4 can hold more words than that
          continue;
        }
        if (stuffedBits!.length + eccBits <= usableBitsInLayers) {
          break;
        }
      }
    }
    final messageBits =
        _generateCheckWords(stuffedBits, totalBitsInLayer, wordSize);
    final messageSizeInWords = stuffedBits.length ~/ wordSize;
    final modeMessage =
        _generateModeMessage(compact, layers, messageSizeInWords);

    // allocate symbol
    int baseMatrixSize;
    if (compact) {
      baseMatrixSize = 11 + layers * 4;
    } else {
      baseMatrixSize = 14 + layers * 4;
    }
    final alignmentMap = List<int>.filled(baseMatrixSize, 0);
    int matrixSize;

    if (compact) {
      // no alignment marks in compact mode, alignmentMap is a no-op
      matrixSize = baseMatrixSize;
      for (var i = 0; i < alignmentMap.length; i++) {
        alignmentMap[i] = i;
      }
    } else {
      matrixSize = baseMatrixSize + 1 + 2 * ((baseMatrixSize / 2 - 1) ~/ 15);
      final origCenter = baseMatrixSize ~/ 2;
      final center = matrixSize ~/ 2;
      for (var i = 0; i < origCenter; i++) {
        final newOffset = i + i ~/ 15;
        alignmentMap[origCenter - i - 1] = center - newOffset - 1;
        alignmentMap[origCenter + i] = center + newOffset + 1;
      }
    }
    final code = _AztecCode(matrixSize);

    // draw data bits
    var rowOffset = 0;
    for (var i = 0; i < layers; i++) {
      var rowSize = (layers - i) * 4;
      if (compact) {
        rowSize += 9;
      } else {
        rowSize += 12;
      }

      for (var j = 0; j < rowSize; j++) {
        final columnOffset = j * 2;
        for (var k = 0; k < 2; k++) {
          if (messageBits[rowOffset + columnOffset + k]) {
            code.set(alignmentMap[i * 2 + k], alignmentMap[i * 2 + j]);
          }
          if (messageBits[rowOffset + rowSize * 2 + columnOffset + k]) {
            code.set(alignmentMap[i * 2 + j],
                alignmentMap[baseMatrixSize - 1 - i * 2 - k]);
          }
          if (messageBits[rowOffset + rowSize * 4 + columnOffset + k]) {
            code.set(alignmentMap[baseMatrixSize - 1 - i * 2 - k],
                alignmentMap[baseMatrixSize - 1 - i * 2 - j]);
          }
          if (messageBits[rowOffset + rowSize * 6 + columnOffset + k]) {
            code.set(alignmentMap[baseMatrixSize - 1 - i * 2 - j],
                alignmentMap[i * 2 + k]);
          }
        }
      }
      rowOffset += rowSize * 8;
    }

    // draw mode message
    _drawModeMessage(code, compact, matrixSize, modeMessage);

    // draw alignment marks
    if (compact) {
      _drawBullsEye(code, matrixSize ~/ 2, 5);
    } else {
      _drawBullsEye(code, matrixSize ~/ 2, 7);
      var j = 0;
      for (var i = 0; i < baseMatrixSize / 2 - 1; i += 15,) {
        for (var k = (matrixSize ~/ 2) & 1; k < matrixSize; k += 2) {
          code.set(matrixSize ~/ 2 - j, k);
          code.set(matrixSize ~/ 2 + j, k);
          code.set(k, matrixSize ~/ 2 - j);
          code.set(k, matrixSize ~/ 2 + j);
        }
        j += 16;
      }
    }
    return code;
  }
}

abstract class _Token {
  _Token(this.prev);

  final _Token? prev;

  void appendTo(List<bool> bits, List<int> text);
}

class _SimpleToken extends _Token {
  _SimpleToken(_Token? prev, this.value, this.bitCount) : super(prev);

  final int value;
  final int bitCount;

  @override
  void appendTo(List<bool> bits, List<int> text) {
    bits.addAll(_addBits(value, bitCount));
  }
}

class _BinaryShiftToken extends _Token {
  _BinaryShiftToken(_Token? prev, this.bShiftStart, this.bShiftByteCnt)
      : super(prev);

  final int bShiftStart;
  final int bShiftByteCnt;

  @override
  void appendTo(List<bool> bits, List<int> text) {
    if (bShiftByteCnt < 0) {
      bits.addAll(_addBits(bShiftStart, -bShiftByteCnt));
    } else {
      for (var i = 0; i < bShiftByteCnt; i++) {
        if (i == 0 || (i == 31 && bShiftByteCnt <= 62)) {
          // We need a header before the first character, and before
          // character 31 when the total byte code is <= 62
          bits.addAll(_addBits(31, 5)); // BINARY_SHIFT
          if (bShiftByteCnt > 62) {
            bits.addAll(_addBits(bShiftByteCnt - 31, 16));
          } else if (i == 0) {
            bits.addAll(_addBits(bShiftByteCnt < 31 ? bShiftByteCnt : 31, 5));
          } else {
            bits.addAll(_addBits(bShiftByteCnt - 31, 5));
          }
        }

        bits.addAll(_addBits(text[bShiftStart + i], 8));
      }
    }
  }
}

// Appends the last (LSB) [count] bits of [b] the the end of the list
Iterable<bool> _addBits(int b, int count) sync* {
  for (var i = count - 1; i >= 0; i--) {
    yield ((b >> i) & 1) == 1;
  }
}

enum _EncodingMode {
  mode_upper, // 5 bits
  mode_lower, // 5 bits
  mode_digit, // 4 bits
  mode_mixed, // 5 bits
  mode_punct, // 5 bits
}

// A map showing the available shift codes.  (The shifts to BINARY are not shown)
const _shiftTable = <_EncodingMode, Map<_EncodingMode, int>>{
  _EncodingMode.mode_upper: {
    _EncodingMode.mode_punct: 0,
  },
  _EncodingMode.mode_lower: {
    _EncodingMode.mode_punct: 0,
    _EncodingMode.mode_upper: 28,
  },
  _EncodingMode.mode_mixed: {
    _EncodingMode.mode_punct: 0,
  },
  _EncodingMode.mode_digit: {
    _EncodingMode.mode_punct: 0,
    _EncodingMode.mode_upper: 15,
  },
};

class _State {
  const _State({
    required this.mode,
    this.tokens,
    required this.bShiftByteCount,
    required this.bitCount,
  });

  static const initialState = _State(
    mode: _EncodingMode.mode_upper,
    tokens: null,
    bShiftByteCount: 0,
    bitCount: 0,
  );

  final _EncodingMode mode;
  final _Token? tokens;
  final int bShiftByteCount;
  final int bitCount;

// The Latch Table shows, for each pair of Modes, the optimal method for
// getting from one mode to another.  In the worst possible case, this can
// be up to 14 bits.  In the best possible case, we are already there!
// The high half-word of each entry gives the number of bits.
// The low half-word of each entry are the actual bits necessary to change
  static const latchTable = <_EncodingMode, Map<_EncodingMode, int>>{
    _EncodingMode.mode_upper: {
      _EncodingMode.mode_upper: 0,
      _EncodingMode.mode_lower: (5 << 16) + 28,
      _EncodingMode.mode_digit: (5 << 16) + 30,
      _EncodingMode.mode_mixed: (5 << 16) + 29,
      _EncodingMode.mode_punct: (10 << 16) + (29 << 5) + 30,
    },
    _EncodingMode.mode_lower: {
      _EncodingMode.mode_upper: (9 << 16) + (30 << 4) + 14,
      _EncodingMode.mode_lower: 0,
      _EncodingMode.mode_digit: (5 << 16) + 30,
      _EncodingMode.mode_mixed: (5 << 16) + 29,
      _EncodingMode.mode_punct: (10 << 16) + (29 << 5) + 30,
    },
    _EncodingMode.mode_digit: {
      _EncodingMode.mode_upper: (4 << 16) + 14,
      _EncodingMode.mode_lower: (9 << 16) + (14 << 5) + 28,
      _EncodingMode.mode_digit: 0,
      _EncodingMode.mode_mixed: (9 << 16) + (14 << 5) + 29,
      _EncodingMode.mode_punct: (14 << 16) + (14 << 10) + (29 << 5) + 30,
    },
    _EncodingMode.mode_mixed: {
      _EncodingMode.mode_upper: (5 << 16) + 29,
      _EncodingMode.mode_lower: (5 << 16) + 28,
      _EncodingMode.mode_digit: (10 << 16) + (29 << 5) + 30,
      _EncodingMode.mode_mixed: 0,
      _EncodingMode.mode_punct: (5 << 16) + 30,
    },
    _EncodingMode.mode_punct: {
      _EncodingMode.mode_upper: (5 << 16) + 31,
      _EncodingMode.mode_lower: (10 << 16) + (31 << 5) + 28,
      _EncodingMode.mode_digit: (10 << 16) + (31 << 5) + 30,
      _EncodingMode.mode_mixed: (10 << 16) + (31 << 5) + 29,
      _EncodingMode.mode_punct: 0,
    },
  };

// Create a new state representing this state with a latch to a (not
// necessary different) mode, and then a code.
  _State latchAndAppend(_EncodingMode mode, int value) {
    var bitCount = this.bitCount;
    var tokens = this.tokens;

    if (mode != this.mode) {
      final latch = latchTable[this.mode]![mode]!;
      tokens = _SimpleToken(tokens, latch & 0xFFFF, latch >> 16);
      bitCount += latch >> 16;
    }

    var latchMode = mode == _EncodingMode.mode_digit
        ? _EncodingMode.mode_digit
        : _EncodingMode.mode_punct;

    tokens = _SimpleToken(tokens, value, _bitCount(latchMode));
    return _State(
      mode: mode,
      tokens: tokens,
      bShiftByteCount: 0,
      bitCount: bitCount + _bitCount(latchMode),
    );
  }

// Create a new state representing this state, with a temporary shift
// to a different mode to output a single value.
  _State shiftAndAppend(_EncodingMode mode, int value) {
    var tokens = this.tokens;
    var thisModeBitCount = this.mode == _EncodingMode.mode_digit
        ? _EncodingMode.mode_digit
        : _EncodingMode.mode_punct;

    // Shifts exist only to UPPER and PUNCT, both with tokens size 5.
    tokens = _SimpleToken(
        tokens, _shiftTable[this.mode]![mode]!, _bitCount(thisModeBitCount));
    tokens = _SimpleToken(tokens, value, 5);

    return _State(
      mode: this.mode,
      tokens: tokens,
      bShiftByteCount: 0,
      bitCount: bitCount + _bitCount(thisModeBitCount) + 5,
    );
  }

// Create a new state representing this state, but an additional character
// output in Binary Shift mode.
  _State addBinaryShiftChar(int index) {
    var tokens = this.tokens;
    var mode = this.mode;
    var bitCnt = bitCount;
    if (this.mode == _EncodingMode.mode_punct ||
        this.mode == _EncodingMode.mode_digit) {
      final latch = latchTable[mode]![_EncodingMode.mode_upper]!;
      tokens = _SimpleToken(tokens, latch & 0xFFFF, latch >> 16);
      bitCnt += latch >> 16;
      mode = _EncodingMode.mode_upper;
    }

    var deltaBitCount = (bShiftByteCount == 0 || bShiftByteCount == 31)
        ? 18
        : (bShiftByteCount == 62)
            ? 9
            : 8;

    var result = _State(
      mode: mode,
      tokens: tokens,
      bShiftByteCount: bShiftByteCount + 1,
      bitCount: bitCnt + deltaBitCount,
    );
    if (result.bShiftByteCount == 2047 + 31) {
      // The string is as long as it's allowed to be.  We should end it.
      result = result.endBinaryShift(index + 1);
    }

    return result;
  }

// Create the state identical to this one, but we are no longer in
// Binary Shift mode.
  _State endBinaryShift(int index) {
    if (bShiftByteCount == 0) {
      return this;
    }
    final tokens = _BinaryShiftToken(
        this.tokens, index - bShiftByteCount, bShiftByteCount);
    return _State(
      mode: mode,
      tokens: tokens,
      bShiftByteCount: 0,
      bitCount: bitCount,
    );
  }

  bool isBetterThanOrEqualTo(_State other) {
    var mySize = bitCount + (latchTable[mode]![other.mode]! >> 16);

    if (other.bShiftByteCount > 0 &&
        (bShiftByteCount == 0 || bShiftByteCount > other.bShiftByteCount)) {
      mySize += 10; // Cost of entering Binary Shift mode.
    }

    return mySize <= other.bitCount;
  }

  List<bool> toBitList(List<int> text) {
    final tokens = <_Token>[];
    final se = endBinaryShift(text.length);

    for (var t = se.tokens; t != null; t = t.prev) {
      tokens.add(t);
    }
    final res = <bool>[];
    for (var i = tokens.length - 1; i >= 0; i--) {
      tokens[i].appendTo(res, text);
    }
    return res;
  }
}

int _bitCount(_EncodingMode em) {
  if (em == _EncodingMode.mode_digit) {
    return 4;
  }
  return 5;
}

class _AztecCode {
  _AztecCode(this.matrixSize)
      : bits = List<bool>.filled(matrixSize * matrixSize, false);

  final List<bool> bits;

  final int matrixSize;

  void set(int x, int y) {
    bits[y * matrixSize + x] = true;
  }
}
