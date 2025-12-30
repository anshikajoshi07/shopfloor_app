import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopfloor_app/main.dart';
import 'package:shopfloor_app/models/user_session.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app restores session and shows dashboard', (WidgetTester tester) async {
    final session = UserSession(email: 'u@t.com', role: 'Operator', tenantId: 'tenant_001', mockJwt: 'jwtx');
    SharedPreferences.setMockInitialValues({'user_session': jsonEncode(session.toJson())});

    await tester.pumpWidget(MyApp(initialSession: session));
    await tester.pumpAndSettle();

    expect(find.textContaining('Email: ${session.email}'), findsOneWidget);
    expect(find.textContaining('Role: ${session.role}'), findsOneWidget);
  });
}
