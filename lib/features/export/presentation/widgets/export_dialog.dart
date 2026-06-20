import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../app/di/injection.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../editor/domain/entities/edit_session.dart';
import '../../../editor/presentation/bloc/editor_bloc.dart';
import '../../../editor/presentation/bloc/editor_event.dart';
import '../../domain/usecases/export_jpeg.dart';
import '../../domain/usecases/export_png.dart';
import '../../domain/usecases/share_image.dart';

class ExportDialog extends StatefulWidget {
  final EditSession session;

  const ExportDialog({super.key, required this.session});

  @override
  State<ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<ExportDialog> {
  String _format = 'jpeg'; // 'jpeg' or 'png'
  double _quality = 90.0;
  double _scale = 1.0;
  final TextEditingController _pathController = TextEditingController();
  bool _isResolvingPath = true;
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    _initDefaultPath();
  }

  @override
  void dispose() {
    _pathController.dispose();
    super.dispose();
  }

  Future<void> _initDefaultPath() async {
    try {
      final path = await _getDefaultExportPath();
      if (mounted) {
        setState(() {
          _pathController.text = path;
          _isResolvingPath = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _pathController.text = '';
          _isResolvingPath = false;
        });
      }
    }
  }

  Future<String> _getDefaultExportPath() async {
    String dirPath;
    if (Platform.isWindows) {
      final downloadsDir = await getDownloadsDirectory();
      dirPath = downloadsDir?.path ?? 'C:/Users/ACER/Downloads';
    } else if (Platform.isAndroid) {
      dirPath = '/storage/emulated/0/Download';
    } else {
      final docsDir = await getApplicationDocumentsDirectory();
      dirPath = docsDir.path;
    }

    final extension = _format == 'png' ? 'png' : 'jpg';
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    // Replace backslashes with forward slashes for cross-platform safety
    dirPath = dirPath.replaceAll('\\', '/');
    return '$dirPath/SeedColor_$timestamp.$extension';
  }

  void _onFormatChanged(String format) {
    setState(() {
      _format = format;
    });
    final currentPath = _pathController.text.trim();
    if (currentPath.isNotEmpty) {
      final lastDot = currentPath.lastIndexOf('.');
      if (lastDot != -1) {
        final base = currentPath.substring(0, lastDot);
        final extension = format == 'png' ? 'png' : 'jpg';
        _pathController.text = '$base.$extension';
      }
    }
  }

  Future<void> _shareImage() async {
    setState(() {
      _isSharing = true;
    });

    try {
      final tempDir = await getTemporaryDirectory();
      final extension = _format == 'png' ? 'png' : 'jpg';
      final tempPath = '${tempDir.path}/share_${DateTime.now().millisecondsSinceEpoch}.$extension'.replaceAll('\\', '/');

      if (_format == 'png') {
        final result = await sl<ExportPng>().call(
          widget.session,
          outputPath: tempPath,
          scale: _scale,
        );
        result.fold(
          (failure) => throw Exception(failure.toString()),
          (path) => null,
        );
      } else {
        final result = await sl<ExportJpeg>().call(
          widget.session,
          outputPath: tempPath,
          quality: _quality.toInt(),
          scale: _scale,
        );
        result.fold(
          (failure) => throw Exception(failure.toString()),
          (path) => null,
        );
      }

      await sl<ShareImage>().call(tempPath);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membagikan gambar: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
        Navigator.pop(context);
      }
    }
  }

  void _exportImage() {
    final path = _pathController.text.trim();
    if (path.isEmpty) return;

    context.read<EditorBloc>().add(
      Export(
        outputPath: path,
        quality: _quality.toInt(),
        format: _format,
        scale: _scale,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.backgroundPanel,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 360,
        padding: const EdgeInsets.all(20),
        child: _isSharing
            ? _buildSharingProgress()
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Row(
                      children: [
                        const Icon(Icons.ios_share_rounded, color: AppColors.primary, size: 24),
                        const SizedBox(width: 10),
                        Text(
                          'Ekspor Foto',
                          style: AppTypography.heading4.copyWith(color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Format Selector
                    Text(
                      'FORMAT GAMBAR',
                      style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary, letterSpacing: 1),
                    ),
                    const SizedBox(height: 8),
                    _buildFormatSelector(),
                    const SizedBox(height: 20),

                    // Quality Slider (JPEG only)
                    if (_format == 'jpeg') ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'KUALITAS KOMPRESI',
                            style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary, letterSpacing: 1),
                          ),
                          Text(
                            '${_quality.toInt()}%',
                            style: AppTypography.labelMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: AppColors.primary,
                          inactiveTrackColor: AppColors.border,
                          thumbColor: AppColors.primary,
                          overlayColor: AppColors.primarySurface,
                        ),
                        child: Slider(
                          value: _quality,
                          min: 10.0,
                          max: 100.0,
                          divisions: 9,
                          onChanged: (val) {
                            setState(() {
                              _quality = val;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Dimensions Scale
                    Text(
                      'UKURAN OUTPUT',
                      style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary, letterSpacing: 1),
                    ),
                    const SizedBox(height: 8),
                    _buildScaleDropdown(),
                    const SizedBox(height: 20),

                    // Output Path Field
                    Text(
                      'JALUR BERKAS KELUARAN',
                      style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary, letterSpacing: 1),
                    ),
                    const SizedBox(height: 8),
                    _buildPathField(),
                    const SizedBox(height: 24),

                    // Buttons
                    _buildActionsRow(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSharingProgress() {
    return const SizedBox(
      height: 180,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            SizedBox(height: 16),
            Text(
              'Menyiapkan berkas sharing...',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormatSelector() {
    return Row(
      children: [
        _buildFormatButton('JPEG', 'jpeg'),
        const SizedBox(width: 12),
        _buildFormatButton('PNG (Lossless)', 'png'),
      ],
    );
  }

  Widget _buildFormatButton(String label, String value) {
    final isSelected = _format == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => _onFormatChanged(value),
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primarySurface : AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScaleDropdown() {
    return DropdownButtonFormField<double>(
      value: _scale,
      isExpanded: true,
      dropdownColor: AppColors.backgroundPanel,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
      items: const [
        DropdownMenuItem(value: 1.0, child: Text('Asli (100% Resolusi)')),
        DropdownMenuItem(value: 0.5, child: Text('Sedang (50% Resolusi)')),
        DropdownMenuItem(value: 0.25, child: Text('Kecil (25% Resolusi)')),
      ],
      onChanged: (val) {
        if (val != null) {
          setState(() {
            _scale = val;
          });
        }
      },
    );
  }

  Widget _buildPathField() {
    if (_isResolvingPath) {
      return Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.textTertiary),
            ),
          ),
        ),
      );
    }

    return TextField(
      controller: _pathController,
      style: const TextStyle(color: Colors.white, fontSize: 11),
      maxLines: 2,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.all(12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildActionsRow() {
    return Row(
      children: [
        // Batal
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          child: const Text('Batal', style: TextStyle(color: Colors.white70)),
        ),
        const Spacer(),
        // Bagikan
        OutlinedButton(
          onPressed: _shareImage,
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: AppColors.border),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.share_rounded, size: 12),
              SizedBox(width: 4),
              Text('Share', style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(width: 6),
        // Ekspor
        ElevatedButton(
          onPressed: _exportImage,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          child: const Text('Ekspor', style: TextStyle(fontSize: 12)),
        ),
      ],
    );
  }
}
