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

import 'dart:convert' show utf8;
import 'dart:typed_data';

import 'package:barcode_image/barcode_image.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as im;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'barcode_conf.dart';

class Download extends StatelessWidget {
  const Download({
    Key? key,
    required this.conf,
  }) : super(key: key);

  final BarcodeConf conf;

  Widget _button(IconData icon, String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!conf.barcode.isValid(conf.normalizedData)) {
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _button(Icons.file_download, 'SVG', _exportSvg),
          _button(Icons.file_download, 'PNG', _exportPng),
          _button(Icons.file_download, 'PDF', _exportPdf),
        ],
      ),
    );
  }

  Future<void> _exportPdf() async {
    final bc = conf.barcode;
    final pdf = pw.Document(
      author: 'David PHAM-VAN',
      keywords: 'barcode, dart, ${conf.barcode.name}',
      subject: conf.barcode.name,
      title: 'Barcode demo',
    );
    const scale = 5.0;

    pdf.addPage(pw.Page(
      build: (context) => pw.Center(
        child: pw.Column(children: [
          pw.Header(text: bc.name, level: 2),
          pw.Spacer(),
          pw.BarcodeWidget(
            barcode: bc,
            data: conf.normalizedData,
            width: conf.width * PdfPageFormat.mm / scale,
            height: conf.height * PdfPageFormat.mm / scale,
            textStyle: pw.TextStyle(
              fontSize: conf.fontSize * PdfPageFormat.mm / scale,
            ),
          ),
          pw.Spacer(),
          pw.Paragraph(text: conf.desc),
          pw.Spacer(),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.RichText(
              text: pw.TextSpan(
                text: 'Pdf file built using: ',
                children: [
                  pw.TextSpan(
                    text: 'https://pub.dev/packages/pdf',
                    annotation: pw.AnnotationUrl(
                      'https://pub.dev/packages/pdf',
                    ),
                    style: const pw.TextStyle(
                      color: PdfColors.blue,
                      decoration: pw.TextDecoration.underline,
                    ),
                  )
                ],
              ),
            ),
          ),
        ]),
      ),
    ));

    final path = await getSavePath();
    if (path != null) {
      final file = XFile.fromData(
        await pdf.save(),
        name: '${bc.name}.pdf',
        mimeType: 'application/pdf',
      );
      await file.saveTo(path);
    }
  }

  Future<void> _exportPng() async {
    final bc = conf.barcode;
    final image = im.Image(conf.width.toInt() * 2, conf.height.toInt() * 2);
    im.fill(image, im.getColor(255, 255, 255));
    drawBarcode(image, bc, conf.normalizedData, font: im.arial_48);
    final data = im.encodePng(image);

    final path = await getSavePath();
    if (path != null) {
      final file = XFile.fromData(
        Uint8List.fromList(data),
        name: '${bc.name}.png',
        mimeType: 'image/png',
      );
      await file.saveTo(path);
    }
  }

  Future<void> _exportSvg() async {
    final bc = conf.barcode;

    final data = bc.toSvg(
      conf.normalizedData,
      width: conf.width,
      height: conf.height,
      fontHeight: conf.fontSize,
    );

    final path = await getSavePath();
    if (path != null) {
      final file = XFile.fromData(
        Uint8List.fromList(utf8.encode(data)),
        name: '${bc.name}.svg',
        mimeType: 'image/svg+xml',
      );
      await file.saveTo(path);
    }
  }
}
