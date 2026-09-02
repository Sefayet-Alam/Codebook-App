import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:codebook_app/widgets/code_viewer.dart';

void main() {
  testWidgets('CodeViewer displays code and available actions', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CodeViewer(
            code: 'void main() {}',
            language: 'dart',
            onCopy: _noop,
            onShare: _noop,
          ),
        ),
      ),
    );

    expect(find.text('View Code'), findsOneWidget);
    expect(
      tester.widget<CodeViewer>(find.byType(CodeViewer)).code,
      'void main() {}',
    );
    expect(find.text('Copy'), findsOneWidget);
    expect(find.text('Share'), findsOneWidget);
    expect(find.text('Close'), findsOneWidget);
  });
}

void _noop() {}
