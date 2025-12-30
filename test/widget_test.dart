// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:shopfloor_app/main.dart';

void main() {
  testWidgets('Shows login screen when no session', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // The Login screen app bar should be visible
    expect(find.widgetWithText(AppBar, 'Login'), findsOneWidget);
    // Email label exists
    expect(find.text('Email'), findsOneWidget);
  });
}
