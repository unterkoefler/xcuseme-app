import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:xcuseme/main.dart';

void main() {
  testWidgets('Log buttons appear', (WidgetTester tester) async {
    await tester.pumpWidget(XCuseMeApp());

    expect(find.text('Log Excuse'), findsOneWidget);
    expect(find.text('Log Exercise'), findsOneWidget);
  });
}
