import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '/core/design_system/app_design_system.dart';
import '/features/auth/data/repositories/auth_repository.dart';
import '/features/auth/domain/models/organization.dart';
import '/features/auth/presentation/providers/auth_providers.dart';

class AdminOrganizationsScreen extends ConsumerWidget {
  const AdminOrganizationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final bg = isDark ? AppColors.backgroundDark : AppColors.background;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surface;
    final border = isDark ? AppColors.borderDark : AppColors.border;
    final fontFamily = GoogleFonts.outfit().fontFamily ?? 'outfit';
    final orgsAsync = ref.watch(organizationsProvider);

    return Scaffold(
      backgroundColor: bg,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await showDialog<bool>(
            context: context,
            builder: (_) => const _OrgFormDialog(),
          );
          if (created == true) ref.invalidate(organizationsProvider);
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Organization'),
      ),
      body: SafeArea(
        child: MaxWidthContainer(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                title: Text('Organizations', style: TextStyle(color: textPrimary, fontFamily: fontFamily, fontWeight: FontWeight.bold, fontSize: 22)),
                floating: true, snap: true, centerTitle: false,
              ),
              orgsAsync.when(
                data: (orgs) {
                  if (orgs.isEmpty) {
                    return SliverFillRemaining(hasScrollBody: false, child: Center(
                      child: Text('No organizations.', style: TextStyle(color: textSecondary)),
                    ));
                  }
                  return SliverList(
                    delegate: SliverChildBuilderDelegate((context, i) {
                      final org = orgs[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (_) => _OrgDetailDialog(org: org),
                              ).then((_) => ref.invalidate(organizationsProvider));
                            },
                            borderRadius: AppRadius.roundedMd,
                            child: Container(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(color: surface, borderRadius: AppRadius.roundedMd, border: Border.all(color: border)),
                              child: Row(children: [
                                Container(
                                  width: 44, height: 44,
                                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: AppRadius.roundedSm),
                                  child: const Icon(Icons.business_rounded, color: AppColors.primary),
                                ),
                                const SizedBox(width: 12),
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(org.name, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: textPrimary, fontFamily: fontFamily)),
                                  const SizedBox(height: 2),
                                  Row(children: [
                                    if (org.code != null) ...[
                                      Text(org.code!, style: TextStyle(fontSize: 12, color: textSecondary, fontFamily: fontFamily)),
                                      Text(' · ', style: TextStyle(fontSize: 12, color: textSecondary)),
                                    ],
                                    Text(org.id.length > 8 ? '${org.id.substring(0, 8)}...' : org.id,
                                      style: TextStyle(fontSize: 12, color: textSecondary, fontFamily: fontFamily)),
                                  ]),
                                  if (org.createdAt != null)
                                    Text('Created: ${DateFormat.yMMMd().format(org.createdAt!)}',
                                      style: TextStyle(fontSize: 12, color: textSecondary, fontFamily: fontFamily)),
                                ])),
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.primary),
                                  padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                                  onPressed: () async {
                                    final updated = await showDialog<bool>(
                                      context: context,
                                      builder: (_) => _OrgFormDialog(org: org),
                                    );
                                    if (updated == true) ref.invalidate(organizationsProvider);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Colors.redAccent),
                                  padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                                  onPressed: () async {
                                    final confirmed = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Delete Organization'),
                                        content: Text('Delete "${org.name}"?'),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                          TextButton(onPressed: () => Navigator.pop(ctx, true), style: TextButton.styleFrom(foregroundColor: Colors.red), child: const Text('Delete')),
                                        ],
                                      ),
                                    );
                                    if (confirmed != true || !context.mounted) return;
                                    try {
                                      await ref.read(authRepositoryProvider).deleteOrganization(org.id);
                                      if (context.mounted) {
                                        ref.invalidate(organizationsProvider);
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                          content: Text('${org.name} deleted.'),
                                          backgroundColor: Colors.green, behavior: SnackBarBehavior.floating,
                                        ));
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                          content: Text(e.toString().replaceFirst('Exception: ', '')),
                                          backgroundColor: AppColors.accent, behavior: SnackBarBehavior.floating,
                                        ));
                                      }
                                    }
                                  },
                                ),
                              ]),
                            ),
                          ),
                        ),
                      );
                    }, childCount: orgs.length),
                  );
                },
                loading: () => const SliverFillRemaining(hasScrollBody: false, child: Center(child: CircularProgressIndicator())),
                error: (_, _) => SliverFillRemaining(hasScrollBody: false, child: Center(child: Text('Could not load organizations.', style: TextStyle(color: textSecondary)))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrgFormDialog extends ConsumerStatefulWidget {
  final Organization? org;
  const _OrgFormDialog({this.org});

  @override
  ConsumerState<_OrgFormDialog> createState() => _OrgFormDialogState();
}

class _OrgFormDialogState extends ConsumerState<_OrgFormDialog> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _codeCtrl;
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.org?.name ?? '');
    _codeCtrl = TextEditingController(text: widget.org?.code ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final repo = ref.read(authRepositoryProvider);
      if (widget.org != null) {
        await repo.updateOrganization(widget.org!.id, _nameCtrl.text.trim(), _codeCtrl.text.trim().nullIfEmpty);
      } else {
        await repo.createOrganization(_nameCtrl.text.trim(), _codeCtrl.text.trim().nullIfEmpty);
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.accent, behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return MaxWidthContainer(
      maxWidth: 500,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Dialog(
          backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedLg),
          insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.md),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(children: [
                    Icon(widget.org != null ? Icons.edit_rounded : Icons.add_rounded, color: AppColors.primary),
                    const SizedBox(width: AppSpacing.sm),
                    Text(widget.org != null ? 'Edit Organization' : 'Add Organization',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: textPrimary)),
                  ]),
                  const SizedBox(height: AppSpacing.lg),
                  _Field(label: 'Organization Name', controller: _nameCtrl, hint: 'e.g. Dhaka Clinic', icon: Icons.business_rounded,
                    validator: (v) => v?.isEmpty ?? true ? 'Required' : null),
                  const SizedBox(height: AppSpacing.md),
                  _Field(label: 'Code', controller: _codeCtrl, hint: 'e.g. DHC', icon: Icons.code_rounded),
                  if (widget.org != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : Colors.grey.shade50,
                        borderRadius: AppRadius.roundedSm,
                        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('ID: ${widget.org!.id}', style: TextStyle(fontSize: 12, color: textSecondary)),
                        if (widget.org!.createdAt != null)
                          const SizedBox(height: 4),
                        if (widget.org!.createdAt != null)
                          Text('Created: ${DateFormat.yMMMd().format(widget.org!.createdAt!)}',
                            style: TextStyle(fontSize: 12, color: textSecondary)),
                      ]),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    TextButton(onPressed: _loading ? null : () => Navigator.of(context).pop(),
                      child: Text('Cancel', style: TextStyle(color: textPrimary))),
                    const SizedBox(width: AppSpacing.md),
                    ElevatedButton(onPressed: _loading ? null : _submit,
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white,
                        minimumSize: const Size(120, 48), shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedMd)),
                      child: _loading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text(widget.org != null ? 'Save' : 'Create'),
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OrgDetailDialog extends ConsumerStatefulWidget {
  final Organization org;
  const _OrgDetailDialog({required this.org});

  @override
  ConsumerState<_OrgDetailDialog> createState() => _OrgDetailDialogState();
}

