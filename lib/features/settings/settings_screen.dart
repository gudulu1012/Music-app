import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth/auth_service.dart';
import '../../app/theme/app_theme.dart';

/// Settings screen — user preferences, account, and app configuration.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AuthService>();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            title: Text('Settings', style: theme.textTheme.headlineMedium),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                // ─── Account Section ────────────────────────
                _buildAccountCard(context, auth, theme),
                const SizedBox(height: 24),

                // ─── Playback ───────────────────────────────
                _SectionTitle(title: 'Playback'),
                _SettingsTile(
                  icon: Icons.graphic_eq_rounded,
                  title: 'Audio Quality',
                  subtitle: 'High',
                  onTap: () {},
                ),
                _SettingsTile(
                  icon: Icons.swap_horiz_rounded,
                  title: 'Crossfade',
                  subtitle: 'Off',
                  onTap: () {},
                ),
                _SettingsTile(
                  icon: Icons.skip_next_rounded,
                  title: 'Autoplay',
                  subtitle: 'Play similar songs when queue ends',
                  trailing: Switch(
                    value: true,
                    onChanged: (v) {},
                    activeColor: AppTheme.primaryPurple,
                  ),
                ),

                const SizedBox(height: 24),

                // ─── Appearance ─────────────────────────────
                _SectionTitle(title: 'Appearance'),
                _SettingsTile(
                  icon: Icons.dark_mode_rounded,
                  title: 'Dark Mode',
                  trailing: Switch(
                    value: true,
                    onChanged: (v) {},
                    activeColor: AppTheme.primaryPurple,
                  ),
                ),
                _SettingsTile(
                  icon: Icons.palette_rounded,
                  title: 'Accent Color',
                  subtitle: 'Purple',
                  onTap: () {},
                ),

                const SizedBox(height: 24),

                // ─── Downloads ──────────────────────────────
                _SectionTitle(title: 'Downloads'),
                _SettingsTile(
                  icon: Icons.wifi_rounded,
                  title: 'Download over Wi-Fi only',
                  trailing: Switch(
                    value: true,
                    onChanged: (v) {},
                    activeColor: AppTheme.primaryPurple,
                  ),
                ),
                _SettingsTile(
                  icon: Icons.storage_rounded,
                  title: 'Storage Used',
                  subtitle: '0 MB',
                  onTap: () {},
                ),
                _SettingsTile(
                  icon: Icons.delete_sweep_rounded,
                  title: 'Clear Downloads',
                  onTap: () {},
                ),

                const SizedBox(height: 24),

                // ─── About ──────────────────────────────────
                _SectionTitle(title: 'About'),
                _SettingsTile(
                  icon: Icons.info_outline_rounded,
                  title: 'Version',
                  subtitle: '1.0.0',
                ),
                _SettingsTile(
                  icon: Icons.description_outlined,
                  title: 'Licenses',
                  onTap: () {
                    showLicensePage(context: context);
                  },
                ),

                const SizedBox(height: 24),

                // Sign out
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => auth.signOut(),
                      icon: const Icon(Icons.logout_rounded,
                          color: Color(0xFFEF4444)),
                      label: const Text('Sign Out',
                          style: TextStyle(color: Color(0xFFEF4444))),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFEF4444)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 120),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountCard(
      BuildContext context, AuthService auth, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white24,
            child: Text(
              (auth.currentUser?.displayName ?? 'U')[0].toUpperCase(),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  auth.currentUser?.displayName ?? 'User',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
                Text(
                  auth.currentUser?.email ?? '',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_rounded, color: Colors.white70),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(),
          style: Theme.of(context)
              .textTheme
              .labelSmall
              ?.copyWith(letterSpacing: 1.2),
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: AppTheme.darkTextSecondary, size: 22),
      title: Text(title, style: theme.textTheme.titleSmall),
      subtitle: subtitle != null
          ? Text(subtitle!, style: theme.textTheme.bodySmall)
          : null,
      trailing: trailing ??
          (onTap != null
              ? const Icon(Icons.chevron_right_rounded,
                  color: AppTheme.darkTextTertiary)
              : null),
      onTap: onTap,
    );
  }
}
