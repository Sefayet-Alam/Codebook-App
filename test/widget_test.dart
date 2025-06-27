import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codebook_app/main.dart';

void main() {
  testWidgets('HomeScreen displays main buttons', (WidgetTester tester) async {
    // Build the CodebookApp widget
    await tester.pumpWidget(const CodebookApp());

    // Wait for animations, streams, etc.
    await tester.pumpAndSettle();

    // Verify the presence of buttons by their labels
    expect(find.text('Browse your Codebook'), findsOneWidget);
    expect(find.text('Get AI Help'), findsOneWidget);
    expect(find.text('Print PDF'), findsOneWidget);
    expect(find.text('Quit App'), findsOneWidget);
  });
}
