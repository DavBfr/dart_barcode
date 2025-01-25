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
import 'barcode_operations.dart';

/// The bar modulation type
enum BarcodeHMBar {
  /// No ascender and descender
  tracker,

  /// Only ascender
  ascender,

  /// Only descender
  descender,

  /// Both ascender and descender
  full,
}

/// Height Modulated Barcode generation class
abstract class BarcodeHM extends Barcode1D {
  /// Create a [BarcodeHM] object
  const BarcodeHM({double tracker = 0.3}) : _tracker = tracker;

  final double _tracker;

  @override
  Iterable<BarcodeElement> makeBytes(
    Uint8List data, {
    required double width,
    required double height,
    bool drawText = false,
    double? fontHeight,
    double? textPadding,
  }) sync* {
    assert(width > 0);
    assert(height > 0);
    assert(!drawText || fontHeight != null);
    fontHeight ??= 0;
    textPadding ??= Barcode1D.defaultTextPadding;

    final text = utf8.decoder.convert(data);
    final bars = convertHM(text).toList();

    if (bars.isEmpty) {
      return;
    }

    final top = marginTop(
      drawText,
      width,
      height,
      fontHeight,
      textPadding,
    );
    final left = marginLeft(
      drawText,
      width,
      height,
      fontHeight,
      textPadding,
    );
    final right = marginRight(
      drawText,
      width,
      height,
      fontHeight,
      textPadding,
    );
    final lineWidth = (width - left - right) / (bars.length * 2 - 1);
    var index = 0;

    final barHeight = height - (drawText ? fontHeight + textPadding : 0) - top;
    final tracker = barHeight * _tracker;

    for (final bar in bars) {
      switch (bar) {
        case BarcodeHMBar.tracker:
          yield BarcodeBar(
            left: left + (index * 2) * lineWidth,
            top: top + barHeight / 2 - tracker / 2,
            width: lineWidth,
            height: tracker,
            black: true,
          );
          break;
        case BarcodeHMBar.ascender:
          yield BarcodeBar(
            left: left + (index * 2) * lineWidth,
            top: top,
            width: lineWidth,
            height: barHeight / 2 + tracker / 2,
            black: true,
          );
          break;
        case BarcodeHMBar.descender:
          yield BarcodeBar(
            left: left + (index * 2) * lineWidth,
            top: top + barHeight / 2 - tracker / 2,
            width: lineWidth,
            height: barHeight / 2 + tracker / 2,
            black: true,
          );
          break;
        case BarcodeHMBar.full:
          yield BarcodeBar(
            left: left + (index * 2) * lineWidth,
            top: top,
            width: lineWidth,
            height: barHeight,
            black: true,
          );
          break;
      }

      index++;
    }

    if (drawText) {
      yield* makeText(text, width, height, fontHeight, textPadding, lineWidth);
    }
  }

  @override
  String toHex(String data) {
    var result = '';
    var b = 0;
    var n = false;
    for (var bit in convertHM(data)) {
      b = (b << 2) + bit.index;
      if (n) {
        result += b.toRadixString(16);
        b = 0;
      }
      n = !n;
    }
    return result;
  }

  /// Convert 2 bits to a bar type
  @protected
  BarcodeHMBar fromBits(int bits) => BarcodeHMBar.values[bits];

  /// Convert bit code to a bar types
  @protected
  Iterable<BarcodeHMBar> addHW(int code, int len) sync* {
    for (var index = 0; index < len; index++) {
      yield fromBits((code >> index * 2) & 3);
    }
  }

  @override
  Iterable<bool> convert(String data) {
    throw UnimplementedError();
  }

  /// Actual barcode computation method, returns a stream of [bool]
  /// which represents the presence or absence of a bar
  @protected
  Iterable<BarcodeHMBar> convertHM(String data);
}
