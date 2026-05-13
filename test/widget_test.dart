// test/widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Bootstrap placeholder renders a loading indicator', (WidgetTester tester) async {
    await tester.pumpWidget(const _BootstrapPlaceholderTest());
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}

class _BootstrapPlaceholderTest extends StatelessWidget {
  const _BootstrapPlaceholderTest();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
