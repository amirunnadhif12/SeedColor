// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:seed_color/app/app.dart';
import 'package:seed_color/app/di/injection.dart';
import 'package:seed_color/core/database/app_database.dart';

void main() {
  setUp(() async {
    if (!sl.isRegistered<AppDatabase>()) {
      await initDependencies();
    }
  });

  testWidgets('App loads smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SeedColorApp());

    // Verify that the MaterialApp.router is built successfully.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
