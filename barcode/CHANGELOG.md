# Changelog

## 2.2.9

- Implement POSTNET Barcode
- Fixed wrong left text position for CODE 39 with spacers disabled [NicolaVerbeeck]

## 2.2.8

- Add option to turn off spacers for CODE 39 [NicolaVerbeeck]

## 2.2.7

- Add text formatting options to GS1-128 [NicolaVerbeeck]

## 2.2.6

- Fix invalid UPC-E in some cases [shinbin]

## 2.2.5

- Fix EAN2 incorrect encoding issue [shinbin]

## 2.2.4

- Fix invalid Aztec in some cases [Tobias Eklund]
- Fix Dart 3.0 issues

## 2.2.3

- Fix Code-128 starting with even number of digits

## 2.2.2

- Avoids mandatory utf8 conversions
- Update dependencies
- Add DataMatrixEncoder
- Add DataMatrix tests

## 2.2.1

- Update Dart version number

## 2.2.0

- Allow the latest version of `package:qr`.
- Update dependencies

## 2.1.0

- Add ITF-16 Barcode

## 2.0.0-nullsafety

- Opt-in dart null-safety

## 1.17.1

- Fix telepen barcode checksum [chrishsieh]

## 1.17.0

- Implement BarcodeEan.normalize to return the barcode with the correct checksum

## 1.16.1

- Fix GS1-128 barcode

## 1.16.0

- Add textPadding parameter
- Update dependencies

## 1.15.0

- Add more options to codabar to specify the start and stop chars
- Improve documentation

## 1.14.0

- Allow Uint8List data barcodes
- Improve ITF barcode
- Add more unit tests

## 1.13.0

- Add Interleaved 2 of 5 (ITF) Barcode

## 1.12.0

- Add support for FNCx to GS1-128 and Code-128

## 1.11.1

- Improve 2d barcode verifications

## 1.11.0

- Fix font height error if not specified
- Implement RM4SCC Barcode

## 1.10.0

- Improve UPC-E barcode

## 1.9.1

- Fix issue with web build

## 1.9.0

- Add Aztec
- Add MeCard generator
- Use BarcodeException for all errors

## 1.8.0

- Add Codabar
- Add PDF417
- Add Data Matrix

## 1.7.0

- Add QR-Code

## 1.6.0

- Add Telepen

## 1.5.0

- Reorganize the library
- Add EAN 2
- Add EAN 5
- Add GS1-128 support
- Add ITF-14

## 1.4.0

- Implement proper EAN-13 rendering
- Implement proper UPC-A rendering
- Implement proper UPC-E rendering
- Implement proper EAN-8 rendering
- Implement proper ISBN rendering

## 1.3.0

- Add text align property
- Add a SVG drawing function

## 1.2.0

- Add a method to check Barcode validity
- Add CODE 128 A
- Add CODE 128 C
- Add misc functions to Barcode

## 1.1.2

- Update README

## 1.1.1

- Fix URLs

## 1.1.0

- Add EAN13
- Add EAN8
- Add ISBN
- Add UPC-A
- Add UPC-E
- Fix Code 93

## 1.0.0

Breaking change: different API

- Supports text output
- Add CODE 93
- Add CODE 128 B
- Add documentation

## 0.1.0

- Initial release, only CODE 39 support for now
