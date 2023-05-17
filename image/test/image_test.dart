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

import 'dart:io';

import 'package:barcode_image/barcode_image.dart';
import 'package:image/image.dart' as img;
import 'package:test/test.dart';

void main() {
  test('Image Barcode 1D', () {
    final image = img.Image(width: 450, height: 200);
    img.fill(image, color: img.ColorRgb8(255, 0, 0));
    img.fillRect(image,
        x1: 10, y1: 10, x2: 440, y2: 190, color: img.ColorRgb8(255, 255, 255));
    drawBarcode(
      image,
      Barcode.itf14(),
      '2349875089245',
      width: 430,
      height: 180,
      x: 10,
      y: 10,
      font: img.arial24,
    );

    File('../itf14.png').writeAsBytesSync(img.encodePng(image));
  });

  test('Image Barcode 2D', () {
    final image = img.Image(width: 320, height: 320);
    img.fill(image, color: img.ColorRgb8(255, 0, 0));
    img.fillRect(image,
        x1: 10, y1: 10, x2: 310, y2: 310, color: img.ColorRgb8(255, 255, 255));
    drawBarcode(
      image,
      Barcode.qrCode(),
      'Hello',
      width: 300,
      height: 300,
      x: 10,
      y: 10,
    );

    File('../qrcode.png').writeAsBytesSync(img.encodePng(image));
  });

  test('Image Barcode 1D auto-size', () {
    final image = img.Image(width: 450, height: 200, numChannels: 4);
    img.fill(image, color: img.ColorRgba8(0, 0, 0, 0));
    drawBarcode(
      image,
      Barcode.code128(),
      'Hello',
      font: img.arial24,
    );

    File('../code128.png').writeAsBytesSync(img.encodePng(image));
  });

  test('Image Barcode EAN13', () {
    final image = img.Image(width: 300, height: 150);
    img.fill(image, color: img.ColorRgb8(255, 255, 255));

    drawBarcode(image, Barcode.ean13(), '1064992311055', font: img.arial24);

    File('../ean13.png').writeAsBytesSync(img.encodePng(image));
  });
}
