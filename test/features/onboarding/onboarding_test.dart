import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seed_color/features/onboarding/presentation/pages/onboarding_page.dart';

void main() {
  Widget createWidgetUnderTesting() {
    return const MaterialApp(
      home: OnboardingPage(),
    );
  }

  testWidgets('should render OnboardingPage slides and navigate to final slide', (tester) async {
    await tester.pumpWidget(createWidgetUnderTesting());
    await tester.pumpAndSettle();

    // Verify slide 1 title is visible
    expect(find.text('Selamat Datang di SeedColor'), findsOneWidget);
    expect(find.text('Lanjut'), findsOneWidget);
    expect(find.text('Lewati'), findsOneWidget);

    // Tap next to go to slide 2
    await tester.tap(find.text('Lanjut'));
    await tester.pumpAndSettle();

    // Verify slide 2 title
    expect(find.text('Kontrol Tonalitas Presisi'), findsOneWidget);

    // Tap next to go to slide 3
    await tester.tap(find.text('Lanjut'));
    await tester.pumpAndSettle();

    // Verify slide 3 title
    expect(find.text('15+ Presets Premium & XMP'), findsOneWidget);

    // Tap next to go to slide 4 (last slide)
    await tester.tap(find.text('Lanjut'));
    await tester.pumpAndSettle();

    // Verify slide 4 title
    expect(find.text('Ekspor Resolusi Penuh & Share'), findsOneWidget);

    // Skip button should be gone, "Mulai Sekarang" button should be visible
    expect(find.text('Lewati'), findsNothing);
    expect(find.text('Mulai Sekarang'), findsOneWidget);
  });
}
