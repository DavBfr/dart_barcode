import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

void main() => runApp(MyApp());

Widget barcode(Barcode barcode, String data) {
  return Center(
      child: BarcodeWidget(
    barcode: barcode,
    data: data,
    width: 200,
    height: 80,
    style: GoogleFonts.sourceCodePro(
      textStyle: TextStyle(
        fontSize: 13,
      ),
    ),
    margin: EdgeInsets.all(20),
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
    decoration: BoxDecoration(
        border: Border.all(
      color: Colors.blue,
    )),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barcode Demo',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Barcode Demo'),
        ),
        body: Scrollbar(
          child: ListView(
            children: <Widget>[
              barcode(Barcode.code128(), 'Flutter'),
              barcode(Barcode.code39(), 'CODE 39'),
              barcode(Barcode.code93(), 'CODE 93'),
              barcode(Barcode.ean13(), '590123412345'),
              barcode(Barcode.ean8(), '9638507'),
              barcode(Barcode.isbn(), '978316148410'),
              barcode(Barcode.upcA(), '98765432109'),
              barcode(Barcode.upcE(), '06510000432'),
            ],
          ),
        ),
      ),
    );
  }
}
