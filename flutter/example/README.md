# example

## pubspec.yaml

```yaml
dependencies:
  flutter:
    sdk: flutter
  barcode_widget:
  google_fonts:

```

## Import

```dart
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
```

## Widget

```dart
BarcodeWidget(
  barcode: Barcode.code128(),
  data: 'Hello World',
  width: 200,
  height: 80,
  style: GoogleFonts.sourceCodePro(
    textStyle: TextStyle(
      color: Colors.black,
      fontSize: 13,
    ),
  ),
  margin: EdgeInsets.all(20),
  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
  decoration: BoxDecoration(
      border: Border.all(
    color: Colors.blue,
  )),
);
```
