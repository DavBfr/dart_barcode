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

import 'package:barcode/barcode.dart';
import 'package:flutter/material.dart';

import 'painter.dart';

/// Error builder callback
typedef BarcodeErrorBuilder = Widget Function(
    BuildContext context, String error);

/// Flutter widget to draw a [Barcode] on screen.
class BarcodeWidget extends StatelessWidget {
  /// Draw a barcode on screen
  const BarcodeWidget({
    Key? key,
    required String data,
    required this.barcode,
    this.color = Colors.black,
    this.backgroundColor,
    this.decoration,
    this.margin,
    this.padding,
    this.width,
    this.height,
    this.drawText = true,
    this.style,
    this.textPadding = 5,
    this.errorBuilder,
  })  : _dataBytes = null,
        _dataString = data,
        super(key: key);

  /// Draw a barcode on screen using Uint8List data
  const BarcodeWidget.fromBytes({
    Key? key,
    required Uint8List data,
    required this.barcode,
    this.color = Colors.black,
    this.backgroundColor,
    this.decoration,
    this.margin,
    this.padding,
    this.width,
    this.height,
    this.drawText = true,
    this.style,
    this.textPadding = 5,
    this.errorBuilder,
  })  : _dataBytes = data,
        _dataString = null,
        super(key: key);

  /// The barcode data to display
  final Uint8List? _dataBytes;
  final String? _dataString;
  Uint8List get data => _dataBytes ?? utf8.encoder.convert(_dataString!);

  /// Is this raw bytes
  bool get isBytes => _dataBytes != null;

  /// The type of barcode to use.
  /// use:
  ///   * Barcode.code128()
  ///   * Barcode.ean13()
  ///   * ...
  final Barcode barcode;

  /// The bars color
  /// should be black or really dark color
  final Color color;

  /// The background color.
  /// this should be white or really light color
  final Color? backgroundColor;

  /// Padding to apply
  final EdgeInsetsGeometry? padding;

  /// Margin to apply
  final EdgeInsetsGeometry? margin;

  /// Width of the barcode with padding
  final double? width;

  /// Height of the barcode with padding
  final double? height;

  /// Whether to draw the text with the barcode
  final bool drawText;

  /// Text style to use to draw the text
  final TextStyle? style;

  /// Padding to add between the text and the barcode
  final double textPadding;

  /// Decoration to apply to the barcode
  final Decoration? decoration;

  /// Displays a custom widget in case of error with the barcode.
  final BarcodeErrorBuilder? errorBuilder;

  @override
  Widget build(BuildContext context) {
    final defaultTextStyle = DefaultTextStyle.of(context);
    var effectiveTextStyle = style;
    if (style == null || style!.inherit) {
      effectiveTextStyle = defaultTextStyle.style.merge(style);
    }

    Widget child = isBytes
        ? BarcodePainter.fromBytes(
            _dataBytes,
            barcode,
            color,
            drawText,
            effectiveTextStyle,
            textPadding,
          )
        : BarcodePainter(
            _dataString,
            barcode,
            color,
            drawText,
            effectiveTextStyle,
            textPadding,
          );

    if (errorBuilder != null) {
      try {
        if (isBytes) {
          barcode.verifyBytes(_dataBytes!);
        } else {
          barcode.verify(_dataString!);
        }
      } catch (e) {
        child = errorBuilder!(context, e.toString());
      }
    }

    if (padding != null) {
      child = Padding(padding: padding!, child: child);
    }

    if (decoration != null) {
      child = DecoratedBox(
        decoration: decoration!,
        child: child,
      );
    } else if (backgroundColor != null) {
      child = DecoratedBox(
        decoration: BoxDecoration(color: backgroundColor),
        child: child,
      );
    }

    if (width != null || height != null) {
      child = SizedBox(width: width, height: height, child: child);
    }

    if (margin != null) {
      child = Padding(padding: margin!, child: child);
    }

    return child;
  }
}
