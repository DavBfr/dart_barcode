import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';

// ignore_for_file: public_member_api_docs

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

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
