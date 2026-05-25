import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '/core/design_system/app_design_system.dart';
import '../../domain/session.dart';
import '../providers/client_detail_providers.dart';
import 'session_dialog.dart';

class SessionsTab extends ConsumerWidget {
  final String clientId;
  final String clientAlias;

  const SessionsTab({
    super.key,
    required this.clientId,
    required this.clientAlias,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(clientSessionsProvider(clientId));

    return Stack(
      children: [
        sessionsAsync.when(
          data: (sessions) {
              if (sessions.isEmpty) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              return Center(
                child: Text(
                  'No sessions yet',
                  style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.only(
                left: AppSpacing.md,
                right: AppSpacing.md,
                top: AppSpacing.md,
                bottom: 80,
              ),
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                final session = sessions[index];
                return SessionListItem(
                  session: session,
                  index: sessions.length - index,
                  onTap: () => context.go(
                    '/clients/${session.clientId}/sessions/${session.id}',
                    extra: {'session': session},
                  ),
                  onEdit: () => _showEditSessionDialog(context, ref, session),
                  onDelete: () => _deleteSession(context, ref, session),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
        Positioned(
          right: AppSpacing.md,
          bottom: AppSpacing.md,
          child: FloatingActionButton.extended(
            onPressed: () => _showAddSessionDialog(context, ref),
            label: const Text('Add Session'),
            icon: const Icon(Icons.add_task_rounded),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  void _showAddSessionDialog(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      barrierColor: (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary).withValues(alpha: 0.8),
      builder: (_) => AddSessionDialog(clientId: clientId, clientAlias: clientAlias),
    );
  }

  void _showEditSessionDialog(
    BuildContext context,
    WidgetRef ref,
    Session session,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      barrierColor: (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary).withValues(alpha: 0.8),
      builder: (context) =>
          AddSessionDialog(clientId: clientId, clientAlias: clientAlias, session: session),
    );
  }

  Future<void> _deleteSession(
    BuildContext context,
    WidgetRef ref,
    Session session,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.surfaceDark : null,
          title: Text('Delete Session',
            style: TextStyle(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
          content: Text(
            'Delete "${session.title.isNotEmpty ? session.title : 'Session'}" from ${DateFormat.yMMMd().format(session.date)}?',
            style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Cancel',
                style: TextStyle(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    if (confirm != true) return;
    try {
      await ref.read(sessionRepositoryProvider).deleteSession(session.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session deleted')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.accent),
        );
      }
    }
  }
}

class SessionListItem extends StatelessWidget {
  final Session session;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const SessionListItem({
    super.key,
    required this.session,
    required this.index,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final title = session.title.isNotEmpty
        ? session.title
        : 'Session $index';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final dateText = DateFormat.yMMMd().format(session.date);

    String? timeText;
    if (session.startTime != null && session.endTime != null) {
      final duration = session.endTime!.difference(session.startTime!);
      final hours = duration.inHours;
      final minutes = duration.inMinutes.remainder(60);
      final durStr = hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';
      timeText = '${DateFormat('hh:mm a').format(session.startTime!)} - ${DateFormat('hh:mm a').format(session.endTime!)} ($durStr)';
    } else if (session.startTime != null) {
      timeText = DateFormat('hh:mm a').format(session.startTime!);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.roundedMd,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: AppRadius.roundedMd,
          border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    dateText,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: session.status == 'completed'
                        ? Colors.green.withOpacity(0.1)
                        : AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    session.status.capitalizeFirst(),
                    style: TextStyle(
                      fontSize: 10,
                      color: session.status == 'completed'
                          ? Colors.green
                          : AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
            ),
            if (session.notes.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                session.notes,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            Row(
              spacing: 4,
              children: [
                if (timeText != null)
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: Text(
                      timeText,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                      ),
                    ),
                  ),
                const Spacer(),
                _CardActionButton(
                  icon: Icons.edit,
                  onTap: onEdit,
                ),
                const SizedBox(width: 4),
                _CardActionButton(
                  icon: Icons.delete_outline,
                  color: Colors.red,
                  onTap: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    ),
    );
  }
}

extension on String {
  String capitalizeFirst() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

class _CardActionButton extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final VoidCallback onTap;

  const _CardActionButton({
    required this.icon,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: c.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 14, color: c),
      ),
    );
  }
}


