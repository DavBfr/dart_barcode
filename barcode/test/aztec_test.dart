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

import 'dart:typed_data';

import 'package:barcode/barcode.dart';
import 'package:barcode/src/aztec.dart';
import 'package:barcode/src/barcode_2d.dart';
import 'package:convert/convert.dart';
import 'package:test/test.dart';

import 'golden_utils.dart';

void main() {
  test('Barcode Aztec', () {
    final bc = Barcode.aztec();
    if (bc is! Barcode2D) {
      throw Exception('bc is not a Barcode2D');
    }

    expect(bc.toSvg('0'), matchesGoldenString('aztec/0.svg'));
    expect(
      bc.toSvg(String.fromCharCodes(Iterable.generate(256))),
      matchesGoldenString('aztec/256.svg'),
    );
  });

  test('Barcode Aztec High error correction level', () {
    final bc = Barcode.aztec(minECCPercent: 80);
    if (bc is! Barcode2D) {
      throw Exception('bc is not a Barcode2D');
    }

    expect(bc.toSvg('0'), matchesGoldenString('aztec/high_error_level.svg'));
  });

  test('Barcode Aztec manual type', () {
    final bc = Barcode.aztec(userSpecifiedLayers: 5);
    if (bc is! Barcode2D) {
      throw Exception('bc is not a Barcode2D');
    }

    expect(bc.toSvg('0'), matchesGoldenString('aztec/manual.svg'));
  });

  test('Barcode Aztec limits', () {
    final bc = Barcode.aztec();
    if (bc is! Barcode2D) {
      throw Exception('bc is not a Barcode2D');
    }

    expect(bc.charSet, equals(List<int>.generate(256, (e) => e)));
    expect(bc.minLength, equals(1));
    expect(bc.maxLength, greaterThan(1024));
  });

  test('Barcode Aztec binary', () {
    final bc = Barcode.aztec();
    final data = Uint8List.fromList(hex.decode(
        '78DA55903D68144114C74D0AC14250031241314D1A717566F6E33E6CE4C8DE9D510CE636DEEE8A84993773EE72BB77EBDEBAC674E709129B58A6B0702FA88DC4CA42040BB5B0520449217E80A509885DB0727217210E3C7E6FFEF3E6F1FEAF4FD312C53472464FF66CEF11D0E09AA8D6886E00F779D3AC7B951927C465DB84A6CF1714AC61268841951CA50D45534943611A160AC306E8823042745624886094975549F42FB5085209D25CA051C4B49C33F2A067DF7902BECFE56DD0BA08269E03ABD4B4B1A9CF98DEA2839BC4C24120CA5E75B6CCAB3C2C53A715CCD62A49895B8045DDADD5EDA859BF04BCB3DD54C2FF6F62B110ED1A80A8482DB80383E6C060E8A7D4B03F66F26BF73187F904DA5AAE382163B1DD12C52BF8AA14D390E26D244388215A0384FC6E0611EF7405BE25682CF3A0253AA952333368D078156898707C0A21801B319CAB9D8794261C49218324826E1F8026142089E98854E412C60D54C0CC600CE106625ABEA0E19C86908AE573DB1F9AD1916649A8BAEE66D069A73B1671DE42F210DDB5CF3AEEB7F6B3AD3F9FDE7D7FB839997E61717E6DFEC5E1B5FD4B077F9DBEF774F984777CFDF6E8E7E95767AE33FBED743559B9FFFEEBF30F5395F1FE1C3D34B5D5B3272EBCBCF963255C0E8EAEEEBD7CD17B7DECF7810D75F2CDE6FA913D3FC7C696F675FE02E1E1C97C'));

    if (bc is! BarcodeAztec) {
      throw Exception('bc is not a BarcodeAztec');
    }

    expect(bc.isValidBytes(data), isTrue);

    // final s = bc.toSvgBytes(data);
    // File('az.svg').writeAsStringSync(s);

    // final d = File('data.bin').readAsBytesSync();

    // for (var i = 0; i < d.length; i++) {
    //   if (d[i] != data[i]) {
    //     print(i);
    //   }
    // }
  });
}
