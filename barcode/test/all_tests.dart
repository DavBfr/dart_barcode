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

import 'code128_test.dart' as code128;
import 'code39_test.dart' as code39;
import 'code93_test.dart' as code93;
import 'generic_test.dart' as generic;
import 'telepen_test.dart' as telepen;

void main() {
  generic.main();
  code39.main();
  code93.main();
  code128.main();
  telepen.main();
}
