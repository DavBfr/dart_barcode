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

// ignore_for_file: avoid_relative_lib_imports

import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Default settings', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BarcodeWidget(
          barcode: Barcode.code128(),
          data: 'Hello Flutter',
        ),
      ),
    );

    expect(find.byType(BarcodeWidget), findsOneWidget);
  });

  testWidgets('Clickable', (WidgetTester tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: GestureDetector(
          child: BarcodeWidget(
            barcode: Barcode.aztec(),
            data: 'Hello Flutter',
          ),
          onTap: () => tapped = true,
        ),
      ),
    );

    expect(tapped, isFalse);
    expect(find.byType(BarcodeWidget), findsOneWidget);
    await tester.tap(find.byType(BarcodeWidget));
    await tester.pump();
    expect(tapped, isTrue);
  });

  testWidgets('Error', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BarcodeWidget(
          barcode: Barcode.ean13(),
          data: 'Hello',
          errorBuilder: (context, error) => const FlutterLogo(),
        ),
      ),
    );

    expect(find.byType(BarcodeWidget), findsOneWidget);
    expect(find.byType(FlutterLogo), findsOneWidget);
  });

  testWidgets('No Error', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BarcodeWidget(
          barcode: Barcode.ean13(),
          data: '123456789012',
          errorBuilder: (context, error) => const FlutterLogo(),
        ),
      ),
    );

    expect(find.byType(BarcodeWidget), findsOneWidget);
    expect(find.byType(FlutterLogo), findsNothing);
  });
}
