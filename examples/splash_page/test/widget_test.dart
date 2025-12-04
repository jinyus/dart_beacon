import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splash_page/app.dart';
import 'package:state_beacon/state_beacon.dart';

void main() {
  testWidgets('App shows splash screen and then home page', (tester) async {
    await tester.pumpWidget(LiteRefScope(child: const App()));

    // Initially, the splash screen should be shown
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Welcome to Recipe App'), findsNothing);

    // Wait for the startup process to complete
    await tester.pumpAndSettle();

    // Error case: HiveDatabase initialization fails the first time
    expect(
      find.text('Exception: Failed to initialize HiveDatabase'),
      findsOneWidget,
    );
    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    // Tap the retry button
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump(); // Start the retry process

    // During retry, the splash screen should show the progress indicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle(); // Wait for retry to complete

    // Now, the home page should be shown
    expect(find.text('Welcome to Recipe App'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
