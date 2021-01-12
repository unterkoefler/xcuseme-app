import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:xcuseme/main.dart';
import 'package:xcuseme/model.dart';

void main() {
  testWidgets('Loading page appears', (WidgetTester tester) async {
    await tester.pumpWidget(ChangeNotifierProvider<Model>(
        create: (context) => Model([]), child: XCuseMeApp()));

    expect(find.text('XCuseMe'), findsOneWidget);
    expect(
        find.text('The exercise tracking app for real people'), findsOneWidget);
  });
}
