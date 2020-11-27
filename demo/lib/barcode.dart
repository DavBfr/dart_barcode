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

import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'barcode_conf.dart';
import 'barcode_error.dart';
import 'download.dart';

class BarcodeView extends StatelessWidget {
  const BarcodeView({
    Key? key,
    required this.conf,
  }) : super(key: key);

  final BarcodeConf conf;

  @override
  Widget build(BuildContext context) {
    try {
      conf.barcode.verify(conf.normalizedData);
    } on BarcodeException catch (error) {
      return BarcodeError(message: error.message);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Card(
          child: Column(
            children: [
              BarcodeWidget(
                barcode: conf.barcode,
                data: conf.normalizedData,
                width: conf.width,
                height: conf.height,
                style: GoogleFonts.sourceCodePro(
                  textStyle: TextStyle(
                    fontSize: conf.fontSize,
                    color: Colors.black,
                  ),
                ),
                margin: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: Theme.of(context).accentColor,
                  ),
                ),
              ),
              Download(conf: conf),
            ],
          ),
        ),
      ),
    );
  }
}
