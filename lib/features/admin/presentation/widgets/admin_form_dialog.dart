import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/design_system/app_design_system.dart';
import '/features/auth/data/repositories/auth_repository.dart';
import '/features/auth/presentation/providers/auth_providers.dart';

class AdminFormDialog extends ConsumerStatefulWidget {
  final Map<String, dynamic>? admin;
  final String? fixedOrgId;
  const AdminFormDialog({super.key, this.admin, this.fixedOrgId});

  @override
  ConsumerState<AdminFormDialog> createState() => _AdminFormDialogState();
}

class _AdminFormDialogState extends ConsumerState<AdminFormDialog> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _passwordCtrl;
  final _formKey = GlobalKey<FormState>();
  String? _orgId;
  String _role = 'admin';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.admin?['name'] as String? ?? '');
    _emailCtrl = TextEditingController(text: widget.admin?['email'] as String? ?? '');
    _passwordCtrl = TextEditingController();
    _orgId = widget.fixedOrgId ?? widget.admin?['organizationId'] as String?;
    _role = widget.admin?['role'] as String? ?? 'admin';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final repo = ref.read(authRepositoryProvider);
      final isEdit = widget.admin != null;
      if (isEdit) {
        await repo.updateAdmin(
          id: widget.admin!['id'] as String,
          name: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          organizationId: _orgId ?? '',
          role: _role,
        );
      } else {
        await repo.createAdmin(
          name: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text.trim(),
          organizationId: _orgId ?? '',
          role: _role,
        );
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
    final surface = isDark ? AppColors.surfaceDark : AppColors.surface;
    final border = isDark ? AppColors.borderDark : AppColors.border;
    final orgsAsync = ref.watch(organizationsProvider);
    final orgs = orgsAsync.asData?.value ?? [];
    final isEdit = widget.admin != null;

    return MaxWidthContainer(
      maxWidth: 500,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Dialog(
          backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedLg),
          insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.md),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(children: [
                      Icon(isEdit ? Icons.edit_rounded : Icons.person_add_alt_1_rounded, color: AppColors.primary),
                      const SizedBox(width: AppSpacing.sm),
                      Text(isEdit ? 'Edit Admin' : 'Add Admin',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: textPrimary)),
                    ]),
                    const SizedBox(height: AppSpacing.lg),
                    _Field(label: 'Name', controller: _nameCtrl, hint: 'e.g. Admin User', icon: Icons.person_outline,
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null),
                    const SizedBox(height: AppSpacing.md),
                    _Field(label: 'Email', controller: _emailCtrl, hint: 'e.g. admin@example.com', icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null),
                    if (!isEdit) ...[
                      const SizedBox(height: AppSpacing.md),
                      _Field(label: 'Password', controller: _passwordCtrl, hint: 'Min. 6 characters', icon: Icons.lock_outlined,
                        obscureText: true, validator: (v) {
                          if (v?.isEmpty ?? true) return 'Required';
                          if (v!.length < 6) return 'Min. 6 characters';
                          return null;
                        }),
                    ],
                    if (widget.fixedOrgId == null) ...[
                      const SizedBox(height: AppSpacing.md),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Organization', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textPrimary)),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(color: surface, borderRadius: AppRadius.roundedSm, border: Border.all(color: border)),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: DropdownButton<String?>(
                            isExpanded: true,
                            value: _orgId,
                            underline: const SizedBox(),
                            hint: Text('Select Organization', style: TextStyle(fontSize: 13, color: textSecondary)),
                            items: [
                              const DropdownMenuItem(value: null, child: Text('None', style: TextStyle(fontSize: 13))),
                              ...orgs.map((org) => DropdownMenuItem(
                                value: org.id,
                                child: Text(org.name, style: TextStyle(fontSize: 13, color: textPrimary)),
                              )),
                            ],
                            onChanged: (v) => setState(() => _orgId = v),
                          ),
                        ),
                      ]),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Role', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textPrimary)),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(color: surface, borderRadius: AppRadius.roundedSm, border: Border.all(color: border)),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _role,
                          underline: const SizedBox(),
                          items: [
                            const DropdownMenuItem(value: 'admin', child: Text('Admin', style: TextStyle(fontSize: 13))),
                            const DropdownMenuItem(value: 'super_admin', child: Text('Super Admin', style: TextStyle(fontSize: 13))),
                          ],
                          onChanged: (v) => setState(() => _role = v!),
                        ),
                      ),
                    ]),
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
                            : Text(isEdit ? 'Save' : 'Create'),
                      ),
                    ]),
                  ],
                ),
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
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  const _Field({required this.label, required this.controller, required this.hint, required this.icon,
    this.keyboardType, this.obscureText = false, this.validator});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
      const SizedBox(height: 8),
      TextFormField(
        controller: controller, keyboardType: keyboardType, obscureText: obscureText, validator: validator,
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
