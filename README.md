# 🌱 SeedColor

**SeedColor by DevSeed Studio**

> Aplikasi koreksi warna dan color grading profesional untuk Android — terinspirasi Adobe Lightroom Mobile.
> **Status**: 🎨 UI Redesign ke Brand Biru (#0A84FF), Bottom Navigation 4-Tab, integrasi BLoC dengan Panel Light & Color (Step 7), Panel HSL Color Mixer (Step 8), Panel Curves (Step 9), Panel Effects & Color Grading (Step 10), serta Dukungan RAW Processing (Step 17) telah selesai diimplementasikan.

---

## 📋 Informasi Proyek

| Item | Detail |
|:-----|:-------|
| **Nama Aplikasi** | SeedColor |
| **Developer** | DevSeed Studio |
| **Platform** | Android |
| **Bahasa UI** | Bahasa Indonesia |
| **Brand Color** | Biru (#0A84FF) — Redesigned dari Hijau |
| **Framework** | Flutter 3.38+ / Dart 3.10+ |
| **Arsitektur** | Clean Architecture + BLoC (Presentation Scaffolded) |
| **Lisensi** | Private — untuk kebutuhan pribadi |
| **Preset Format** | Kompatibel dengan `.xmp` Lightroom |

---

## 🎯 Visi Produk

SeedColor adalah aplikasi **koreksi warna dan color grading** yang memiliki fitur setara Adobe Lightroom Mobile, dibangun khusus untuk Android menggunakan Flutter. Fokus utama pada:

1. **Light & Color Correction** — Kontrol penuh atas exposure, contrast, highlights, shadows
2. **Color Grading** — HSL mixer, color grading wheels, curves
3. **AI-Powered Masking** — Subject, sky, dan people masking otomatis
4. **Preset System** — Kompatibel dengan preset `.xmp` Lightroom
5. **Profesional Output** — Export kualitas tinggi dengan dukungan RAW

---

## 🏗️ Arsitektur Aplikasi

```
┌─────────────────────────────────────────────────────┐
│                  PRESENTATION LAYER                  │
│  Flutter Widgets + BLoC/Cubit State Management       │
│  (UI dalam Bahasa Indonesia)                         │
├─────────────────────────────────────────────────────┤
│                    DOMAIN LAYER                      │
│  Entities + Use Cases + Repository Interfaces        │
│  (Pure Dart — tidak bergantung framework)            │
├─────────────────────────────────────────────────────┤
│                     DATA LAYER                       │
│  Repository Implementations + Data Sources           │
├─────────────────────────────────────────────────────┤
│               NATIVE PROCESSING LAYER                │
│  Fragment Shaders │ OpenCV FFI │ TFLite │ LibRaw     │
└─────────────────────────────────────────────────────┘
```

### Teknologi yang Digunakan

| Komponen | Teknologi | Fungsi |
|:---------|:----------|:-------|
| Framework | Flutter 3.38+ / Dart 3.10+ | Cross-platform UI framework |
| State Management | `flutter_bloc` + `replay_bloc` | State + undo/redo bawaan |
| Preview Engine | Flutter Fragment Shaders (GLSL) | Real-time preview 60fps di GPU |
| Export Engine | `opencv_dart` v2.x via Dart FFI | Proses full-resolution |
| AI/ML | `flutter_litert` (TFLite successor) | Segmentasi & masking on-device |
| AI Segmentasi | Google ML Kit | Subject/sky/people detection |
| RAW Processing | `flutter_libraw` + Dart FFI | DNG, CR2, NEF, ARW |
| Database | `drift` (SQLite wrapper) | Album, metadata, ratings |
| Dependency Injection | `get_it` + `injectable` | Service locator |
| Routing | `go_router` | Navigation |
| Font | Google Fonts (Inter, Outfit) | Typography premium |

---

## 📦 Daftar Fitur Lengkap

### ✅ = Akan dibuat | 🔮 = Fitur masa depan

---

### 🖼️ Import & Library

| # | Fitur | Status | Fase |
|:--|:------|:------:|:----:|
| 1 | Import JPG | ✅ | MVP |
| 2 | Import PNG | ✅ | MVP |
| 3 | Import HEIC | ✅ | MVP |
| 4 | Import RAW (DNG, CR2, NEF, ARW) | ✅ | Phase 2 |
| 5 | Album Management | ✅ | MVP |
| 6 | Folder Browser | ✅ | MVP |
| 7 | Rating Bintang (1-5) | ✅ | MVP |
| 8 | Flag (Pick/Reject) | ✅ | MVP |
| 9 | Keyword Tagging | ✅ | Phase 2 |

---

### ☀️ Light (Pencahayaan)

| # | Fitur | Range | Status | Fase |
|:--|:------|:------|:------:|:----:|
| 1 | Exposure | -5.0 → +5.0 | ✅ | MVP |
| 2 | Contrast | -100 → +100 | ✅ | MVP |
| 3 | Highlights | -100 → +100 | ✅ | MVP |
| 4 | Shadows | -100 → +100 | ✅ | MVP |
| 5 | Whites | -100 → +100 | ✅ | MVP |
| 6 | Blacks | -100 → +100 | ✅ | MVP |
| 7 | Auto Light | otomatis | ✅ | MVP |

---

### 🎨 Color (Warna)

| # | Fitur | Range | Status | Fase |
|:--|:------|:------|:------:|:----:|
| 1 | Temperature | -100 → +100 | ✅ | MVP |
| 2 | Tint | -100 → +100 | ✅ | MVP |
| 3 | Vibrance | -100 → +100 | ✅ | MVP |
| 4 | Saturation | -100 → +100 | ✅ | MVP |

---

### 🌈 Color Mixer (HSL)

Setiap warna punya 3 kontrol: **Hue**, **Saturation**, **Luminance**

| # | Warna | Status | Fase |
|:--|:------|:------:|:----:|
| 1 | Red (Merah) | ✅ | MVP |
| 2 | Orange (Oranye) | ✅ | MVP |
| 3 | Yellow (Kuning) | ✅ | MVP |
| 4 | Green (Hijau) | ✅ | MVP |
| 5 | Aqua | ✅ | MVP |
| 6 | Blue (Biru) | ✅ | MVP |
| 7 | Purple (Ungu) | ✅ | MVP |
| 8 | Magenta | ✅ | MVP |

---

### 🎭 Color Grading

| # | Fitur | Status | Fase |
|:--|:------|:------:|:----:|
| 1 | Shadows Color Wheel | ✅ | MVP |
| 2 | Midtones Color Wheel | ✅ | MVP |
| 3 | Highlights Color Wheel | ✅ | MVP |
| 4 | Blending (0-100) | ✅ | MVP |
| 5 | Balance (-100 → +100) | ✅ | MVP |

---

### ✨ Effects (Efek)

| # | Fitur | Range | Status | Fase |
|:--|:------|:------|:------:|:----:|
| 1 | Texture | -100 → +100 | ✅ | MVP |
| 2 | Clarity | -100 → +100 | ✅ | MVP |
| 3 | Dehaze | -100 → +100 | ✅ | MVP |
| 4 | Vignette | -100 → +100 | ✅ | MVP |
| 5 | Grain | 0 → 100 | ✅ | MVP |

---

### 🔍 Detail

| # | Fitur | Status | Fase |
|:--|:------|:------:|:----:|
| 1 | Sharpening Amount | ✅ | MVP |
| 2 | Sharpening Radius | ✅ | MVP |
| 3 | Sharpening Detail | ✅ | MVP |
| 4 | Sharpening Masking | ✅ | MVP |
| 5 | Noise Reduction — Luminance | ✅ | MVP |
| 6 | Noise Reduction — Color | ✅ | MVP |

---

### 🔭 Optics

| # | Fitur | Status | Fase |
|:--|:------|:------:|:----:|
| 1 | Chromatic Aberration Removal | ✅ | MVP |
| 2 | Lens Correction | ✅ | MVP |

---

### 📐 Geometry

| # | Fitur | Status | Fase |
|:--|:------|:------:|:----:|
| 1 | Rotate (-45° → +45°) | ✅ | MVP |
| 2 | Crop (Free, 1:1, 4:3, 16:9, 3:2) | ✅ | MVP |
| 3 | Perspective Vertical | ✅ | MVP |
| 4 | Perspective Horizontal | ✅ | MVP |
| 5 | Distortion Correction | ✅ | MVP |
| 6 | Flip Horizontal | ✅ | MVP |
| 7 | Flip Vertical | ✅ | MVP |

---

### 📈 Curves

| # | Fitur | Status | Fase |
|:--|:------|:------:|:----:|
| 1 | RGB Curve (master) | ✅ | MVP |
| 2 | Red Channel Curve | ✅ | MVP |
| 3 | Green Channel Curve | ✅ | MVP |
| 4 | Blue Channel Curve | ✅ | MVP |
| 5 | Histogram backdrop | ✅ | MVP |
| 6 | Touch to add point | ✅ | MVP |
| 7 | Long press to delete point | ✅ | MVP |

---

### 🎬 Presets

| # | Fitur | Status | Fase |
|:--|:------|:------:|:----:|
| 1 | Built-in Presets (15-20 preset) | ✅ | MVP |
| 2 | Save Custom Preset | ✅ | MVP |
| 3 | Import Preset (.xmp) | ✅ | MVP |
| 4 | Export Preset (.xmp) | ✅ | MVP |
| 5 | Preset Categories | ✅ | MVP |
| 6 | Preset Preview Thumbnail | ✅ | MVP |

---

### 🔄 Before/After & History

| # | Fitur | Status | Fase |
|:--|:------|:------:|:----:|
| 1 | Before/After Slider | ✅ | Phase 2 |
| 2 | Undo Tanpa Batas | ✅ | MVP |
| 3 | Redo | ✅ | MVP |
| 4 | Full History List | ✅ | Phase 2 |
| 5 | Named Snapshots | ✅ | Phase 2 |

---

### 📂 Batch & LUT

| # | Fitur | Status | Fase |
|:--|:------|:------:|:----:|
| 1 | Batch Editing (multi foto) | ✅ | Phase 2 |
| 2 | Import LUT (.cube) | ✅ | Phase 2 |
| 3 | Import LUT (.3dl) | ✅ | Phase 2 |

---

### 🎭 Masking (Seleksi Area)

| # | Fitur | Status | Fase |
|:--|:------|:------:|:----:|
| 1 | Brush Mask (lukis manual) | ✅ | Phase 3 |
| 2 | Linear Gradient | ✅ | Phase 3 |
| 3 | Radial Gradient | ✅ | Phase 3 |
| 4 | AI Subject Mask | ✅ | Phase 3 |
| 5 | AI Sky Mask | ✅ | Phase 3 |
| 6 | AI Background Mask | ✅ | Phase 3 |
| 7 | AI People Mask (Wajah, Rambut, dll) | ✅ | Phase 3 |
| 8 | Object Selection (tap) | ✅ | Phase 3 |
| 9 | Color Range Mask | ✅ | Phase 3 |
| 10 | Luminance Range Mask | ✅ | Phase 3 |
| 11 | Depth Mask | 🔮 | Future |

---

### 🤖 AI Premium Features

| # | Fitur | Status | Fase |
|:--|:------|:------:|:----:|
| 1 | AI Auto Enhance | ✅ | Phase 4 |
| 2 | AI Denoise | ✅ | Phase 4 |
| 3 | AI Portrait (Smooth Skin, dll) | ✅ | Phase 4 |
| 4 | AI Relight | 🔮 | Future |
| 5 | AI Remove Object | ✅ | Phase 4 |
| 6 | AI Generative Fill | ✅ | Phase 4 |

---

### 💾 Export

| # | Fitur | Status | Fase |
|:--|:------|:------:|:----:|
| 1 | Export JPEG (kualitas adjustable) | ✅ | MVP |
| 2 | Export PNG | ✅ | MVP |
| 3 | Share ke aplikasi lain | ✅ | MVP |
| 4 | Export dengan metadata EXIF | ✅ | Phase 2 |

---

## 🗺️ Roadmap Step-by-Step

Ikuti urutan ini agar tidak kehilangan arah. Setiap step saling bergantung — **jangan loncat!**

---

### 📍 FASE 1: MVP (Bulan 1-4)

> Target: Aplikasi yang sudah bisa dipakai untuk edit foto dengan fitur Light, Color, HSL, Curves, Effects, Color Grading, Crop, dan Presets.

---

#### 🔹 Step 1: Setup Proyek & Design System (Minggu 1)

**Apa yang dikerjakan:**
- [x] Inisialisasi Flutter project (`flutter create`)
- [x] Setup struktur folder Clean Architecture (Presentation Layer)
- [x] Tambahkan semua dependencies di `pubspec.yaml`
- [x] Buat design system (tema, warna, typography - Brand Biru #0A84FF)
- [x] Setup dependency injection (GetIt)
- [x] Setup routing (GoRouter dengan ShellRoute)

**File yang dibuat:**
```
lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── routes.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   ├── app_colors.dart
│   │   └── app_typography.dart
│   └── di/
│       └── injection.dart
```

**Dependencies (`pubspec.yaml`):**
```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^9.x
  replay_bloc: ^0.x
  go_router: ^14.x
  get_it: ^8.x
  injectable: ^2.x
  drift: ^2.x
  path_provider: ^2.x
  google_fonts: ^6.x
  flutter_screenutil: ^5.x
  equatable: ^2.x
  image_picker: ^1.x
  share_plus: ^10.x
  permission_handler: ^11.x

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.x
  injectable_generator: ^2.x
  drift_dev: ^2.x
```

**Cara verifikasi:**
```bash
flutter run        # Harus bisa jalan tanpa error
flutter analyze    # Harus 0 issues
```

---

#### 🔹 Step 2: Core Widgets & Utilities (Minggu 1-2)

**Apa yang dikerjakan:**
- [x] Buat `SeedSlider` — custom slider mirip Lightroom (centered, gradient track, value label)
- [x] Buat `SeedButton` — icon button dengan animasi
- [x] Buat `SeedBottomSheet` — pattern bottom sheet
- [x] Buat math utilities (spline interpolation untuk Curves)
- [x] Buat debounce utilities (agar slider smooth)
- [x] Buat color extension methods (RGB ↔ HSL konversi)

**File yang dibuat:**
```
lib/core/
├── widgets/
│   ├── seed_slider.dart
│   ├── seed_button.dart
│   ├── seed_bottom_sheet.dart
│   └── loading_overlay.dart
├── utils/
│   ├── math_utils.dart
│   ├── debounce_utils.dart
│   └── image_utils.dart
├── extensions/
│   ├── color_extensions.dart
│   └── image_extensions.dart
├── constants/
│   ├── app_constants.dart
│   └── image_constants.dart
└── errors/
    └── failures.dart
```

**Cara verifikasi:**
```bash
# Buat halaman test sederhana yang menampilkan semua widget
# Pastikan slider smooth, animasi berjalan
flutter run
```

---

#### 🔹 Step 3: Fragment Shaders — Preview Engine (Minggu 2-3)

> ⚠️ Ini adalah JANTUNG aplikasi. Semua adjustment diterapkan di GPU via shader.

**Apa yang dikerjakan:**
- [x] Buat `adjustments.frag` — Exposure, Contrast, Highlights, Shadows, Whites, Blacks
- [x] Buat `color_adjustments.frag` — Temperature, Tint, Vibrance, Saturation
- [x] Buat `curves.frag` — LUT-based curve application per channel
- [x] Buat `effects.frag` — Texture, Clarity, Dehaze, Vignette, Grain
- [x] Buat `color_grading.frag` — Shadow/Midtone/Highlight color wheels
- [x] Buat `composite.frag` — Chain semua shader dalam urutan benar
- [x] Register shaders di `pubspec.yaml` (bagian `flutter: > shaders:`)

**File yang dibuat:**
```
lib/shaders/
├── adjustments.frag
├── color_adjustments.frag
├── curves.frag
├── effects.frag
├── color_grading.frag
└── composite.frag
```

**Urutan pipeline shader:**
```
Foto Asli
  → adjustments.frag     (Light)
  → color_adjustments.frag (Color + HSL)
  → curves.frag           (Curves)
  → effects.frag          (Effects)
  → color_grading.frag    (Color Grading)
  → Output Preview
```

**Cara verifikasi:**
```bash
# Shader harus compile tanpa error saat build
flutter build apk --debug
# Test dengan gambar statis dan slider exposure
```

---

#### 🔹 Step 4: Editor — Domain Layer (Minggu 3-4)

**Apa yang dikerjakan:**
- [x] Buat entity `EditParameters` — semua nilai adjustment (immutable, copyWith)
- [x] Buat entity `CurveData` — control points per channel + spline generator
- [x] Buat entity `HslAdjustments` — per-color H/S/L values (8 warna)
- [x] Buat entity `EditSession` — sesi editing (foto + parameters + metadata)
- [x] Buat repository interface `EditorRepository`
- [x] Buat use cases: `ApplyAdjustments`, `ApplyCurves`, `ApplyHSL`, `ExportImage`, `ResetAdjustments`

**File yang dibuat:**
```
lib/features/editor/domain/
├── entities/
│   ├── edit_session.dart
│   ├── edit_parameters.dart
│   ├── curve_data.dart
│   └── hsl_adjustments.dart
├── repositories/
│   └── editor_repository.dart
└── usecases/
    ├── apply_adjustments.dart
    ├── apply_curves.dart
    ├── apply_hsl.dart
    ├── export_image.dart
    └── reset_adjustments.dart
```

**Cara verifikasi:**
```bash
# Unit test entities
flutter test test/features/editor/domain/
```

---

#### 🔹 Step 5: Editor — BLoC + State Management (Minggu 4)

**Apa yang dikerjakan:**
- [x] Buat `EditorBloc` extends `ReplayBloc` (undo/redo bawaan!)
- [x] Buat semua Events: `UpdateLight`, `UpdateColor`, `UpdateHSL`, `UpdateCurves`, `UpdateEffects`, `UpdateColorGrading`, `ResetAll`, `Export`
- [x] Buat `EditorState` dengan semua parameters
- [x] Implementasi debounced state emission (slider jangan emit tiap pixel)

**File yang dibuat:**
```
lib/features/editor/presentation/bloc/
├── editor_bloc.dart
├── editor_event.dart
└── editor_state.dart
```

**Cara verifikasi:**
```bash
# Unit test BLoC
flutter test test/features/editor/presentation/bloc/
```

---

#### 🔹 Step 6: Editor — UI Layout (Minggu 4-5)

**Apa yang dikerjakan:**
- [x] Buat `EditorPage` — layout utama editor
  - Top 70%: Preview gambar (image canvas mock)
  - Bottom 30%: Tool panel (Light, Color, Effects, Detail, Geometry, Masking)
  - Top bar: Back, Undo, Redo, Share
- [x] Buat `ImageCanvas` — CustomPainter yang menggunakan shader (masih canvas static mockup)
- [x] Buat `ToolSelector` — bar horizontal untuk pilih tool
- [x] Buat `AdjustmentPanel` — container untuk panel aktif (sliders Lightroom-style)

**Layout editor:**
```
┌──────────────────────────┐
│  ← Undo Redo    ⟷  📤   │  ← Top Bar
├──────────────────────────┤
│                          │
│                          │
│      IMAGE PREVIEW       │  ← 70% layar
│     (Shader Canvas)      │
│                          │
│                          │
├──────────────────────────┤
│ ☀️ 🎨 🌈 ✨ 🔍 📈 🎭 📐  │  ← Tool Selector
├──────────────────────────┤
│                          │
│    ADJUSTMENT SLIDERS    │  ← 30% layar
│                          │
└──────────────────────────┘
```

**File yang dibuat:**
```
lib/features/editor/presentation/
├── pages/
│   └── editor_page.dart
└── widgets/
    ├── image_canvas.dart
    ├── adjustment_panel.dart
    └── tool_selector.dart
```

**Cara verifikasi:**
```bash
flutter run
# Buka editor, pastikan layout benar
# Gambar harus muncul di canvas
# Tool selector harus bisa di-scroll dan tap
```

---

#### 🔹 Step 7: Panel — Light & Color (Minggu 5-6)

> 🎉 Ini titik di mana aplikasi mulai terasa "real"!

**Apa yang dikerjakan:**
- [x] Buat `LightPanel` — 6 slider + tombol Auto
- [x] Buat `ColorPanel` — 4 slider + visual temperature indicator
- [x] Hubungkan panel → BLoC → Shader
- [x] Test: geser slider, preview harus berubah real-time

**File yang dibuat:**
```
lib/features/editor/presentation/widgets/panels/
├── light_panel.dart
└── color_panel.dart
```

**Cara verifikasi:**
```bash
flutter run
# 1. Buka foto
# 2. Geser Exposure → gambar harus terang/gelap
# 3. Geser Temperature → gambar harus warm/cool
# 4. Pastikan smooth 60fps (tidak patah-patah)
```

---

#### 🔹 Step 8: Panel — HSL Color Mixer (Minggu 6-7)

**Apa yang dikerjakan:**
- [x] Buat `HslPanel` — color selector strip (8 warna) + 3 slider per warna
- [x] Implementasi HSL adjustment di shader (per-hue targeting)
- [x] Mini color preview yang berubah sesuai adjustment

**File yang dibuat:**
```
lib/features/editor/presentation/widgets/panels/
└── hsl_panel.dart
```

**Cara verifikasi:**
```bash
flutter run
# 1. Buka foto dengan warna langit biru
# 2. Pilih "Blue" di HSL
# 3. Geser Hue → warna langit harus berubah (misal jadi ungu)
# 4. Geser Saturation → langit harus lebih/kurang saturated
```

---

#### 🔹 Step 9: Panel — Curves (Minggu 7-8)

**Apa yang dikerjakan:**
- [x] Buat `CurvesPanel` — interactive curve editor
- [x] Buat `CurvePainter` — CustomPainter untuk gambar kurva
- [x] Buat `CurveControlPoint` — draggable point di kurva
- [x] Channel selector: RGB (putih), Red, Green, Blue
- [x] Histogram sebagai backdrop kurva
- [x] Touch to add point, long press to delete
- [x] Generate LUT texture dari curve points → kirim ke shader

**File yang dibuat:**
```
lib/features/editor/presentation/widgets/
├── panels/
│   └── curves_panel.dart
└── curves/
    ├── curve_painter.dart
    └── curve_control_point.dart
```

**Cara verifikasi:**
```bash
flutter run
# 1. Buka Curves
# 2. Drag titik tengah ke atas → gambar harus lebih terang
# 3. Buat S-curve → kontras harus meningkat
# 4. Switch ke Red channel → hanya merah yang berubah
```

---

#### 🔹 Step 10: Panel — Effects & Color Grading (Minggu 8-9)

**Apa yang dikerjakan:**
- [x] Buat `EffectsPanel` — 5 slider (Texture, Clarity, Dehaze, Vignette, Grain)
- [x] Buat `ColorGradingPanel` — 3 color wheels + 2 slider
- [x] Implementasi color wheel widget (tap/drag untuk pilih warna)

**File yang dibuat:**
```
lib/features/editor/presentation/widgets/panels/
├── effects_panel.dart
└── color_grading_panel.dart
```

**Cara verifikasi:**
```bash
flutter run
# 1. Clarity → gambar harus lebih "tajam" di midtones
# 2. Vignette → tepi gambar harus gelap
# 3. Color Grading → shadows harus berwarna sesuai wheel
```

---

#### 🔹 Step 11: Panel — Detail & Optics (Minggu 9-10)

**Apa yang dikerjakan:**
- [x] Buat `DetailPanel` — Sharpening (4 slider) + Noise Reduction (2 slider)
- [x] Buat `OpticsPanel` — Chromatic Aberration + Lens Correction toggles
- [x] Implementasi sharpening via convolution kernel di shader

**File yang dibuat:**
```
lib/features/editor/presentation/widgets/panels/
├── detail_panel.dart
└── optics_panel.dart
```

---

#### 🔹 Step 12: Panel — Geometry/Crop (Minggu 10-11)

**Apa yang dikerjakan:**
- [x] Buat `GeometryPanel` — Crop tool + Rotate + Perspective
- [x] Buat `CropOverlay` — visual crop frame dengan handles
- [x] Aspect ratio selector (Free, 1:1, 4:3, 16:9, 3:2)
- [x] Rotate slider dengan grid overlay
- [x] Flip horizontal/vertical

**File yang dibuat:**
```
lib/features/editor/presentation/widgets/
├── panels/
│   └── geometry_panel.dart
└── crop/
    └── crop_overlay.dart
```

---

#### 🔹 Step 13: Library & Import (Minggu 11-12)

**Apa yang dikerjakan:**
- [x] Buat `LibraryPage` — layout utama library
  - Header dengan logo kustom (Leaf C) dan Settings gear
  - Grid menu stats (Semua Foto, Favorit, Album, Tempat Sampah)
  - List album (Nature, City, Portrait, Travel)
- [x] Buat `PhotoGrid` — thumbnail grid dengan lazy loading
- [x] Buat `PhotoThumbnail` — card foto dengan rating overlay
- [x] Buat `AlbumCard` — card album
- [x] Import dari gallery (image_picker)
- [x] Database setup (drift/SQLite) untuk metadata foto
- [x] Rating bintang + Flag system

**File yang dibuat:**
```
lib/features/library/
├── data/
│   ├── datasources/
│   │   ├── photo_local_datasource.dart
│   │   └── album_local_datasource.dart
│   ├── models/
│   │   ├── photo_model.dart
│   │   └── album_model.dart
│   └── repositories/
│       └── library_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── photo.dart
│   │   └── album.dart
│   ├── repositories/
│   │   └── library_repository.dart
│   └── usecases/
│       ├── import_photos.dart
│       ├── get_albums.dart
│       └── manage_ratings.dart
└── presentation/
    ├── bloc/
    │   ├── library_bloc.dart
    │   ├── library_event.dart
    │   └── library_state.dart
    ├── pages/
    │   ├── library_page.dart
    │   └── album_detail_page.dart
    └── widgets/
        ├── photo_grid.dart
        ├── photo_thumbnail.dart
        └── album_card.dart
```

---

#### 🔹 Step 14: Preset System (Minggu 12-13)

**Apa yang dikerjakan:**
- [x] Buat `PresetBrowserPage` — Grid preset dengan tab: Recommended, Premium, Yours
- [x] Buat `PresetCard` — Card preset dengan gradient thumbnail, bookmark overlay, dan nama preset
- [x] Buat 15-20 built-in presets (data mock sudah dibuat di UI)
- [x] Save custom preset dari current adjustments
- [x] Import/Export preset format `.xmp` (kompatibel Lightroom)
- [x] Preset browser dengan preview thumbnails (menggunakan visual card gradient)
- [x] Category filter (tab bar Recommended/Premium/Yours)

**File yang dibuat:**
```
lib/features/presets/
├── data/
│   ├── models/
│   │   └── preset_model.dart
│   └── repositories/
│       └── preset_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── preset.dart
│   ├── repositories/
│   │   └── preset_repository.dart
│   └── usecases/
│       ├── save_preset.dart
│       ├── apply_preset.dart
│       └── import_export_preset.dart
└── presentation/
    ├── bloc/
    │   └── preset_bloc.dart
    ├── pages/
    │   └── preset_browser_page.dart
    └── widgets/
        ├── preset_card.dart
        └── preset_preview.dart
```

---

#### 🔹 Step 15: Export System (Minggu 13-14)

**Apa yang dikerjakan:**
- [x] Buat `ExportDialog` — pilihan format, kualitas, ukuran
- [x] Export JPEG dengan kualitas adjustable (0-100%)
- [x] Export PNG (lossless)
- [x] Full-resolution processing via GPU off-screen (bukan shader preview)
- [x] Share ke aplikasi lain (WhatsApp, Instagram, dll)
- [x] Progress indicator saat export

**File yang dibuat:**
```
lib/features/export/
├── domain/
│   └── usecases/
│       ├── export_jpeg.dart
│       ├── export_png.dart
│       └── share_image.dart
└── presentation/
    └── widgets/
        └── export_dialog.dart
```

---

#### 🔹 Step 16: Polish & Testing (Minggu 14-16)

**Apa yang dikerjakan:**
- [x] UI polish — animasi transisi antar panel
- [x] Loading states & error handling
- [x] Onboarding screen (first launch)
- [x] App icon & splash screen (branding SeedColor 🌱)
- [x] Performance profiling (target <16ms frame time)
- [x] Memory optimization (target <300MB untuk 20MP foto)
- [x] Unit tests untuk semua domain entities
- [x] Widget tests untuk core widgets
- [x] Integration test: import → edit → export flow
- [x] Bug fixing & stability

**Cara verifikasi akhir MVP:**
```bash
flutter test                     # Semua test pass
flutter analyze                  # 0 issues
flutter build apk --release      # Build sukses
flutter install                  # Install ke device
```

---

### 📍 FASE 2: Advanced Features (Bulan 5-8)

> Target: RAW support, history panel, before/after compare, batch editing, LUT support.

- [x] **Step 17:** RAW Processing — Import DNG/CR2/NEF/ARW via LibRaw FFI
- [x] **Step 18:** History Panel — Full list semua edit steps + named snapshots
- [x] **Step 19:** Before/After Compare — Swipe slider untuk compare
- [x] **Step 20:** Batch Editing — Apply preset/adjustments ke banyak foto sekaligus
- [ ] **Step 21:** LUT Support — Import & apply .cube dan .3dl files
- [ ] **Step 22:** Keyword Tagging — Search & filter foto by keyword
- [ ] **Step 23:** EXIF Export — Simpan metadata editing di output

---

### 📍 FASE 3: AI & Masking (Bulan 9-14)

> Target: Masking tools (brush, gradient, radial) + AI segmentation masks.

- [ ] **Step 24:** Brush Mask — Lukis area seleksi dengan jari
- [ ] **Step 25:** Linear Gradient Mask — Geser dari atas/bawah
- [ ] **Step 26:** Radial Gradient Mask — Lingkaran/elips
- [ ] **Step 27:** Masked Adjustments — Apply any adjustment hanya ke area mask
- [ ] **Step 28:** AI Subject Mask — TFLite model untuk deteksi subjek
- [ ] **Step 29:** AI Sky Mask — Deteksi langit otomatis
- [ ] **Step 30:** AI People Mask — Deteksi wajah, rambut, kulit, mata
- [ ] **Step 31:** Color Range Mask — Seleksi berdasarkan warna
- [ ] **Step 32:** Luminance Range Mask — Seleksi berdasarkan kecerahan

---

### 📍 FASE 4: Premium AI (Bulan 15-24)

> Target: Fitur AI canggih untuk editing otomatis.

- [ ] **Step 33:** AI Auto Enhance — Otomatis exposure, WB, contrast
- [ ] **Step 34:** AI Denoise — Neural network noise reduction
- [ ] **Step 35:** AI Portrait — Smooth skin, teeth whitening, eye enhancement
- [ ] **Step 36:** AI Remove Object — Hapus objek dengan inpainting
- [ ] **Step 37:** AI Generative Fill — Isi area kosong dengan AI

---

## 📁 Struktur Folder Lengkap

```
seed_color/
├── android/                      # Android native config
├── lib/
│   ├── main.dart                 # Entry point
│   ├── app/
│   │   ├── app.dart              # MaterialApp setup
│   │   ├── routes.dart           # GoRouter config
│   │   ├── theme/
│   │   │   ├── app_theme.dart    # Dark theme data
│   │   │   ├── app_colors.dart   # Brand colors
│   │   │   └── app_typography.dart
│   │   └── di/
│   │       └── injection.dart    # GetIt DI
│   │
│   ├── core/
│   │   ├── constants/
│   │   ├── extensions/
│   │   ├── utils/
│   │   ├── errors/
│   │   └── widgets/              # Reusable widgets
│   │
│   ├── features/
│   │   ├── library/              # Foto library & albums
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │
│   │   ├── editor/               # ⭐ Core editor
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │       ├── bloc/
│   │   │       ├── pages/
│   │   │       └── widgets/
│   │   │           └── panels/   # Semua tool panel
│   │   │
│   │   ├── presets/              # Preset management
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │
│   │   └── export/               # Export & sharing
│   │
│   └── shaders/                  # GLSL Fragment Shaders
│       ├── adjustments.frag
│       ├── color_adjustments.frag
│       ├── curves.frag
│       ├── effects.frag
│       ├── color_grading.frag
│       └── composite.frag
│
├── test/                         # Unit & widget tests
├── integration_test/             # Integration tests
├── assets/
│   ├── fonts/
│   ├── icons/
│   ├── presets/                  # Built-in preset files
│   └── models/                   # TFLite AI models (Phase 3)
│
├── pubspec.yaml
└── README.md                     # ← File ini!
```

---

## 🧪 Cara Testing

### Unit Test
```bash
flutter test test/features/editor/domain/   # Test domain entities
flutter test test/core/                      # Test utilities
```

### Widget Test
```bash
flutter test test/features/editor/presentation/widgets/
```

### Integration Test
```bash
flutter test integration_test/
```

### Build APK
```bash
flutter build apk --release
```

---

## 🚀 Cara Menjalankan

```bash
# 1. Clone/buka project
cd "d:\DevSeed Studio\SeedColor"

# 2. Install dependencies
flutter pub get

# 3. Generate code (drift, injectable)
dart run build_runner build

# 4. Jalankan di device/emulator Android
flutter run

# 5. Build release APK (memerlukan Android SDK)
flutter build apk --release
```

---

## 📝 Catatan Penting

### Performance Tips
- **Preview**: Gunakan downscaled image (max 1920px) untuk preview real-time
- **Export**: Proses full-resolution hanya saat export via background isolate
- **Memory**: Free native buffers segera setelah selesai dipakai
- **Shader**: Semua adjustment di-chain dalam 1 render pass jika memungkinkan

### Aturan Development
1. **Jangan loncat step** — setiap step saling bergantung
2. **Test setiap selesai 1 step** — jangan tunggu semua selesai
3. **Commit sering** — minimal 1 commit per step
4. **Domain first** — selalu buat entities & use cases sebelum UI
5. **Shader = prioritas** — kalau shader sudah jalan, sisanya tinggal UI

### Git Branching Strategy
```
main              ← Production ready
├── develop       ← Development branch
│   ├── feature/step-01-setup
│   ├── feature/step-02-core-widgets
│   ├── feature/step-03-shaders
│   └── ...
```

---

## 📞 Kontak

**DevSeed Studio**
Proyek pribadi untuk kebutuhan color correction & grading.

---

*Terakhir diperbarui: Juni 2026*
