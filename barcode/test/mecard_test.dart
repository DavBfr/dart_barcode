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

import 'package:barcode/barcode.dart';
import 'package:test/test.dart';

void main() {
  test('MeCard WIFI', () {
    final a = MeCard.wifi(
      ssid: 'ssid',
      password: '123;45',
    );

    expect(a.toString(), r'WIFI:S:ssid;T:WPA;P:123\;45;;');
  });

  test('MeCard contact', () {
    final a = MeCard.contact(
      name: 'David PHAM-VAN',
      email: 'dev.nfet.net@gmail.com',
      address: '234 BAY Avenue',
      birthday: DateTime.fromMillisecondsSinceEpoch(1577880945000),
      memo: 'Hello',
      nickname: 'D',
      reading: 'Reading',
      tel: '9872394872',
      url: 'https://github.com/DavBfr/dart_barcode',
      videophone: '987234987234',
    );

    expect(a.toString(),
        r'MECARD:N:David PHAM-VAN;SOUND:Reading;TEL:9872394872;TEL-AV:987234987234;EMAIL:dev.nfet.net@gmail.com;NOTE:Hello;BDAY:20200101;ADR:234 BAY Avenue;URL:https\://github.com/DavBfr/dart_barcode;NICKNAME:D;;');
  });
}
