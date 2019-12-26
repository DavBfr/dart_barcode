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

// ignore_for_file: omit_local_variable_types

import 'package:barcode/barcode.dart';
import 'package:test/test.dart';

import 'test_draw.dart';

void main() {
  test('Barcode CODE39', () {
    final Barcode bc = Barcode.code39(draw: TestDraw());
    bc.make('0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-. \$/+%', 200, 50);
  });
}
