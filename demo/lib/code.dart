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

import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'settings.dart';

class Code extends StatefulWidget {
  const Code({Key key, this.conf}) : super(key: key);

  final BarcodeConf conf;

  @override
  _CodeState createState() => _CodeState();
}

class _CodeState extends State<Code> {
  final controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    String barcode = '';

    switch (widget.conf.type) {
      case BarcodeType.CodeITF14:
        barcode = 'itf14';
        break;
      case BarcodeType.CodeEAN13:
        barcode = 'ean13';
        break;
      case BarcodeType.CodeEAN8:
        barcode = 'ean8';
        break;
      case BarcodeType.CodeEAN5:
        barcode = 'ean5';
        break;
      case BarcodeType.CodeEAN2:
        barcode = 'ean2';
        break;
      case BarcodeType.CodeISBN:
        barcode = 'isbn';
        break;
      case BarcodeType.Code39:
        barcode = 'code39';
        break;
      case BarcodeType.Code93:
        barcode = 'code93';
        break;
      case BarcodeType.CodeUPCA:
        barcode = 'upcA';
        break;
      case BarcodeType.CodeUPCE:
        barcode = 'upcE';
        break;
      case BarcodeType.Code128:
        barcode = 'code128';
        break;
      case BarcodeType.GS128:
        barcode = 'gs128';
        break;
      case BarcodeType.Telepen:
        barcode = 'telepen';
        break;
      case BarcodeType.QrCode:
        barcode = 'qrCode';
        break;
      case BarcodeType.Codabar:
        barcode = 'codabar';
        break;
      case BarcodeType.PDF417:
        barcode = 'pdf417';
        break;
      case BarcodeType.DataMatrix:
        barcode = 'dataMatrix';
        break;
      case BarcodeType.Aztec:
        barcode = 'aztec';
        break;
      case BarcodeType.Rm4scc:
        barcode = 'rm4scc';
        break;
    }

    final data = jsonEncode(widget.conf.data);

    return Container(
      margin: const EdgeInsets.all(10).copyWith(top: 30),
      child: Card(
        child: Container(
          margin: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Source code:',
                  style: Theme.of(context).textTheme.headline5),
              SizedBox(height: 5),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.grey,
                  border: Border.all(
                    color: Colors.blueGrey,
                    width: 1,
                  ),
                ),
                child: SelectableText(
                  """BarcodeWidget(
  barcode:  Barcode.$barcode(),
  data: $data,
);""",
                  style: GoogleFonts.sourceCodePro(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
