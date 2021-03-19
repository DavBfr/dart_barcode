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
import 'dart:ui' as ui;

import 'package:barcode/barcode.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Barcode renderer
class BarcodePainter extends LeafRenderObjectWidget {
  /// Create a Barcode renderer
  const BarcodePainter(
    this.data,
    this.barcode,
    this.color,
    this.drawText,
    this.style,
    this.textPadding,
  ) : super();

  /// The Data to include in the barcode
  final Uint8List data;

  /// The barcode rendering object
  final Barcode barcode;

  /// The color of the barcode elements, usually black
  final Color color;

  /// Draw the text if any
  final bool drawText;

  /// Text style to use
  final TextStyle? style;

  /// Padding to add between the text and the barcode
  final double textPadding;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderBarcode(
      data,
      barcode,
      Paint()..color = color,
      drawText,
      style,
      textPadding,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant _RenderBarcode renderObject) {
    if (renderObject.data != data ||
        renderObject.barcode != barcode ||
        renderObject.barStyle.color != color ||
        renderObject.drawText != drawText ||
        renderObject.style != style ||
        renderObject.textPadding != textPadding) {
      renderObject
        ..data = data
        ..barcode = barcode
        ..barStyle = (Paint()
          ..color = color
          ..isAntiAlias = false)
        ..drawText = drawText
        ..style = style
        ..textPadding = textPadding;
      renderObject.markNeedsPaint();
    }
  }
}

class _RenderBarcode extends RenderBox {
  _RenderBarcode(
    this.data,
    this.barcode,
    this.barStyle,
    this.drawText,
    this.style,
    this.textPadding,
  );

  Uint8List data;

  Barcode barcode;

  Paint barStyle;

  bool drawText;

  TextStyle? style;

  double textPadding;

  @override
  bool get sizedByParent => true;

  Size _computeSize(BoxConstraints constraints) {
    var _size = constraints.biggest;

    if (_size.width >= double.infinity) {
      if (_size.height >= double.infinity) {
        _size = const Size(200, 100);
      } else {
        _size = Size(_size.height * 2, _size.height);
      }
    }
    if (_size.height >= double.infinity) {
      _size = Size(_size.width, _size.width / 2);
    }
    return _size;
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return _computeSize(constraints);
  }

  @override
  void performResize() {
    size = _computeSize(constraints);
  }

  void paintBar(PaintingContext context, Offset offset, BarcodeBar element) {
    if (!element.black) {
      return;
    }

    context.canvas.drawRect(
      Rect.fromLTWH(
        offset.dx + element.left,
        offset.dy + element.top,
        element.width,
        element.height,
      ),
      barStyle,
    );
  }

  void paintText(PaintingContext context, Offset offset, BarcodeText element) {
    TextAlign? align;
    switch (element.align) {
      case BarcodeTextAlign.left:
        align = TextAlign.left;
        break;
      case BarcodeTextAlign.center:
        align = TextAlign.center;
        break;
      case BarcodeTextAlign.right:
        align = TextAlign.right;
        break;
    }

    final builder = ui.ParagraphBuilder(
      style!.getParagraphStyle(
          textAlign: align,
          fontSize: element.height,
          maxLines: 1,
          ellipsis: '...'),
    )
      ..pushStyle(style!.getTextStyle())
      ..addText(element.text);

    final paragraph = builder.build();
    paragraph.layout(ui.ParagraphConstraints(width: element.width));

    context.canvas.drawParagraph(
      paragraph,
      Offset(
          offset.dx + element.left,
          offset.dy +
              element.top +
              paragraph.alphabeticBaseline -
              paragraph.height),
    );
  }

  void drawError(PaintingContext context, ui.Offset offset, String message) {
    final errorBox = RenderErrorBox(message);
    errorBox.layout(constraints);
    errorBox.paint(context, offset);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    try {
      for (var element in barcode.makeBytes(
        data,
        width: size.width,
        height: size.height,
        drawText: drawText,
        fontHeight: style!.fontSize,
        textPadding: textPadding,
      )) {
        if (element is BarcodeBar) {
          paintBar(context, offset, element);
        } else if (element is BarcodeText) {
          paintText(context, offset, element);
        }
      }
    } on BarcodeException catch (error) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        library: 'Barcode Widget',
      ));

      assert(() {
        drawError(context, offset, error.message);
        return true;
      }());
    }
  }

  @override
  bool hitTestSelf(Offset position) => true;
}
