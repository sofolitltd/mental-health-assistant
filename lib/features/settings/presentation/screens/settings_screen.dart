import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '/core/design_system/app_design_system.dart';
import '/core/theme/theme_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/features/auth/presentation/providers/auth_providers.dart';
import '/features/auth/domain/models/auth_state.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: MaxWidthContainer(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                title: Text(
                  'Settings',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontFamily: GoogleFonts.outfit().fontFamily,
                  ),
                ),
                floating: true,
                snap: true,
                centerTitle: false,
              ),
              SliverToBoxAdapter(child: _ProfileCard(authState: authState)),
              SliverToBoxAdapter(child: _SectionHeader(title: 'Appearance')),
              SliverToBoxAdapter(child: _ThemeSection(ref: ref)),
              SliverToBoxAdapter(child: _SectionHeader(title: 'MHpss Basics')),
              SliverToBoxAdapter(child: _SupportSection()),
              SliverToBoxAdapter(child: const SizedBox(height: AppSpacing.lg)),
              SliverToBoxAdapter(child: _SignOutSection(ref: ref)),
              SliverToBoxAdapter(child: const SizedBox(height: AppSpacing.xxl)),
              SliverToBoxAdapter(child: _VersionInfo()),
              SliverToBoxAdapter(child: const SizedBox(height: AppSpacing.xxl)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Profile Card ──────────────────────────────────────────────────────────

class _ProfileCard extends StatelessWidget {
  final AuthState authState;

  const _ProfileCard({required this.authState});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final joined = authState.joinedAt != null
        ? DateFormat('MMM dd, yyyy').format(authState.joinedAt!)
        : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.lg,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: AppRadius.roundedMd,
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: AppColors.primary,
                    size: 30,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        authState.name ?? 'User',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        authState.designation ?? '',
                        style: TextStyle(
                          fontSize: 13,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Material(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: AppRadius.roundedSm,
                  child: InkWell(
                    borderRadius: AppRadius.roundedSm,
                    onTap: () => _showEditDialog(context),
                    child: const Padding(
                      padding: EdgeInsets.all(AppSpacing.sm),
                      child: Icon(
                        Icons.edit_outlined,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Divider(height: 1, color: colors.outlineVariant),
            const SizedBox(height: AppSpacing.sm),
            _ProfileRow(
              label: 'Employee ID',
              value: authState.employeeId ?? '—',
            ),
            const SizedBox(height: AppSpacing.sm),
            _ProfileRow(label: 'Mobile', value: authState.phone ?? '—'),
            const SizedBox(height: AppSpacing.sm),
            _ProfileRow(label: 'Email', value: authState.email ?? '—'),
            if (joined != null) ...[
              const SizedBox(height: AppSpacing.sm),
              _ProfileRow(label: 'Joined', value: joined),
            ],
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => _EditProfileDialog(authState: authState),
    );
  }
}

class _EditProfileDialog extends ConsumerStatefulWidget {
  final AuthState authState;

  const _EditProfileDialog({required this.authState});

  @override
  ConsumerState<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends ConsumerState<_EditProfileDialog> {
  late final TextEditingController _nameCtl;
  late final TextEditingController _empCtl;
  late final TextEditingController _desigCtl;
  late final TextEditingController _phoneCtl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtl = TextEditingController(text: widget.authState.name);
    _empCtl = TextEditingController(text: widget.authState.employeeId);
    _desigCtl = TextEditingController(text: widget.authState.designation);
    _phoneCtl = TextEditingController(text: widget.authState.phone);
  }

  @override
  void dispose() {
    _nameCtl.dispose();
    _empCtl.dispose();
    _desigCtl.dispose();
    _phoneCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Text('Edit Profile', style: TextStyle(color: colors.onSurface)),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameCtl,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _empCtl,
                decoration: const InputDecoration(
                  labelText: 'Employee ID',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _desigCtl,
                decoration: const InputDecoration(
                  labelText: 'Designation',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _phoneCtl,
                decoration: const InputDecoration(
                  labelText: 'Mobile',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: TextEditingController(text: widget.authState.email),
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: colors.surfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Save'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final uid = widget.authState.uid;
    if (uid == null) return;

    await FirebaseFirestore.instance.collection('counselors').doc(uid).update({
      'name': _nameCtl.text.trim(),
      'employeeId': _empCtl.text.trim(),
      'designation': _desigCtl.text.trim(),
      'phone': _phoneCtl.text.trim(),
    });

    ref
        .read(authProvider.notifier)
        .updateProfile(
          name: _nameCtl.text.trim(),
          employeeId: _empCtl.text.trim(),
          designation: _desigCtl.text.trim(),
          phone: _phoneCtl.text.trim(),
        );

    if (mounted) Navigator.pop(context);
  }
}

class _ProfileRow extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: colors.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Theme Section ─────────────────────────────────────────────────────────

class _ThemeSection extends StatelessWidget {
  final WidgetRef ref;

  const _ThemeSection({required this.ref});

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider).asData?.value ?? ThemeMode.system;

    return _SettingsCard(
      child: Column(
        children: [
          _ThemeOption(
            title: 'System Default',
            icon: Icons.brightness_auto_rounded,
            isSelected: themeMode == ThemeMode.system,
            onTap: () => ref
                .read(themeModeProvider.notifier)
                .setThemeMode(ThemeMode.system),
          ),
          const Divider(height: 1, indent: 56),
          _ThemeOption(
            title: 'Light Mode',
            icon: Icons.light_mode_rounded,
            isSelected: themeMode == ThemeMode.light,
            onTap: () => ref
                .read(themeModeProvider.notifier)
                .setThemeMode(ThemeMode.light),
          ),
          const Divider(height: 1, indent: 56),
          _ThemeOption(
            title: 'Dark Mode',
            icon: Icons.dark_mode_rounded,
            isSelected: themeMode == ThemeMode.dark,
            onTap: () => ref
                .read(themeModeProvider.notifier)
                .setThemeMode(ThemeMode.dark),
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.primary : colors.onSurfaceVariant,
        size: 24,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? AppColors.primary : colors.onSurface,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        ),
      ),
      trailing: isSelected
          ? const Icon(
              Icons.check_circle_rounded,
              color: AppColors.primary,
              size: 22,
            )
          : null,
      onTap: onTap,
    );
  }
}

// ─── Support Section ───────────────────────────────────────────────────────

class _SupportSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      child: Column(
        children: [
          _SettingsListTile(
            title: 'MHPSS Basics',
            icon: Icons.help_center_outlined,
            onTap: () => context.go('/settings/mhpss-basics'),
          ),
          const Divider(height: 1, indent: 56),
          _SettingsListTile(
            title: 'Privacy & Security',
            icon: Icons.security_rounded,
            onTap: () => context.go('/settings/privacy'),
          ),
        ],
      ),
    );
  }
}

// ─── Sign Out ──────────────────────────────────────────────────────────────

class _SignOutSection extends StatelessWidget {
  final WidgetRef ref;

  const _SignOutSection({required this.ref});

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      child: _SettingsListTile(
        title: 'Sign Out',
        icon: Icons.logout_rounded,
        iconColor: AppColors.accent,
        textColor: AppColors.accent,
        onTap: () {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text(
                'Sign Out',
                style: TextStyle(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
              ),
              content: Text(
                'Are you sure you want to log out of your session?',
                style: TextStyle(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ref.read(authProvider.notifier).logout();
                  },
                  child: const Text(
                    'Sign Out',
                    style: TextStyle(color: AppColors.accent),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Version Info ──────────────────────────────────────────────────────────

class _VersionInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        children: [
          Text(
            'Mental Health Assistant',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Version 1.0.0 (Build 2026.1.0)',
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// ─── Reusable Components ───────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.sm,
      ),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: colors.onSurfaceVariant,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final Widget child;
  const _SettingsCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: AppRadius.roundedMd,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: AppRadius.roundedMd,
        child: Material(color: Colors.transparent, child: child),
      ),
    );
  }
}

class _SettingsListTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;

  const _SettingsListTile({
    required this.title,
    required this.icon,
    required this.onTap,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? colors.onSurfaceVariant,
        size: 24,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? colors.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: colors.onSurfaceVariant,
        size: 20,
      ),
      onTap: onTap,
    );
  }
}
