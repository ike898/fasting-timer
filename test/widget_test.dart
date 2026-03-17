import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fasting_timer/main.dart';

void main() {
  testWidgets('App launches and shows FastingTimer title', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: FastingTimerApp()),
    );
    expect(find.text('FastingTimer'), findsOneWidget);
  });
}
