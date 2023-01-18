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
import 'package:flutter/foundation.dart';
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

    final String sampleString = 'eNplkj-IE0EUxomW_gEFJYdwHhaC4CazMzvZZG1uD2PheSJEMBeRY-btJDcm2V12JktULHIWJxY2J1hvlFhdc7axsbCxExtLa73mGsXKSYgnXIaZx_B9vPd-b5ghi9ePjZ_VP74D1mmJag3TEoh-HGOEMaKI3kVlRB3aAMn0P9H5L8qAYxfaMuiLTa1j5RWLOmGhknqzx612ainNWjJsFVLW6-gCe9xLRCEUutgWj1SRR9ySSvVEYinZCkVSdB0BlNPAISXmoDKp2JzaFAMnLiHYRdCVKStByJtzMOu5vczADEYBbHSD5xnEgRr08yXsYkKA2dxxnSZ3OUNB4Ajb-J1QqNSqVTNosuQNsK5eONsF6CVQq65CyvRC7kIGOobBEIBpxsDMlssgSSXcsa8by8w9axBUSMUlUKaYceHYNghjR3KOMgMVpXOqQdbQv4mJt2SOEpMOwqtgunR5Kugo9u67DposYl-d3Sh9YPzlo8WKhs0UTLu5SQynUeeC2LzKEDqiNRgBS5J-fpJnIWpNMz3b9RAqmKoNCER81J3smRtGepv7Pver3L_N_Xu8eovfWOGraxDFAohNQOl4Sx7SykNaUCmAGQpikE1lfkVH1Je39lH9bbb9BL59dd_v_1g8dXHn05_PGwcPn77YOf_r4PiHc7X8q73Xl37j0e7aeDF7yU-fvPbzy-74SiM5c-K7z9IVZv8FdrvqmQ';
    final Uint8List bytes = base64Url.decode(base64Url.normalize(sampleString));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Card(
          child: Column(
            children: [
              BarcodeWidget.fromBytes(
                barcode: conf.barcode,
                data: bytes,
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
                    color: Theme.of(context).colorScheme.secondary,
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
