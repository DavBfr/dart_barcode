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

import 'barcode_operations.dart';
import 'code39.dart';

enum BarcodeType {
  CodeEAN13,
  CodeEAN8,
  Code39,
  Code93,
  CodeUPCA,
  CodeUPCE,
  Code128,
}

@immutable
abstract class Barcode {
  const Barcode();

  factory Barcode.fromType(BarcodeType type) {
    assert(type != null);

    switch (type) {
      case BarcodeType.Code39:
        return const BarcodeCode39();
      default:
        throw UnimplementedError('Barcode $type not supported');
    }
  }

  static Barcode code39() => const BarcodeCode39();

  Iterable<BarcodeElement> make(
    String data, {
    @required double width,
    @required double height,
    bool drawText = false,
    double fontHeight,
  }) sync* {
    assert(data != null);
    assert(width != null && width > 0);
    assert(height != null && height > 0);
    assert(!drawText || fontHeight != null);

    final List<bool> bits = convert(data).toList();

    if (bits.isEmpty) {
      return;
    }

    final double lineWidth = width / bits.length;

    bool color = bits.first;
    int count = 1;

    for (int i = 1; i < bits.length; i++) {
      if (color == bits[i]) {
        count++;
        continue;
      }

      yield BarcodeBar(
        left: (i - count) * lineWidth,
        top: 0,
        width: count * lineWidth,
        height: height - (drawText ? fontHeight : 0),
        black: color,
      );

      color = bits[i];
      count = 1;
    }

    yield BarcodeBar(
      left: (bits.length - count) * lineWidth,
      top: 0,
      width: count * lineWidth,
      height: height - (drawText ? fontHeight : 0),
      black: color,
    );

    if (drawText) {
      yield* makeText(data, width, height, fontHeight);
    }
  }

  @protected
  Iterable<BarcodeText> makeText(
    String data,
    double width,
    double height,
    double fontHeight,
  ) sync* {
    yield BarcodeText(
      left: 0,
      top: height - fontHeight,
      width: width,
      height: fontHeight,
      text: data,
    );
  }

  @protected
  Iterable<bool> add(int data, int count) sync* {
    for (int i = 0; i < count; i++) {
      yield (1 & (data >> i)) == 1;
    }
  }

  String toHex(String data) {
    String intermediate = '';
    for (bool bit in convert(data)) {
      intermediate += bit ? '1' : '0';
    }

    String result = '';
    while (intermediate.length > 8) {
      final String sub = intermediate.substring(intermediate.length - 8);
      result += int.parse(sub, radix: 2).toRadixString(16);
      intermediate = intermediate.substring(0, intermediate.length - 8);
    }
    result += int.parse(intermediate, radix: 2).toRadixString(16);

    return result;
  }

  @protected
  Iterable<bool> convert(String data);

  Iterable<int> get charSet;

  String get name;
}
