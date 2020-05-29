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

import 'package:barcode/barcode.dart';
import 'package:barcode_image/barcode_image.dart';
import 'package:image/image.dart' as img;
import 'package:test/test.dart';
import 'package:crypto/crypto.dart';

void main() {
  test('Image Barcode 1D', () {
    final image = img.Image(450, 200);
    img.fill(image, img.getColor(255, 0, 0));
    img.fillRect(image, 10, 10, 440, 190, img.getColor(255, 255, 255));
    drawBarcode(
      image,
      Barcode.itf14(),
      '2349875089245',
      width: 430,
      height: 180,
      x: 10,
      y: 10,
      font: img.arial_24,
    );

    File('../itf14.png').writeAsBytesSync(img.writePng(image));

    expect(
      sha1.convert(image.getBytes()).toString(),
      equals('6a30d1ad72cd90e262d9ca7a6b0bcef22d01cee8'),
    );
  });

  test('Image Barcode 2D', () {
    final image = img.Image(320, 320);
    img.fill(image, img.getColor(255, 0, 0));
    img.fillRect(image, 10, 10, 310, 310, img.getColor(255, 255, 255));
    drawBarcode(
      image,
      Barcode.qrCode(),
      'Hello',
      width: 300,
      height: 300,
      x: 10,
      y: 10,
    );

    File('../qrcode.png').writeAsBytesSync(img.writePng(image));

    expect(
      sha1.convert(image.getBytes()).toString(),
      equals('44ff75acb301f764cb6cfc8dea61ec9e4edb937b'),
    );
  });

  test('Image Barcode 1D auto-size', () {
    final image = img.Image(450, 200);
    drawBarcode(
      image,
      Barcode.code128(),
      'Hello',
      font: img.arial_24,
    );

    File('../code128.png').writeAsBytesSync(img.writePng(image));

    expect(
      sha1.convert(image.getBytes()).toString(),
      equals('7608224396ba51dfce991042acfbbf9e97ca5ad7'),
    );
  });
}
