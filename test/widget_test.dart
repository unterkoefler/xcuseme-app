import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:xcuseme/main.dart';
import 'package:xcuseme/model.dart';

void main() {
  testWidgets('Log buttons appear', (WidgetTester tester) async {
    await tester.pumpWidget(ChangeNotifierProvider<Model>(
      create: (context) => Model({}),
      child: XCuseMeApp()));

    expect(find.text('Log Excuse'), findsOneWidget);
    expect(find.text('Log Exercise'), findsOneWidget);
  });
}
