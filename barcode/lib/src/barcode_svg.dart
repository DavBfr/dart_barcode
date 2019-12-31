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

import 'dart:convert' show HtmlEscape;

import 'barcode.dart';
import 'barcode_operations.dart';

extension BarcodeSvg on Barcode {
  String _d(double d) {
    assert(d != double.infinity);
    return d.toStringAsFixed(5);
  }

  String _s(String s) {
    const HtmlEscape esc = HtmlEscape();
    return esc.convert(s);
  }

  String _c(int c) {
    return '#' + (c & 0xffffff).toRadixString(16).padLeft(6, '0');
  }

  /// Create a SVG file with this Barcode
  String toSvg(
    String data, {
    double x = 0,
    double y = 0,
    double width = 200,
    double height = 80,
    bool drawText = true,
    String fontFamily = 'monospace',
    double fontHeight,
    int color = 0x000000,
    bool fullSvg = true,
    double baseline = .75,
  }) {
    assert(data != null);
    assert(x != null);
    assert(y != null);
    assert(width != null);
    assert(height != null);
    assert(fontFamily != null);
    assert(color != null);
    assert(baseline != null);

    fontHeight ??= height * 0.2;

    final StringBuffer path = StringBuffer();
    final StringBuffer tspan = StringBuffer();

    // Draw the barcode
    for (BarcodeElement elem in make(
      data,
      width: width.toDouble(),
      height: height.toDouble(),
      drawText: drawText,
      fontHeight: fontHeight,
    )) {
      if (elem is BarcodeBar) {
        if (elem.black) {
          path.write('M ${_d(x + elem.left)} ${_d(y + elem.top)} ');
          path.write('h ${_d(elem.width)} ');
          path.write('v ${_d(elem.height)} ');
          path.write('h ${_d(-elem.width)} ');
          path.write('z ');
        }
      } else if (elem is BarcodeText) {
        final double _y = y + elem.top + elem.height * baseline;

        double _x;
        String anchor;
        switch (elem.align) {
          case BarcodeTextAlign.left:
            _x = x + elem.left;
            anchor = 'start';
            break;
          case BarcodeTextAlign.center:
            _x = x + elem.left + elem.width / 2;
            anchor = 'middle';
            break;
          case BarcodeTextAlign.right:
            _x = x + elem.left + elem.width;
            anchor = 'end';
            break;
        }

        tspan.write(
            '<tspan style="text-anchor: $anchor" x="${_d(_x)}" y="${_d(_y)}">${_s(elem.text)}</tspan>');
      }
    }

    final StringBuffer output = StringBuffer();
    if (fullSvg) {
      output.write(
          '<svg viewBox="${_d(x)} ${_d(y)} ${_d(width)} ${_d(height)}" xmlns="http://www.w3.org/2000/svg">');
    }

    output.write('<path d="$path" style="fill: ${_c(color)}"/>');
    output.write(
        '<text style="fill: ${_c(color)}; font-family: &quot;${_s(fontFamily)}&quot;; font-size: ${_d(fontHeight)}px" x="${_d(x)}" y="${_d(y)}">$tspan</text>');

    if (fullSvg) {
      output.write('</svg>');
    }

    return output.toString();
  }
}
