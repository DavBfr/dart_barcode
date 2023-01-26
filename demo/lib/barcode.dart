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

    //  final String sampleString =
    //     'eNplkj-IE0EUxomW_gEFJYdwHhaC4CazMzvZZG1uD2PheSJEMBeRY-btJDcm2V12JktULHIWJxY2J1hvlFhdc7axsbCxExtLa73mGsXKSYgnXIaZx_B9vPd-b5ghi9ePjZ_VP74D1mmJag3TEoh-HGOEMaKI3kVlRB3aAMn0P9H5L8qAYxfaMuiLTa1j5RWLOmGhknqzx612ainNWjJsFVLW6-gCe9xLRCEUutgWj1SRR9ySSvVEYinZCkVSdB0BlNPAISXmoDKp2JzaFAMnLiHYRdCVKStByJtzMOu5vczADEYBbHSD5xnEgRr08yXsYkKA2dxxnSZ3OUNB4Ajb-J1QqNSqVTNosuQNsK5eONsF6CVQq65CyvRC7kIGOobBEIBpxsDMlssgSSXcsa8by8w9axBUSMUlUKaYceHYNghjR3KOMgMVpXOqQdbQv4mJt2SOEpMOwqtgunR5Kugo9u67DposYl-d3Sh9YPzlo8WKhs0UTLu5SQynUeeC2LzKEDqiNRgBS5J-fpJnIWpNMz3b9RAqmKoNCER81J3smRtGepv7Pver3L_N_Xu8eovfWOGraxDFAohNQOl4Sx7SykNaUCmAGQpikE1lfkVH1Je39lH9bbb9BL59dd_v_1g8dXHn05_PGwcPn77YOf_r4PiHc7X8q73Xl37j0e7aeDF7yU-fvPbzy-74SiM5c-K7z9IVZv8FdrvqmQ';
    //final String sampleString =
    //    'eNplks9rE0EUx11FPNiLPbVVJOCvi5vdndkfyR5KUxsPpoqQgm20yMzbSTIk2R12JkvqQYhFKngTRBA8JErtxYvgzZOeBD34Dwj-AR70IHpzEtqIZph5DN8v773PG2ZIxMbht9vr714CaTdYuYo8H1hPCGQjZBcdd81BKMCoBpyoAxH_FXlEUQAtHvVYUykhQ8tSKYklV80uNVuZKRVp8LiRz0i3rfLkTjdl-Zgpq8W2pEUTanIpuyw1JW_ELLUCl4FHvcjFPnHtAi461HM8BBQHGKPAhg7PiA8xrU_BbBivBxqmvxvB7U70YAAikv3enI-RHQSIFj3fRj6rM9_Xkke1346ZzMxqeQB1kj4H0lHzsx2AbgrVcgUyouaNkwNQAvpDAKIIAT2bMYA043DdWdGWnnu_AXYDgj0H6prc9QsFSrSd8CnKAcgkm1I1soLeFYTDnD6SjTqwsOh7ufNjQSUivBm49ng5F_dv2NnU_tL_xSzNpgtmHWMU43FURiT0qwyhzRr9XSBp2psb5Zl20XS8NScIbb3tvK5ag4iJf10_9LyJGydqh5ZKtFSmpWu0dIOWV-nlZVq5ColggB0MUol7fELLJ7QgMwA9FAjgdal_RZutL114unXm0MytyjfjyfvC6ulL21_foLu_jx5bPL73-cSjc8bDnbPoR-7U9xc_P26-uv_h8ZfawrNPTWtmce_Ir9mVBYtky8T5Ayal470';
    final String sampleString =
        'eNptUj1oFEEYJdHSTpGkUI4YrLJ3OzszO7uHQi7mRIyKJEHzg8rMt7OXJXe7y87cclp5GDDaKIhYyp2YWFlZWalglUYFmxR2EkVIYWfnXExOMA7Mx8d7fN97b5guT-cPHL0z924deL0mqzMOdUG20tSxHQchB88iQojtLUDE9R7o_AWjQDgMlqOgJZe0TlW5VNIZj1Wkl5rCWs4tpXktimvFnDfrushvNTNZjKUuLcubqiQSYUVKNWVmqagWy6zEiAQqaECwy40C9pGgiDogMMPYYTY0opy7EItwn5n5wUMdY6a9FsCNRnCvA2mg2q0hFzOQtsOYZNIloe-6HiZAqeHrsVS5NVPtQMizZ8Abenh0E6CZwUx1CnKuhwfdDugU2l0ArjkHk22gA1kewWU0aSiTe1cAe2A0XOQjH3uYUd8zdBLtc9kBleT_QXUWtUYZER5BzLE8l4BFREgtQSSxOA2l5wgPMRmadBpa1x1cLpirZM-MLPsIFU7uADpJy4uM2DuHjv3pKPX7nTu2x6JrZmZ81wuZtQlFtr1QMtGMSN4Y6NV4p-qBIDWP2oW6rLXXhQY4P10FnmWtod64hZDVW0DLxCvbdtHsXoBApv-yCPXZONF3RaUiKlVRuSQqV0X1gjg7IaYuQpJKwAiD0ulK1A8S9YP0O7fPIlA5gHkDSCEKlflvdTk3_vbTo--Hz9x_-u1N8uXcldXFx2vTW2sfJuY2R1Ze_Tj48_Sx1eNfX24X9O2Rh6-3Jx_8KrwovP_YfXJqgz3_vHXkxAbPJzj6DczbAps';
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
