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

/// Barcode configuration
class BarcodeConf extends ChangeNotifier {
  BarcodeConf([BarcodeType initialType = BarcodeType.Code128]) {
    type = initialType;
  }

  String? _data;

  /// Data to encode
  String get data => _data ?? _defaultData;
  set data(String value) {
    _data = value;
    notifyListeners();
  }

  String get normalizedData {
    if (barcode is BarcodeEan && barcode.name != 'UPC E') {
      // ignore: avoid_as
      final ean = barcode as BarcodeEan;
      return ean.normalize(data);
    }

    return data;
  }

  String _defaultData = 'HELLO';

  late Barcode _barcode;

  late String _desc;

  late String _method;

  late BarcodeType _type;

  /// Size of the font
  double fontSize = 30;

  /// height of the barcode
  double height = 160;

  /// width of the barcode
  double width = 400;

  Barcode get barcode => _barcode;

  String get desc => _desc;

  String get method => _method;

  /// Barcode type
  BarcodeType get type => _type;

  set type(BarcodeType value) {
    _type = value;

    fontSize = 30;
    height = 160;
    width = 400;

    switch (_type) {
      case BarcodeType.Itf:
        fontSize = 25;
        _defaultData = '345874';
        _desc =
            'Interleaved 2 of 5 (ITF) is a continuous two-width barcodesymbology encoding digits. It is used commercially on 135 film, for ITF-14 barcodes, and on cartons of some products, while the products inside are labeled with UPC or EAN.';
        _method = 'itf(zeroPrepend: true)';
        _barcode = Barcode.itf(zeroPrepend: true);
        break;
      case BarcodeType.CodeITF16:
        fontSize = 25;
        height = 140;
        _defaultData = '1234567890123452';
        _desc =
            'ITF-16 is a standardized version of the Interleaved 2 of 5 barcode, also known as UPC Shipping Container Symbol. It is used to mark cartons, cases, or pallets that contain products. It containins 16 digits, the last being a check digit.';
        _method = 'itf16()';
        _barcode = Barcode.itf16();
        break;
      case BarcodeType.CodeITF14:
        fontSize = 25;
        height = 140;
        _defaultData = '9872346598257';
        _desc =
            'ITF-14 is the GS1 implementation of an Interleaved 2 of 5 (ITF) bar code to encode a Global Trade Item Number. ITF-14 symbols are generally used on packaging levels of a product, such as a case box of 24 cans of soup. The ITF-14 will always encode 14 digits.';
        _method = 'itf14()';
        _barcode = Barcode.itf14();
        break;
      case BarcodeType.CodeEAN13:
        _defaultData = '873487659295';
        _desc =
            'The International Article Number is a standard describing a barcode symbology and numbering system used in global trade to identify a specific retail product type, in a specific packaging configuration, from a specific manufacturer.';
        _method = 'ean13(drawEndChar: true)';
        _barcode = Barcode.ean13(drawEndChar: true);
        break;
      case BarcodeType.CodeEAN8:
        width = 300;
        _defaultData = '3465920';
        _desc =
            'An EAN-8 is an EAN/UPC symbology barcode and is derived from the longer International Article Number code. It was introduced for use on small packages where an EAN-13 barcode would be too large; for example on cigarettes, pencils, and chewing gum packets. It is encoded identically to the 12 digits of the UPC-A barcode, except that it has 4 digits in each of the left and right halves.';
        _method = 'ean8(drawSpacers: true)';
        _barcode = Barcode.ean8(drawSpacers: true);
        break;
      case BarcodeType.CodeEAN5:
        _defaultData = '12749';
        width = 150;
        _desc =
            'The EAN-5 is a 5-digit European Article Number code, and is a supplement to the EAN-13 barcode used on books. It is used to give a suggestion for the price of the book.';
        _method = 'ean5()';
        _barcode = Barcode.ean5();
        break;
      case BarcodeType.CodeEAN2:
        _defaultData = '42';
        width = 100;
        _desc =
            'The EAN-2 is a supplement to the EAN-13 and UPC-A barcodes. It is often used on magazines and periodicals to indicate an issue number.';
        _method = 'ean2()';
        _barcode = Barcode.ean2();
        break;
      case BarcodeType.CodeISBN:
        fontSize = 25;
        height = 140;
        _defaultData = '329873497482';
        _desc =
            'The International Standard Book Number is a numeric commercial book identifier which is intended to be unique. Publishers purchase ISBNs from an affiliate of the International ISBN Agency.';
        _method = 'isbn(drawEndChar: true)';
        _barcode = Barcode.isbn(drawEndChar: true);
        break;
      case BarcodeType.Code39:
        _defaultData = 'HELLO WORLD';
        _desc =
            'The Code 39 specification defines 43 characters, consisting of uppercase letters (A through Z), numeric digits (0 through 9) and a number of special characters (-, ., \$, /, +, %, and space). An additional character (denoted \'*\') is used for both start and stop delimiters.';
        _method = 'code39()';
        _barcode = Barcode.code39();
        break;
      case BarcodeType.Code93:
        _defaultData = 'HELLO WORLD';
        _desc =
            'Code 93 is a barcode symbology designed in 1982 by Intermec to provide a higher density and data security enhancement to Code 39. It is an alphanumeric, variable length symbology. Code 93 is used primarily by Canada Post to encode supplementary delivery information.';
        _method = 'code93()';
        _barcode = Barcode.code93();
        break;
      case BarcodeType.CodeUPCA:
        _defaultData = '37234876234';
        _desc =
            'The Universal Product Code is a barcode symbology that is widely used in the United States, Canada, Europe, Australia, New Zealand, and other countries for tracking trade items in stores. UPC consists of 12 numeric digits that are uniquely assigned to each trade item.';
        _method = 'upcA()';
        _barcode = Barcode.upcA();
        break;
      case BarcodeType.CodeUPCE:
        _defaultData = '18740000915';
        _desc =
            'The Universal Product Code is a barcode symbology that is widely used in the United States, Canada, Europe, Australia, New Zealand, and other countries for tracking trade items in stores. To allow the use of UPC barcodes on smaller packages, where a full 12-digit barcode may not fit, a zero-suppressed version of UPC was developed, called UPC-E, in which the number system digit, all trailing zeros in the manufacturer code, and all leading zeros in the product code, are suppressed';
        _method = 'upcE()';
        _barcode = Barcode.upcE();
        break;
      case BarcodeType.Code128:
        _defaultData = 'Hello World';
        _desc =
            'Code 128 is a high-density linear barcode symbology defined in ISO/IEC 15417:2007. It is used for alphanumeric or numeric-only barcodes. It can encode all 128 characters of ASCII and, by use of an extension symbol, the Latin-1 characters defined in ISO/IEC 8859-1.';
        fontSize = 25;
        _method = 'code128(escapes: true)';
        _barcode = Barcode.code128(escapes: true);
        break;
      case BarcodeType.GS128:
        _defaultData = '(420)22345(56780000000001)';
        _desc =
            'The GS1-128 is an application standard of the GS1. It uses a series of Application Identifiers to include additional data such as best before dates, batch numbers, quantities, weights and many other attributes needed by the user.';
        _method = 'gs128(useCode128A: false, useCode128B: false)';
        fontSize = 25;
        _barcode = Barcode.gs128(useCode128A: false, useCode128B: false);
        break;
      case BarcodeType.Telepen:
        _defaultData = 'Hello';
        _desc =
            'Telepen is a barcode designed in 1972 in the UK to express all 128 ASCII characters without using shift characters for code switching, and using only two different widths for bars and spaces.';
        _method = 'telepen()';
        _barcode = Barcode.telepen();
        break;
      case BarcodeType.QrCode:
        width = 300;
        height = width;
        _defaultData = 'Hello World';
        _desc =
            'QR code (abbreviated from Quick Response code) is the trademark for a type of matrix barcode (or two-dimensional barcode) first designed in 1994 for the automotive industry in Japan.';
        _method = 'qrCode()';
        _barcode = Barcode.qrCode();
        break;
      case BarcodeType.Codabar:
        _defaultData = '7698-1239';
        _desc =
            'Codabar was designed to be accurately read even when printed on dot-matrix printers for multi-part forms such as FedEx airbills and blood bank forms, where variants are still in use as of 2007.';
        _method = 'codabar()';
        _barcode = Barcode.codabar();
        break;
      case BarcodeType.PDF417:
        _defaultData = 'Hello World';
        _desc =
            'PDF417 is a stacked linear barcode format used in a variety of applications such as transport, identification cards, and inventory management.';
        _method = 'pdf417()';
        _barcode = Barcode.pdf417();
        break;
      case BarcodeType.DataMatrix:
        width = 300;
        height = width;
        _defaultData = 'Hello World';
        _desc =
            'A Data Matrix is a two-dimensional barcode consisting of black and white "cells" or modules arranged in either a square or rectangular pattern, also known as a matrix.';
        _method = 'dataMatrix()';
        _barcode = Barcode.dataMatrix();
        break;
      case BarcodeType.Aztec:
        width = 300;
        height = width;
        _defaultData = 'Hello World';
        _desc =
            'Named after the resemblance of the central finder pattern to an Aztec pyramid.';
        _method = 'aztec()';
        _barcode = Barcode.aztec();
        break;
      case BarcodeType.Rm4scc:
        height = 60;
        _defaultData = 'HELLOWORLD';
        _desc =
            'The RM4SCC is used for the Royal Mail Cleanmail service. It enables UK postcodes as well as Delivery Point Suffixes (DPSs) to be easily read by a machine at high speed.';
        _method = 'rm4scc()';
        _barcode = Barcode.rm4scc();
        break;
      case BarcodeType.Postnet:
        height = 60;
        _defaultData = '55555-1237';
        _desc =
            'POSTNET (Postal Numeric Encoding Technique) is a barcode symbology used by the United States Postal Service to assist in directing mail.';
        _method = 'postnet()';
        _barcode = Barcode.postnet();
        break;
    }

    notifyListeners();
  }
}