class _OrgDetailDialogState extends ConsumerState<_OrgDetailDialog> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _codeCtrl;
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.org.name);
    _codeCtrl = TextEditingController(text: widget.org.code ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveOrg() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(authRepositoryProvider).updateOrganization(
        widget.org.id, _nameCtrl.text.trim(), _codeCtrl.text.trim().nullIfEmpty,
      );
      if (mounted) setState(() => _loading = false);
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.accent, behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surface;
    final border = isDark ? AppColors.borderDark : AppColors.border;

    return MaxWidthContainer(
      maxWidth: 500,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Dialog(
          backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedLg),
          insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.md),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(children: [
                    const Icon(Icons.business_rounded, color: AppColors.primary),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(child: Text(widget.org.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: textPrimary))),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: textSecondary),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ]),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(color: surface, borderRadius: AppRadius.roundedMd, border: Border.all(color: border)),
                    child: Column(children: [
                      _Field(label: 'Organization Name', controller: _nameCtrl, hint: 'e.g. Dhaka Clinic', icon: Icons.business_rounded,
                        validator: (v) => v?.isEmpty ?? true ? 'Required' : null),
                      const SizedBox(height: AppSpacing.md),
                      _Field(label: 'Code', controller: _codeCtrl, hint: 'e.g. DHC', icon: Icons.code_rounded),
                      const SizedBox(height: AppSpacing.sm),
                      Row(children: [
                        Text('ID: ${widget.org.id}', style: TextStyle(fontSize: 12, color: textSecondary)),
                        const Spacer(),
                        if (_nameCtrl.text != widget.org.name || _codeCtrl.text != (widget.org.code ?? ''))
                          TextButton(
                            onPressed: _loading ? null : _saveOrg,
                            child: _loading
                              ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                              : Text('Save', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                          ),
                      ]),
                    ]),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final String? Function(String?)? validator;
  const _Field({required this.label, required this.controller, required this.hint, required this.icon, this.validator});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
      const SizedBox(height: 8),
      TextFormField(
        controller: controller, validator: validator,
        style: TextStyle(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, size: 20, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          hintStyle: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
          border: OutlineInputBorder(borderRadius: AppRadius.roundedSm, borderSide: BorderSide(color: isDark ? AppColors.borderDark : AppColors.border)),
          enabledBorder: OutlineInputBorder(borderRadius: AppRadius.roundedSm, borderSide: BorderSide(color: isDark ? AppColors.borderDark : AppColors.border)),
        ),
      ),
    ]);
  }
}

extension on String {
  String? get nullIfEmpty => isEmpty ? null : this;
}
