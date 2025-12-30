import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopfloor_app/screens/machine_list_screen.dart';

void main() {
  testWidgets('Search filters machines by name and id', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: MachineListScreen()));

    // initial state: all machines present
    expect(find.text('Cutter 1'), findsOneWidget);
    expect(find.text('Roller A'), findsOneWidget);

    // enter a search that matches only Cutter
    await tester.enterText(find.byKey(const Key('machine-search-field')), 'cutter');
    await tester.pumpAndSettle();

    expect(find.text('Cutter 1'), findsOneWidget);
    expect(find.text('Roller A'), findsNothing);

    // clear search
    await tester.tap(find.byIcon(Icons.clear));
    await tester.pumpAndSettle();

    expect(find.text('Roller A'), findsOneWidget);
  });
}
