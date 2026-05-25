import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '/core/design_system/app_design_system.dart';
import '../../domain/models/client.dart';
import '../providers/clients_provider.dart';

class ClientScreen extends ConsumerWidget {
  const ClientScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientsAsyncValue = ref.watch(clientsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= AppBreakpoints.lg;
        return Scaffold(
          backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
          body: SafeArea(
            child: MaxWidthContainer(
              child: Stack(
                children: [
                  CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverAppBar(
                        title: Text(
                          'Clients',
                          style: TextStyle(
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                            fontFamily: GoogleFonts.outfit().fontFamily,
                          ),
                        ),
                        floating: true,
                        snap: true,
                        centerTitle: false,
                      ),
                      clientsAsyncValue.when(
                        data: (clients) {
                          final sorted = List<Client>.from(clients)
                            ..sort((a, b) {
                              final aDate = a.joinDate ?? a.createdAt;
                              final bDate = b.joinDate ?? b.createdAt;
                              return bDate.compareTo(aDate);
                            });
                          if (sorted.isEmpty) {
                            return SliverFillRemaining(
                              hasScrollBody: false,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.people_outline_rounded,
                                      size: 64,
                                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                    ),
                                    SizedBox(height: AppSpacing.md),
                                    Text(
                                      'No clients registered yet',
                                      style: TextStyle(
                                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          if (isWide) {
                            return SliverPadding(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              sliver: SliverMasonryGrid.count(
                                crossAxisCount: 2,
                                mainAxisSpacing: AppSpacing.md,
                                crossAxisSpacing: AppSpacing.md,
                                childCount: sorted.length,
                                itemBuilder: (context, index) =>
                                    _ClientListItem(client: sorted[index]),
                              ),
                            );
                          }
                          return SliverPadding(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final client = sorted[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                                    child: _ClientListItem(client: client),
                                  );
                                },
                                childCount: sorted.length,
                              ),
                            ),
                          );
                        },
                        loading: () => const SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (err, stack) => SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              child: Text(
                                'Error loading clients: $err',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: AppColors.accent),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Extra space at bottom for FAB
                      const SliverToBoxAdapter(child: SizedBox(height: 80)),
                    ],
                  ),
                  Positioned(
                    right: 0,
                    bottom: AppSpacing.md,
                    child: FloatingActionButton.extended(
                      onPressed: () => _showAddClientDialog(context),
                      label: const Text('Add Client'),
                      icon: const Icon(Icons.person_add_rounded),
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAddClientDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      barrierColor: isDark ? AppColors.textPrimaryDark.withValues(alpha: 0.8) : AppColors.textPrimary.withValues(alpha: 0.8),
      builder: (context) => const AddClientDialog(),
    );
  }
}

class _ClientListItem extends StatelessWidget {
  final Client client;

  const _ClientListItem({required this.client});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: AppRadius.roundedMd,
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => context.go('/clients/${client.id}/about'),
        borderRadius: AppRadius.roundedMd,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: AppRadius.roundedSm,
                    ),
                   
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          client.aliasCode,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          client.dateOfBirth != null ? '${client.age} yrs' : 'N/A',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded,
                      size: 20, color: isDark ? AppColors.borderDark : AppColors.border),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Divider(height: 1, color: isDark ? AppColors.borderDark : AppColors.border),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Icon(Icons.wc_rounded, size: 16, color: AppColors.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    client.gender,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    client.joinDate != null
                        ? 'Joined ${_formatDate(client.joinDate!)}'
                        : 'Added ${_formatDate(client.createdAt)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

class AddClientDialog extends ConsumerStatefulWidget {
  const AddClientDialog({super.key});

  @override
  ConsumerState<AddClientDialog> createState() => _AddClientDialogState();
}

class _AddClientDialogState extends ConsumerState<AddClientDialog> {
  final _formKey = GlobalKey<FormState>();
  final _aliasController = TextEditingController();
  final _phoneController = TextEditingController();
  DateTime? _dateOfBirth;
  DateTime _joinDate = DateTime.now();
  String _gender = 'Male';
  bool _isLoading = false;

  int? get _calculatedAge {
    if (_dateOfBirth == null) return null;
    final now = DateTime.now();
    int age = now.year - _dateOfBirth!.year;
    if (now.month < _dateOfBirth!.month ||
        (now.month == _dateOfBirth!.month && now.day < _dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  @override
  void dispose() {
    _aliasController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.md,
                ),
                child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.person_add_alt_1_rounded,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Register Client',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _DialogTextField(
                    controller: _aliasController,
                    label: 'Alias Code',
                    hint: 'e.g. PAT-001',
                    prefixIcon: Icons.tag_rounded,
                    validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Gender',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ButtonTheme(
                    alignedDropdown: true,
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: _gender,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        border: OutlineInputBorder(
                          borderRadius: AppRadius.roundedSm,
                          borderSide: BorderSide(color: isDark ? AppColors.borderDark : AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: AppRadius.roundedSm,
                          borderSide: BorderSide(color: isDark ? AppColors.borderDark : AppColors.border),
                        ),
                      ),
                      items: ['Male', 'Female']
                          .map((g) => DropdownMenuItem(value: g, child: Text(g, style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                          ))))
                          .toList(),
                      onChanged: (v) => setState(() => _gender = v!),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Date of Birth',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _dateOfBirth ?? DateTime(2000),
                        firstDate: DateTime(1950),
                        lastDate: DateTime.now(),
                        helpText: 'Select date of birth',
                      );
                      if (picked != null) {
                        setState(() => _dateOfBirth = picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isDark ? AppColors.borderDark : AppColors.border,
                        ),
                        borderRadius: AppRadius.roundedSm,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_rounded,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _dateOfBirth != null
                                  ? '${_dateOfBirth!.day.toString().padLeft(2, '0')}/${_dateOfBirth!.month.toString().padLeft(2, '0')}/${_dateOfBirth!.year}'
                                  : 'Select date of birth',
                              style: TextStyle(
                                color: _dateOfBirth != null
                                    ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)
                                    : AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          if (_calculatedAge != null)
                            Text(
                              '  $_calculatedAge yrs',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                fontSize: 14,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _DialogTextField(
                    controller: _phoneController,
                    label: 'Phone',
                    hint: 'e.g. +8801XXXXXXXXX',
                    prefixIcon: Icons.phone_rounded,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Join Date',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _joinDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                        helpText: 'Select join date',
                      );
                      if (picked != null) {
                        setState(() => _joinDate = picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isDark ? AppColors.borderDark : AppColors.border,
                        ),
                        borderRadius: AppRadius.roundedSm,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.event_rounded,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '${_joinDate.day.toString().padLeft(2, '0')}/${_joinDate.month.toString().padLeft(2, '0')}/${_joinDate.year}',
                              style: TextStyle(
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleSave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(140, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.roundedMd,
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Create Profile'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a date of birth'),
          backgroundColor: AppColors.accent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref
          .read(clientsProvider.notifier)
          .addClient(
            _aliasController.text.trim(),
            _gender,
            joinDate: _joinDate,
            dateOfBirth: _dateOfBirth,
            phone: _phoneController.text.trim(),
          );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.accent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

class _DialogTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData prefixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _DialogTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(prefixIcon, size: 20, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            hintStyle: TextStyle(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ),
            border: OutlineInputBorder(
              borderRadius: AppRadius.roundedSm,
              borderSide: BorderSide(color: isDark ? AppColors.borderDark : AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.roundedSm,
              borderSide: BorderSide(color: isDark ? AppColors.borderDark : AppColors.border),
            ),
          ),
        ),
      ],
    );
  }
}
