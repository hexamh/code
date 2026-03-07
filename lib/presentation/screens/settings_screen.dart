import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/core/constants.dart';
import 'package:myapp/core/extensions.dart';
import 'package:myapp/data/models/editor_settings.dart';
import 'package:myapp/domain/editor_themes.dart';
import 'package:myapp/presentation/providers/settings_providers.dart';
import 'package:myapp/presentation/widgets/editor_theme_picker.dart';

/// Settings screen with all editor configuration options.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (settings) => ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            // === Appearance ===
            _SectionHeader(title: 'Appearance'),
            _SettingsTile(
              icon: Icons.palette_outlined,
              title: 'App Theme',
              subtitle: _themeModeLabel(settings.themeMode),
              onTap: () => _showThemePicker(context, ref, settings),
            ),
            _SettingsTile(
              icon: Icons.color_lens_outlined,
              title: 'Editor Theme',
              subtitle: settings.editorTheme.displayName,
              onTap: () => EditorThemePicker.show(
                context,
                currentTheme: settings.editorTheme,
                onThemeSelected: (theme) {
                  ref.read(settingsProvider.notifier).setEditorTheme(theme);
                },
              ),
            ),

            const Divider(indent: 16, endIndent: 16),

            // === Editor ===
            _SectionHeader(title: 'Editor'),
            _SettingsTile(
              icon: Icons.format_size,
              title: 'Font Size',
              subtitle: '${settings.fontSize.toInt()} px',
              trailing: SizedBox(
                width: 180,
                child: Slider(
                  value: settings.fontSize,
                  min: AppConstants.minFontSize,
                  max: AppConstants.maxFontSize,
                  divisions:
                      (AppConstants.maxFontSize - AppConstants.minFontSize)
                          .toInt(),
                  label: '${settings.fontSize.toInt()}',
                  onChanged: (value) {
                    ref
                        .read(settingsProvider.notifier)
                        .setFontSize(value.roundToDouble());
                  },
                ),
              ),
            ),
            _SettingsTile(
              icon: Icons.font_download_outlined,
              title: 'Font Family',
              subtitle: settings.fontFamily,
              onTap: () => _showFontPicker(context, ref, settings),
            ),
            _SettingsTile(
              icon: Icons.keyboard_tab,
              title: 'Tab Width',
              subtitle: '${settings.tabWidth} spaces',
              trailing: SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 2, label: Text('2')),
                  ButtonSegment(value: 4, label: Text('4')),
                  ButtonSegment(value: 8, label: Text('8')),
                ],
                selected: {settings.tabWidth},
                onSelectionChanged: (value) {
                  ref
                      .read(settingsProvider.notifier)
                      .setTabWidth(value.first);
                },
                style: const ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),

            const Divider(indent: 16, endIndent: 16),

            // === Features ===
            _SectionHeader(title: 'Features'),
            _SwitchTile(
              icon: Icons.wrap_text,
              title: 'Word Wrap',
              subtitle: 'Wrap long lines to fit the screen',
              value: settings.wordWrap,
              onChanged: (_) =>
                  ref.read(settingsProvider.notifier).toggleWordWrap(),
            ),
            _SwitchTile(
              icon: Icons.format_list_numbered,
              title: 'Line Numbers',
              subtitle: 'Show line numbers in the gutter',
              value: settings.showLineNumbers,
              onChanged: (_) =>
                  ref.read(settingsProvider.notifier).toggleLineNumbers(),
            ),
            _SwitchTile(
              icon: Icons.map_outlined,
              title: 'Minimap',
              subtitle: 'Show scroll overview on the right edge',
              value: settings.showMinimap,
              onChanged: (_) =>
                  ref.read(settingsProvider.notifier).toggleMinimap(),
            ),
            _SwitchTile(
              icon: Icons.format_indent_increase,
              title: 'Auto Indent',
              subtitle: 'Automatically indent new lines',
              value: settings.autoIndent,
              onChanged: (_) =>
                  ref.read(settingsProvider.notifier).toggleAutoIndent(),
            ),

            const Divider(indent: 16, endIndent: 16),

            // === Auto-save ===
            _SectionHeader(title: 'Auto Save'),
            _SwitchTile(
              icon: Icons.save,
              title: 'Auto Save',
              subtitle: 'Automatically save files periodically',
              value: settings.autoSaveEnabled,
              onChanged: (val) =>
                  ref.read(settingsProvider.notifier).setAutoSave(val),
            ),
            if (settings.autoSaveEnabled)
              _SettingsTile(
                icon: Icons.timer_outlined,
                title: 'Save Interval',
                subtitle: '${settings.autoSaveIntervalSeconds} seconds',
                trailing: SizedBox(
                  width: 180,
                  child: Slider(
                    value: settings.autoSaveIntervalSeconds.toDouble(),
                    min: 10,
                    max: 120,
                    divisions: 11,
                    label: '${settings.autoSaveIntervalSeconds}s',
                    onChanged: (value) {
                      ref
                          .read(settingsProvider.notifier)
                          .setAutoSaveInterval(value.toInt());
                    },
                  ),
                ),
              ),

            const Divider(indent: 16, endIndent: 16),

            // === About ===
            _SectionHeader(title: 'About'),
            _SettingsTile(
              icon: Icons.info_outline,
              title: AppConstants.appName,
              subtitle: 'Version ${AppConstants.appVersion}',
            ),
            _SettingsTile(
              icon: Icons.touch_app,
              title: 'Gestures',
              subtitle: 'Pinch to zoom font size in editor',
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  String _themeModeLabel(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => 'Light',
      ThemeMode.dark => 'Dark',
      ThemeMode.system => 'System Default',
    };
  }

  void _showThemePicker(
      BuildContext context, WidgetRef ref, EditorSettings settings) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('App Theme',
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            for (final mode in ThemeMode.values)
              RadioListTile<ThemeMode>(
                title: Text(_themeModeLabel(mode)),
                value: mode,
                groupValue: settings.themeMode,
                onChanged: (value) {
                  if (value != null) {
                    ref.read(settingsProvider.notifier).setThemeMode(value);
                  }
                  Navigator.pop(ctx);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showFontPicker(
      BuildContext context, WidgetRef ref, EditorSettings settings) {
    final fonts = [
      'JetBrains Mono',
      'Fira Code',
      'Source Code Pro',
      'Roboto Mono',
      'Ubuntu Mono',
      'Inconsolata',
    ];

    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Font Family',
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            for (final font in fonts)
              RadioListTile<String>(
                title: Text(
                  font,
                  style: GoogleFonts.getFont(font.replaceAll(' ', '')).copyWith(
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  'The quick brown fox jumps',
                  style: GoogleFonts.getFont(font.replaceAll(' ', '')).copyWith(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                value: font,
                groupValue: settings.fontFamily,
                onChanged: (value) {
                  if (value != null) {
                    ref.read(settingsProvider.notifier).setFontFamily(value);
                  }
                  Navigator.pop(ctx);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: context.textTheme.titleSmall?.copyWith(
          color: context.colorScheme.primary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: context.colorScheme.onSurfaceVariant),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: trailing,
      onTap: onTap,
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Icon(icon, color: context.colorScheme.onSurfaceVariant),
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }
}
