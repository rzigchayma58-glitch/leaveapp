// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:leaveapp/services/local_notification_service.dart';

import 'package:leaveapp/main.dart';

void main() {
  testWidgets('App starts without error', (WidgetTester tester) async {
    // Create a local notification service for testing
    final localNotificationService = LocalNotificationService();
    await localNotificationService.initialize();
    
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(localNotificationService: localNotificationService));

    // Verify that the app starts (login screen should be visible)
    expect(find.text('Se connecter'), findsOneWidget);
  });
}
