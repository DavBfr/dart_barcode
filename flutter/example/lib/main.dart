import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';

// ignore_for_file: public_member_api_docs

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Barcode demo'),
      ),
      body: Center(
        child: BarcodeWidget(
          barcode: Barcode.aztec(), // Barcode type and settings
          data: 'https://pub.dev/packages/barcode_widget', // Content
          width: 200,
          height: 200,
        ),
      ),
    );
  }
}
