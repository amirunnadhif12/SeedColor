import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seed_color/features/editor/domain/entities/hsl_adjustments.dart';
import 'package:seed_color/features/editor/presentation/widgets/compare_canvas.dart';

class FakeImage extends Fake implements ui.Image {
  @override
  int get width => 100;

  @override
  int get height => 100;

  @override
  bool get debugDisposed => false;

  @override
  void dispose() {}
}

void main() {
  test('BeforeClipper should clip correctly based on ratio', () {
    final clipper = BeforeClipper(0.35);
    const size = Size(200.0, 100.0);
    final clipRect = clipper.getClip(size);

    expect(clipRect, equals(const Rect.fromLTWH(0, 0, 70.0, 100.0)));
    expect(clipper.shouldReclip(BeforeClipper(0.35)), isFalse);
    expect(clipper.shouldReclip(BeforeClipper(0.50)), isTrue);
  });

  testWidgets('CompareCanvas should render labels and support dragging the handle', (tester) async {
    final image = FakeImage();
    final lutImage = FakeImage();
    final identityLutImage = FakeImage();
    double updatedDragRatio = 0.5;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 200,
              height: 200,
              child: CompareCanvas(
                image: image,
                lutImage: lutImage,
                identityLutImage: identityLutImage,
                shader: null,
                dragRatio: updatedDragRatio,
                onDragUpdate: (ratio) {
                  updatedDragRatio = ratio;
                },
                exposure: 0.0,
                contrast: 0.0,
                highlights: 0.0,
                shadows: 0.0,
                whites: 0.0,
                blacks: 0.0,
                temperature: 0.0,
                tint: 0.0,
                vibrance: 0.0,
                saturation: 0.0,
                hslAdjustments: const HslAdjustments(),
                textureAdjust: 0.0,
                clarity: 0.0,
                dehaze: 0.0,
                vignette: 0.0,
                grain: 0.0,
                sharpeningAmount: 40.0,
                sharpeningRadius: 1.0,
                sharpeningDetail: 25.0,
                sharpeningMasking: 0.0,
                luminanceNR: 0.0,
                colorNR: 25.0,
                removeChromaticAberration: false,
                enableLensCorrection: false,
                shadowsColor: const [0.0, 0.0, 0.0],
                midtonesColor: const [0.0, 0.0, 0.0],
                highlightsColor: const [0.0, 0.0, 0.0],
                cgBlending: 50.0,
                cgBalance: 0.0,
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify before/after text is visible initially
    expect(find.text('SEBELUM'), findsOneWidget);
    expect(find.text('SESUDAH'), findsOneWidget);

    // Find the slider knob (Icon Icons.swap_horiz_rounded)
    final knobFinder = find.byIcon(Icons.swap_horiz_rounded);
    expect(knobFinder, findsOneWidget);

    // Drag the knob to the left (e.g. from ratio 0.5 to 0.3)
    await tester.drag(knobFinder, const Offset(-40.0, 0.0));
    await tester.pumpAndSettle();

    // Verify callback was triggered and updated the dragRatio
    expect(updatedDragRatio, lessThan(0.5));
  });
}
