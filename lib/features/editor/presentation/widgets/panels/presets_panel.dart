import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../app/di/injection.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_typography.dart';
import '../../../../presets/presentation/bloc/presets_bloc.dart';
import '../../../../presets/presentation/bloc/presets_event.dart';
import '../../../../presets/presentation/bloc/presets_state.dart';
import '../../../domain/entities/edit_parameters.dart';
import '../../bloc/editor_bloc.dart';
import '../../bloc/editor_event.dart';

class PresetsPanel extends StatefulWidget {
  final EditParameters currentParameters;

  const PresetsPanel({super.key, required this.currentParameters});

  @override
  State<PresetsPanel> createState() => _PresetsPanelState();
}

class _PresetsPanelState extends State<PresetsPanel> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PresetsBloc>(
      create: (context) => sl<PresetsBloc>()..add(LoadPresets()),
      child: BlocConsumer<PresetsBloc, PresetsState>(
        listener: (context, state) {
          if (state is PresetsLoaded && state.message != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message!),
                backgroundColor: AppColors.primary,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is PresetsLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }

          if (state is PresetsLoaded) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top controls: Category Tabs + Save button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TabBar(
                          controller: _tabController,
                          labelColor: AppColors.textPrimary,
                          unselectedLabelColor: AppColors.textTertiary,
                          indicatorColor: AppColors.primary,
                          indicatorWeight: 2,
                          dividerColor: Colors.transparent,
                          labelStyle: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.bold),
                          tabs: const [
                            Tab(text: 'Recommended'),
                            Tab(text: 'Premium'),
                            Tab(text: 'Yours'),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Save Preset Button
                      IconButton(
                        icon: const Icon(Icons.bookmark_add_rounded, color: AppColors.primary),
                        onPressed: () => _showSavePresetDialog(context),
                        tooltip: 'Save Custom Preset',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Horizontal list of presets
                SizedBox(
                  height: 110,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildPresetList(context, state.recommended),
                      _buildPresetList(context, state.premium),
                      _buildPresetList(context, state.yours, isYours: true),
                    ],
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildPresetList(BuildContext context, List<dynamic> presets, {bool isYours = false}) {
    if (presets.isEmpty) {
      return Center(
        child: Text(
          isYours ? 'No custom presets yet.' : 'No presets available.',
          style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary),
        ),
      );
    }

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: presets.length,
      itemBuilder: (listContext, index) {
        final preset = presets[index];
        return GestureDetector(
          onTap: () {
            // Apply preset parameters to editor BLoC
            context.read<EditorBloc>().add(ApplyPreset(preset.parameters));
          },
          child: Container(
            width: 85,
            margin: const EdgeInsets.only(right: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Visual Gradient Thumbnail
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: _getGradientForPreset(preset.name),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                        width: 0.5,
                      ),
                    ),
                    child: const Center(
                      child: Icon(Icons.style_outlined, color: Colors.white24, size: 20),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                // Preset Name
                Text(
                  preset.name,
                  style: AppTypography.labelSmall.copyWith(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  LinearGradient _getGradientForPreset(String name) {
    if (name.contains('Cinema')) {
      return const LinearGradient(
        colors: [Color(0xFFE5A93B), Color(0xFF2A52BE)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    if (name.contains('Teal')) {
      return const LinearGradient(
        colors: [Color(0xFF008080), Color(0xFFFF7F50)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    if (name.contains('Warm')) {
      return const LinearGradient(
        colors: [Color(0xFFFFB347), Color(0xFFFFCC33)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    if (name.contains('Moody') || name.contains('Dark')) {
      return const LinearGradient(
        colors: [Color(0xFF1F1F1F), Color(0xFF000000)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    if (name.contains('B&W') || name.contains('Monochrome')) {
      return const LinearGradient(
        colors: [Color(0xFF7F7F7F), Color(0xFF1A1A1A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    return const LinearGradient(
      colors: [Color(0xFF0A84FF), Color(0xFFBC8CFF)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  void _showSavePresetDialog(BuildContext parentContext) {
    final controller = TextEditingController();
    showDialog(
      context: parentContext,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E2E),
          title: const Text('Save Custom Preset', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Enter preset name',
              hintStyle: TextStyle(color: Colors.white30),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white24),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            TextButton(
              onPressed: () {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  parentContext.read<PresetsBloc>().add(
                        SaveCurrentPreset(
                          name: name,
                          parameters: widget.currentParameters,
                        ),
                      );
                }
                Navigator.pop(dialogContext);
              },
              child: const Text('Save', style: TextStyle(color: AppColors.primary)),
            ),
          ],
        );
      },
    );
  }
}
