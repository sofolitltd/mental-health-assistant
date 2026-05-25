import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '/core/design_system/app_design_system.dart';
import '../../../../clients/domain/session.dart';

enum ScheduleRange { today, week, month }

class TodaySchedule extends StatelessWidget {
  final List<Session> sessions;
  final ScheduleRange range;
  final ValueChanged<ScheduleRange> onRangeChanged;
  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color surface;
  final String fontFamily;

  const TodaySchedule({
    super.key,
    required this.sessions,
    required this.range,
    required this.onRangeChanged,
    required this.isDark,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.surface,
    required this.fontFamily,
  });

  String get _title {
    switch (range) {
      case ScheduleRange.today: return "Today's Schedule";
      case ScheduleRange.week: return "This Week's Schedule";
      case ScheduleRange.month: return "This Month's Schedule";
    }
  }

  String get _emptyText {
    switch (range) {
      case ScheduleRange.today: return 'No sessions scheduled for today';
      case ScheduleRange.week: return 'No sessions scheduled this week';
      case ScheduleRange.month: return 'No sessions scheduled this month';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.sm),
      child: Container(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: AppRadius.roundedMd,
          border: Border.all(color: border),
          boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.sm, AppSpacing.sm),
              child: Row(
                children: [
                  Text(
                    _title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: textPrimary,
                      fontFamily: fontFamily,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    height: 32,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: border),
                    ),
                    child: ButtonTheme(
                      alignedDropdown: true,
                      child: DropdownButton<ScheduleRange>(
                        value: range,
                        underline: const SizedBox(),
                        icon: Icon(Icons.arrow_drop_down_rounded, color: textSecondary, size: 20),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: textSecondary,
                          fontFamily: fontFamily,
                        ),
                        items: const [
                          DropdownMenuItem(value: ScheduleRange.today, child: Text('Today')),
                          DropdownMenuItem(value: ScheduleRange.week, child: Text('This Week')),
                          DropdownMenuItem(value: ScheduleRange.month, child: Text('This Month')),
                        ],
                        onChanged: (v) {
                          if (v != null) onRangeChanged(v);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: border, indent: AppSpacing.md, endIndent: AppSpacing.md),
            if (sessions.isEmpty)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    Icon(Icons.event_busy_rounded, size: 18, color: textSecondary),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      _emptyText,
                      style: TextStyle(color: textSecondary, fontSize: 14, fontFamily: fontFamily),
                    ),
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  spacing: AppSpacing.md,
                  children: sessions.map((s) => _SessionTile(
                    session: s,
                    isDark: isDark,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    border: border,
                    fontFamily: fontFamily,
                  )).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  final Session session;
  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final String fontFamily;

  const _SessionTile({
    required this.session,
    required this.isDark,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.fontFamily,
  });

  Color _statusColor() {
    switch (session.status) {
      case 'completed': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return AppColors.primary;
    }
  }

  String? _timeText() {
    if (session.startTime != null && session.endTime != null) {
      final duration = session.endTime!.difference(session.startTime!);
      final hours = duration.inHours;
      final minutes = duration.inMinutes.remainder(60);
      final durStr = hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';
      return '${DateFormat('h:mm a').format(session.startTime!)} - ${DateFormat('h:mm a').format(session.endTime!)} ($durStr)';
    }
    if (session.startTime != null) {
      return DateFormat('h:mm a').format(session.startTime!);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final dateText = DateFormat.yMMMd().format(session.date);
    final statusColor = _statusColor();
    final timeText = _timeText();

    return InkWell(
      onTap: () => context.go('/clients/${session.clientId}/sessions/${session.id}', extra: {'session': session}),
      borderRadius: AppRadius.roundedMd,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: AppRadius.roundedMd,
          border: Border.all(color: border),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    dateText,
                    style: TextStyle(
                      fontSize: 12,
                      color: textSecondary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    session.status[0].toUpperCase() + session.status.substring(1),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              session.clientAlias.isNotEmpty ? session.clientAlias : 'Client',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: textPrimary,
                fontFamily: fontFamily,
              ),
            ),
            Row(
              mainAxisAlignment:.start,
              children: [
                if (session.title.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                session.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: textSecondary,
                  fontFamily: fontFamily,
                ),
              ),
            ],
            if (timeText != null) ...[
              const SizedBox(width: AppSpacing.sm),

              Text(
                ' | ',
                style: TextStyle(fontSize: 10, color: textSecondary),
              ),
              const SizedBox(width: AppSpacing.sm),
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: Text(
                  timeText,
                  style: TextStyle(
                    fontSize: 12,
                    color: textSecondary,
                    fontFamily: fontFamily,
                  ),
                ),
              ),
            ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
