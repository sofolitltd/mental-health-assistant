import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '/core/design_system/app_design_system.dart';
import '../../data/client_repository.dart';
import '../../domain/models/client.dart';
import '../../../assessment_engine/data/assessment_session_repository.dart';
import '../providers/client_detail_providers.dart';
import '../widgets/about_tab.dart';
import '../widgets/assessments_tab.dart';
import '../widgets/sessions_tab.dart';

class ClientDetailScreen extends ConsumerStatefulWidget {
  final String clientId;

  const ClientDetailScreen({super.key, required this.clientId});

  @override
  ConsumerState<ClientDetailScreen> createState() => _ClientDetailScreenState();
}

class _ClientDetailScreenState extends ConsumerState<ClientDetailScreen> {
  int get _tabIndex {
    final path = GoRouterState.of(context).uri.path;
    if (path.endsWith('/sessions')) return 1;
    if (path.endsWith('/assessments')) return 2;
    return 0;
  }

  void _onTabTap(int index) {
    final base = '/clients/${widget.clientId}';
    final targetPath = switch (index) {
      0 => '$base/about',
      1 => '$base/sessions',
      _ => '$base/assessments',
    };
    context.go(targetPath);
  }

  Widget _buildTab(String label, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selected = _tabIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => _onTabTap(index),
        child: Container(
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected
                  ? AppColors.primary
                  : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, Client client) {
    final aliasCtrl = TextEditingController(text: client.aliasCode);
    String gender = client.gender;
    DateTime? dateOfBirth = client.dateOfBirth;
    DateTime joinDate = client.joinDate ?? DateTime.now();

    int calculatedAge() {
      if (dateOfBirth == null) return 0;
      final now = DateTime.now();
      int age = now.year - dateOfBirth!.year;
      if (now.month < dateOfBirth!.month ||
          (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
        age--;
      }
      return age;
    }

    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
        final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
        final border = isDark ? AppColors.borderDark : AppColors.border;
        final surface = isDark ? AppColors.surfaceDark : AppColors.surface;
        return StatefulBuilder(
          builder: (ctx, setDialogState) => MaxWidthContainer(
            maxWidth: 500,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Dialog(
                backgroundColor: surface,
                shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedLg),
                insetPadding: const EdgeInsets.all(12),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.md),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.edit_outlined, color: AppColors.primary),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              'Edit Client',
                              style: TextStyle(
                                fontSize: Theme.of(ctx).textTheme.titleLarge?.fontSize,
                                fontWeight: FontWeight.bold,
                                color: textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text('Alias Code', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textPrimary)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: aliasCtrl,
                          style: TextStyle(color: isDark ? textPrimary : textSecondary),
                          decoration: InputDecoration(
                            hintText: 'e.g. PAT-001',
                            hintStyle: TextStyle(color: textSecondary),
                            prefixIcon: const Icon(Icons.tag_rounded, size: 20),
                            contentPadding: const EdgeInsets.all(12),
                            border: OutlineInputBorder(
                              borderRadius: AppRadius.roundedSm,
                              borderSide: BorderSide(color: border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: AppRadius.roundedSm,
                              borderSide: BorderSide(color: border),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text('Gender', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textPrimary)),
                        const SizedBox(height: 8),
                        ButtonTheme(
                          alignedDropdown: true,
                          child: DropdownButtonFormField<String>(
                            isExpanded: true,
                            initialValue: gender,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                              border: OutlineInputBorder(
                                borderRadius: AppRadius.roundedSm,
                                borderSide: BorderSide(color: border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: AppRadius.roundedSm,
                                borderSide: BorderSide(color: border),
                              ),
                            ),
                            items: ['Male', 'Female']
                                .map((g) => DropdownMenuItem(value: g, child: Text(g, style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black,
                                ))))
                                .toList(),
                            onChanged: (v) => setDialogState(() => gender = v!),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text('Date of Birth', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textPrimary)),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: ctx,
                              initialDate: dateOfBirth ?? DateTime(2000),
                              firstDate: DateTime(1950),
                              lastDate: DateTime.now(),
                              helpText: 'Select date of birth',
                            );
                            if (picked != null) {
                              setDialogState(() => dateOfBirth = picked);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            decoration: BoxDecoration(
                              border: Border.all(color: border),
                              borderRadius: AppRadius.roundedSm,
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today_rounded, color: AppColors.textSecondary, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    dateOfBirth != null
                                        ? '${dateOfBirth!.day.toString().padLeft(2, '0')}/${dateOfBirth!.month.toString().padLeft(2, '0')}/${dateOfBirth!.year}'
                                        : 'Select date of birth',
                                    style: TextStyle(
                                      color: dateOfBirth != null ? textPrimary : AppColors.textSecondary,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                if (dateOfBirth != null)
                                  Text(
                                    '${calculatedAge()} yrs',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 14),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        if (dateOfBirth == null)
                          Padding(
                            padding: const EdgeInsets.only(top: 6, left: 12),
                            child: Text(
                              'Age will be calculated from date of birth',
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ),
                        const SizedBox(height: AppSpacing.lg),
                        Text('Join Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textPrimary)),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: ctx,
                              initialDate: joinDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                              helpText: 'Select join date',
                            );
                            if (picked != null) {
                              setDialogState(() => joinDate = picked);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            decoration: BoxDecoration(
                              border: Border.all(color: border),
                              borderRadius: AppRadius.roundedSm,
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.event_rounded, color: AppColors.textSecondary, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    '${joinDate.day.toString().padLeft(2, '0')}/${joinDate.month.toString().padLeft(2, '0')}/${joinDate.year}',
                                    style: TextStyle(color: textPrimary, fontSize: 14),
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
                              onPressed: () => Navigator.pop(ctx),
                              child: Text('Cancel', style: TextStyle(color: textPrimary)),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            ElevatedButton(
                              onPressed: () async {
                                if (aliasCtrl.text.trim().isEmpty) return;
                                final updated = Client(
                                  id: client.id,
                                  organizationId: client.organizationId,
                                  counselorIds: client.counselorIds,
                                  aliasCode: aliasCtrl.text.trim(),
                                  gender: gender,
                                  createdAt: client.createdAt,
                                  joinDate: joinDate,
                                  dateOfBirth: dateOfBirth,
                                  phone: client.phone,
                                );
                                await ref.read(clientRepositoryProvider).updateClient(updated);
                                if (ctx.mounted) Navigator.pop(ctx);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(120, 48),
                                shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedMd),
                              ),
                              child: const Text('Save'),
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
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, Client client) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.surfaceDark : null,
        title: Text('Delete Client',
          style: TextStyle(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
        content: Text(
          'Are you sure you want to delete "${client.aliasCode}"?\n\nThis will also delete all sessions and assessments for this client. This action cannot be undone.',
          style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: TextStyle(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await ref.read(sessionRepositoryProvider).deleteSessionsByClientId(client.id);
      await ref.read(assessmentSessionRepositoryProvider).deleteSessionsByClientId(client.id);
      await ref.read(clientRepositoryProvider).deleteClient(client.id);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.accent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final client = ref.watch(clientByIdProvider(widget.clientId));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.backgroundDark : AppColors.background;

    if (client == null) {
      return Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          title: Text(
            'Client Details',
            style: TextStyle(
              fontFamily: GoogleFonts.outfit().fontFamily,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
          backgroundColor: bg,
        ),
        body: MaxWidthContainer(
          child: Center(
            child: Text(
              'Client not found',
              style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: MaxWidthContainer(
          child: Stack(
            children: [
              NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverAppBar(
                      title: Text(
                        client.aliasCode,
                        style: TextStyle(
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                          fontFamily: GoogleFonts.outfit().fontFamily,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      backgroundColor: bg,
                      elevation: 0,
                      pinned: true,
                      floating: true,
                      snap: true,
                      centerTitle: false,
                      leading: IconButton(
                        icon: Icon(
                          Icons.arrow_back_rounded,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      bottom: PreferredSize(
                        preferredSize: const Size.fromHeight(48),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: isDark ? AppColors.borderDark : AppColors.border),
                            ),
                          ),
                          child: Row(
                            children: [
                              _buildTab('About', 0),
                              _buildTab('Sessions', 1),
                              _buildTab('Assessments', 2),
                            ],
                          ),
                        ),
                      ),
                      actions: [
                        PopupMenuButton<String>(
                          icon: Icon(
                            Icons.more_vert_rounded,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                          ),
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showEditDialog(context, client);
                            } else if (value == 'delete') {
                              _confirmDelete(context, client);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  children: [
                                    Icon(Icons.edit_outlined, color: AppColors.primary, size: 20),
                                    SizedBox(width: 12),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  children: [
                                    Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                    SizedBox(width: 12),
                                    Text('Delete', style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ];
                },
                body: Padding(
                  padding: EdgeInsets.only(bottom: 1),
                  child: IndexedStack(
                    index: _tabIndex,
                    children: [
                      AboutTab(client: client),
                      SessionsTab(
                        clientId: widget.clientId,
                        clientAlias: client.aliasCode,
                      ),
                      AssessmentsTab(
                        clientId: widget.clientId,
                        clientAlias: client.aliasCode,
                      ),
                    ],
                  ),
                ),
              ),
              if (_tabIndex == 2)
                Positioned(
                  right: AppSpacing.md,
                  bottom: AppSpacing.md,
                  child: FloatingActionButton.extended(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('New Assessment'),
                    onPressed: () => context.go(
                      '/clients/${widget.clientId}/new-assessment?clientAlias=${Uri.encodeComponent(client.aliasCode)}&from=assessments',
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
