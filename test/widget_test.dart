import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// Import our actual app
import 'package:academic_intelligence/main.dart';

void main() {
  testWidgets('App boots up successfully smoke test', (WidgetTester tester) async {
    // 1. Build our app and trigger a frame. 
    // CRITICAL: We must wrap AcademicAIApp in a ProviderScope just like we did in main.dart
    await tester.pumpWidget(
      const ProviderScope(
        child: AcademicAIApp(),
      ),
    );

    // Wait for the UI to fully render (useful since we have some animations/blur)
    await tester.pumpAndSettle();

    // 2. Verify that our app successfully booted up by looking for text 
    // that exists on our LoginScreen.
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    
    // Ensure the old default counter app stuff is nowhere to be found
    expect(find.text('0'), findsNothing);
    expect(find.byIcon(CupertinoIcons.add), findsNothing);
  });
}
