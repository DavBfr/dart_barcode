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

// ignore_for_file: always_specify_types

import 'dart:io';

import 'package:args/args.dart';
import 'package:barcode_image/barcode_image.dart';
import 'package:barcode_image/src/pubspec.dart';
import 'package:image/image.dart';

int main(List<String> arguments) {
  // Parse CLI arguments
  final parser = ArgParser()
    ..addOption(
      'output',
      abbr: 'o',
      defaultsTo: 'barcode.png',
      help: 'Image file to create',
    )
    ..addOption(
      'type',
      abbr: 't',
      defaultsTo: 'Code128',
      allowed: BarcodeType.values.map(
        (BarcodeType t) => t.toString().substring(12),
      ),
      help: 'Barcode type',
    )
    ..addOption(
      'width',
      abbr: 'w',
      defaultsTo: '600',
      help: 'Barcode width',
    )
    ..addOption(
      'height',
      abbr: 'h',
      defaultsTo: '150',
      help: 'Barcode height',
    )
    ..addFlag(
      'text',
      negatable: true,
      defaultsTo: true,
      help: 'Display the data as text',
    )
    ..addFlag(
      'version',
      negatable: false,
      help: 'Print the version information',
    )
    ..addFlag(
      'help',
      negatable: false,
      help: 'Shows usage information',
    );

  try {
    final argResults = parser.parse(arguments);

    if (argResults['version']) {
      print(
          'barcode version ${Pubspec.versionFull} Copyright (c) ${Pubspec.authorsName.join(', ')}, 2020');
      return 0;
    }

    if (argResults['help'] || argResults.rest.isEmpty) {
      showHelp(parser);
      return 0;
    }

    return makeBarcode(argResults);
  } catch (error) {
    var debug = false;

    assert(() {
      debug = true;
      return true;
    }());

    if (debug) {
      rethrow;
    } else {
      print('Error: $error');
    }
    return 1;
  }
}

void showHelp(ArgParser parser) {
  print(Pubspec.description);
  print('');
  print('Usage:   barcode [options...]');
  print('');
  print('Options:');
  print(parser.usage);
}

int makeBarcode(ArgResults argResults) {
  final data = argResults.rest.join(' ');

  final type = BarcodeType.values
      .firstWhere((t) => t.toString().substring(12) == argResults['type']);

  final barcode = Barcode.fromType(type);
  final bool text = argResults['text'];

  if (argResults['output'].endsWith('.svg')) {
    // Draw the SVG barcode
    final svg = barcode.toSvg(
      data,
      width: double.parse(argResults['width']),
      height: double.parse(argResults['height']),
      drawText: text,
    );

    // Save the image to a file
    File(argResults['output']).writeAsStringSync(svg);
    return 0;
  }

  // Create an image
  final image = Image(
      width: int.parse(argResults['width']),
      height: int.parse(argResults['height']));

  // Fill it with a solid color (white)
  fill(image, color: ColorRgb8(255, 255, 255));

  drawBarcode(
    image,
    barcode,
    data,
    font: text ? arial24 : null,
  );

  // Save the image to a file
  final img = encodeNamedImage(argResults['output'], image);
  if (img != null) {
    File(argResults['output']).writeAsBytesSync(img);
  }

  return 0;
}
