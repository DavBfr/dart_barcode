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
import 'dart:typed_data';

import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

Future<void> share({
  required Uint8List bytes,
  required String filename,
  required String mimetype,
}) async {
  final tempDir = await getTemporaryDirectory();
  final fn = filename.replaceAll(' ', '-');
  final name = '${tempDir!.path}/$fn';
  final file = File(name);
  await file.writeAsBytes(bytes);
  await OpenFile.open(name, type: mimetype, uti: filename);
}
