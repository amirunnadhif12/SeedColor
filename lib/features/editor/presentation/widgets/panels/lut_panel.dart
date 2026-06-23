import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:seed_color/app/theme/app_colors.dart';
import 'package:seed_color/core/widgets/seed_slider.dart';
import 'package:seed_color/features/editor/domain/entities/edit_parameters.dart';
import 'package:seed_color/features/editor/data/datasources/lut_parser.dart';

class LutPanel extends StatefulWidget {
  final EditParameters parameters;
  final void Function({String? lutPath, required double lutIntensity, required double lutSize}) onLutChanged;

  const LutPanel({
    super.key,
    required this.parameters,
    required this.onLutChanged,
  });

  @override
  State<LutPanel> createState() => _LutPanelState();
}

class _LutPanelState extends State<LutPanel> {
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _importLutPath(String path) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final file = File(path);
      if (!await file.exists()) {
        throw Exception('Berkas LUT tidak ditemukan.');
      }
      
      // Parse file to get size and validate content
      final lutData = await LutParser.parse(path);
      
      widget.onLutChanged(
        lutPath: path,
        lutSize: lutData.size.toDouble(),
        lutIntensity: widget.parameters.lutIntensity,
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat LUT: ${e.toString().replaceAll('Exception:', '').trim()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showImportDialog(BuildContext context) {
    final controller = TextEditingController(text: widget.parameters.lutPath ?? '');
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E2E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Impor 3D LUT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Masukkan path absolut berkas .cube atau .3dl:',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: controller,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Misal: C:/Luts/vintage.cube',
                  hintStyle: TextStyle(color: Colors.white30, fontSize: 13),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal', style: TextStyle(color: Colors.white70)),
            ),
            TextButton(
              onPressed: () {
                final path = controller.text.trim();
                if (path.isNotEmpty) {
                  _importLutPath(path);
                }
                Navigator.pop(dialogContext);
              },
              child: const Text('Impor', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final lutPath = widget.parameters.lutPath;
    final hasLut = lutPath != null && widget.parameters.lutSize > 0.0;

    return Container(
      constraints: const BoxConstraints(maxHeight: 220),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            )
          else if (!hasLut)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _showImportDialog(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.file_open_rounded),
                      label: const Text('Muat berkas LUT (.cube/.3dl)', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.error, fontSize: 12),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView(
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  Row(
                    children: [
                      const Icon(Icons.table_chart_rounded, color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.basename(lutPath),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Ukuran Grid: ${widget.parameters.lutSize.toInt()}³',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: () => _showImportDialog(context),
                        icon: const Icon(Icons.edit_rounded, size: 16, color: Colors.white70),
                        label: const Text('Ganti', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ),
                      IconButton(
                        onPressed: () {
                          widget.onLutChanged(
                            lutPath: null,
                            lutSize: 0.0,
                            lutIntensity: 1.0,
                          );
                        },
                        icon: const Icon(Icons.close_rounded, color: AppColors.error, size: 20),
                        tooltip: 'Hapus LUT',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SeedSlider(
                    label: 'Intensitas',
                    value: widget.parameters.lutIntensity * 100.0,
                    min: 0.0,
                    max: 100.0,
                    onChanged: (val) {
                      widget.onLutChanged(
                        lutPath: lutPath,
                        lutSize: widget.parameters.lutSize,
                        lutIntensity: val / 100.0,
                      );
                    },
                    onChangeEnd: (val) {},
                    accentColor: AppColors.primary,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
