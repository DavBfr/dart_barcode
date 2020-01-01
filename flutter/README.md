# barcode_widget

Barcode Widget for flutter.

[![Buy Me A Coffee](https://bmc-cdn.nyc3.digitaloceanspaces.com/BMC-button-images/custom_images/orange_img.png "Buy Me A Coffee")](https://www.buymeacoffee.com/JORBmbw9h "Buy Me A Coffee")

This widget uses [pub:barcode](https://pub.dev/packages/barcode) to generate any supported Barcodes.

## Live example with Flutter Web

<https://davbfr.github.io/dart_barcode/>

<iframe style="width:100%;height:630px;" src="https://davbfr.github.io/dart_barcode/></iframe>

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

Many layout options are available like: width, height, margin, padding, colors, etc.
