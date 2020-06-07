# barcode_widget

Barcode Widget for flutter.

[![Buy Me A Coffee](https://bmc-cdn.nyc3.digitaloceanspaces.com/BMC-button-images/custom_images/orange_img.png "Buy Me A Coffee")](https://www.buymeacoffee.com/JORBmbw9h "Buy Me A Coffee")

This widget uses [pub:barcode](https://pub.dev/packages/barcode) to generate any supported Barcodes.

<img alt="Barcode Demo" src="https://raw.githubusercontent.com/DavBfr/dart_barcode/master/img/flutter.png">

## Live example with Flutter Web

<https://davbfr.github.io/dart_barcode/>

## Getting Started

In your flutter project add the dependency:

```yml
dependencies:
  ...
  barcode_widget:
```

For help getting started with Flutter, view the online
[documentation](https://flutter.dev/).

## Usage example

Import `barcode_widget.dart`

```dart
import 'package:barcode_widget/barcode_widget.dart';
```

Use the widget directly

```dart
BarcodeWidget(
  barcode: Barcode.code128(),
  data: 'Hello Flutter',
);
```

To display an custom error message if the barcode is not valid, use:

```dart
BarcodeWidget(
  barcode: Barcode.ean13(),
  data: 'Hello',
  errorBuilder: (context, error) => Center(child: Text(error)),
);
```

Many layout options are available like: width, height, margin, padding, colors, etc.

To add a logo on top of a QrCode, use Flutter's composing abilities while increasing the error recovery density:

```dart
Stack(
  alignment: Alignment.center,
  children: [
    BarcodeWidget(
      barcode: Barcode.qrCode(
        errorCorrectLevel: BarcodeQRCorrectionLevel.high,
      ),
      data: 'https://pub.dev/packages/barcode_widget',
      width: 200,
      height: 200,
    ),
    Container(
      color: Colors.white,
      width: 60,
      height: 60,
      child: const FlutterLogo(),
    ),
  ],
)
```
