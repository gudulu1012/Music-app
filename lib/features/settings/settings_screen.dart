import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth/auth_service.dart';
import '../../shared/theme/sonora_colors.dart';
import '../../shared/theme/theme_provider.dart';

/// Settings screen with theme selector, playback, and account settings.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    final auth = context.watch<AuthService>();
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Text(
                  'Settings',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // ─── Theme Section ─────────────────────────────
          SliverToBoxAdapter(
            child: _SectionTitle(title: 'THEME'),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: SonoraColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: SonoraColors.surfaceBorder.withAlpha(40),
                    width: 0.5,
                  ),
                ),
                child: Column(
                  children: SonoraColors.presets.map((preset) {
                    final isSelected =
                        themeProvider.currentTheme == preset.type;
                    return _ThemePresetTile(
                      preset: preset,
                      isSelected: isSelected,
                      onTap: () => themeProvider.setTheme(preset.type),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // ─── Playback Section ──────────────────────────
          SliverToBoxAdapter(
            child: _SectionTitle(title: 'PLAYBACK'),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: SonoraColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: SonoraColors.surfaceBorder.withAlpha(40),
                    width: 0.5,
                  ),
                ),
                child: Column(
                  children: [
                    _SettingsSwitch(
                      icon: Icons.graphic_eq_rounded,
                      title: 'Auto-play',
                      subtitle: 'Automatically play similar songs',
                      value: true,
                      accent: accent,
                      onChanged: (_) {},
                    ),
                    _SettingsDivider(),
                    _SettingsSwitch(
                      icon: Icons.compare_arrows_rounded,
                      title: 'Crossfade',
                      subtitle: 'Smooth transition between songs',
                      value: false,
                      accent: accent,
                      onChanged: (_) {},
                    ),
                    _SettingsDivider(),
                    _SettingsSwitch(
                      icon: Icons.explicit_rounded,
                      title: 'Explicit Content',
                      subtitle: 'Show explicit content in results',
                      value: true,
                      accent: accent,
                      onChanged: (_) {},
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // ─── Audio Quality Section ─────────────────────
          SliverToBoxAdapter(
            child: _SectionTitle(title: 'AUDIO QUALITY'),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: SonoraColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: SonoraColors.surfaceBorder.withAlpha(40),
                    width: 0.5,
                  ),
                ),
                child: Column(
                  children: [
                    _SettingsNavTile(
                      icon: Icons.headphones_rounded,
                      title: 'Streaming Quality',
                      subtitle: 'High',
                      onTap: () {},
                    ),
                    _SettingsDivider(),
                    _SettingsNavTile(
                      icon: Icons.download_rounded,
                      title: 'Download Quality',
                      subtitle: 'High',
                      onTap: () {},
                    ),
                    _SettingsDivider(),
                    _SettingsSwitch(
                      icon: Icons.wifi_rounded,
                      title: 'Download over Wi-Fi only',
                      subtitle: 'Save mobile data',
                      value: true,
                      accent: accent,
                      onChanged: (_) {},
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // ─── Account Section ───────────────────────────
          SliverToBoxAdapter(
            child: _SectionTitle(title: 'ACCOUNT'),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: SonoraColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: SonoraColors.surfaceBorder.withAlpha(40),
                    width: 0.5,
                  ),
                ),
                child: Column(
                  children: [
                    _SettingsNavTile(
                      icon: Icons.person_outline_rounded,
                      title: 'Profile',
                      subtitle: auth.currentUser?.email ?? 'Not signed in',
                      onTap: () {},
                    ),
                    _SettingsDivider(),
                    _SettingsNavTile(
                      icon: Icons.info_outline_rounded,
                      title: 'About',
                      subtitle: 'Sonora v1.0.0',
                      onTap: () {},
                    ),
                    _SettingsDivider(),
                    Material(
                      color: Colors.transparent,
                      child: ListTile(
                        leading: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: SonoraColors.error.withAlpha(15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.logout_rounded,
                              color: SonoraColors.error, size: 18),
                        ),
                        title: Text(
                          'Sign Out',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: SonoraColors.error,
                          ),
                        ),
                        onTap: () => auth.signOut(),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
    );
  }
}

// ─── Section Title ───────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              letterSpacing: 1.2,
              color: SonoraColors.textTertiary,
              fontSize: 11,
            ),
      ),
    );
  }
}

// ─── Theme Preset Tile ───────────────────────────────────────

class _ThemePresetTile extends StatelessWidget {
  final SonoraThemePreset preset;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemePresetTile({
    required this.preset,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Color swatch
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: preset.primary,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: preset.primary.withAlpha(80),
                            blurRadius: 12,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                child: isSelected
                    ? const Icon(Icons.check_rounded,
                        color: Colors.white, size: 18)
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      preset.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      preset.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: SonoraColors.textTertiary,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.circle, color: preset.primary, size: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Settings Switch ─────────────────────────────────────────

class _SettingsSwitch extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final Color accent;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitch({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.accent,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: SonoraColors.surfaceElevated,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: SonoraColors.textSecondary, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleSmall),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: SonoraColors.textTertiary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

// ─── Settings Nav Tile ───────────────────────────────────────

class _SettingsNavTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsNavTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: SonoraColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: SonoraColors.textSecondary, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleSmall),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: SonoraColors.textTertiary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: SonoraColors.textTertiary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Settings Divider ────────────────────────────────────────

class _SettingsDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 0.5,
        color: SonoraColors.surfaceBorder.withAlpha(40),
      ),
    );
  }
}
