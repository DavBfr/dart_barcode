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

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'barcode_conf.dart';

class Code extends StatefulWidget {
  const Code({Key? key, required this.conf}) : super(key: key);

  final BarcodeConf conf;

  @override
  CodeState createState() => CodeState();
}

class CodeState extends State<Code> {
  @override
  Widget build(BuildContext context) {
    final data = jsonEncode(widget.conf.normalizedData);

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
              const SizedBox(height: 5),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  border: Border.all(
                    color: Colors.black,
                    width: 1,
                  ),
                ),
                child: SelectableText(
                  '''BarcodeWidget(
  barcode:  Barcode.${widget.conf.method},
  data: $data,
  width: ${widget.conf.width},
  height: ${widget.conf.height},
);''',
                  style: GoogleFonts.sourceCodePro(
                    color: Colors.black,
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
