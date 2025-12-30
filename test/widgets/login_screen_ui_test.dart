import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopfloor_app/screens/login_screen.dart';

void main() {
  testWidgets('Login UI shows logo, role buttons, and login button', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    expect(find.text('Shop Floor Lite'), findsOneWidget);
    expect(find.byKey(const Key('login-email-field')), findsOneWidget);
    expect(find.byKey(const Key('role-operator')), findsOneWidget);
    expect(find.byKey(const Key('role-supervisor')), findsOneWidget);
    expect(find.byKey(const Key('login-button')), findsOneWidget);

    // Default role is Operator and its button should be enabled
    final operatorBtn = tester.widget<OutlinedButton>(find.byKey(const Key('role-operator')));
    expect(operatorBtn.onPressed, isNotNull);
  });
}
