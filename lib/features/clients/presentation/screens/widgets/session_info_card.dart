import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '/core/design_system/app_design_system.dart';

class SessionInfoCard extends StatelessWidget {
  final String fontFamily;
  final DateTime date;
  final DateTime? startTime;
  final DateTime? endTime;
  final String title;
  final String clientAlias;
  final VoidCallback onPickDate;
  final VoidCallback onPickStartTime;
  final VoidCallback onPickEndTime;
  final VoidCallback? onClearStartTime;
  final VoidCallback? onClearEndTime;

  const SessionInfoCard({
    super.key,
    required this.fontFamily,
    required this.date,
    this.startTime,
    this.endTime,
    required this.title,
    required this.clientAlias,
    required this.onPickDate,
    required this.onPickStartTime,
    required this.onPickEndTime,
    this.onClearStartTime,
    this.onClearEndTime,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final border = isDark ? AppColors.borderDark : AppColors.border;

    String? durationText;
    if (startTime != null && endTime != null) {
      final diff = endTime!.difference(startTime!);
      final h = diff.inHours;
      final m = diff.inMinutes.remainder(60);
      durationText = h > 0 ? '${h}h ${m}m' : '${m}m';
    }

    return Container(
      width: double.infinity,
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
          Text(
            title.isNotEmpty ? title : 'Session ${DateFormat.yMMMd().format(date)}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: fontFamily,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            clientAlias,
            style: TextStyle(color: textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              InkWell(
                onTap: onPickDate,
                borderRadius: AppRadius.roundedSm,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: border),
                    borderRadius: AppRadius.roundedSm,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.calendar_today_rounded, size: 16, color: textSecondary),
                      const SizedBox(width: AppSpacing.sm),
                      Text(DateFormat.yMMMd().format(date), style: TextStyle(color: textPrimary)),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: onPickStartTime,
                borderRadius: AppRadius.roundedSm,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: border),
                    borderRadius: AppRadius.roundedSm,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.access_time_rounded, size: 16, color: textSecondary),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        startTime != null ? DateFormat('h:mm a').format(startTime!) : 'Start',
                        style: TextStyle(color: startTime != null ? textPrimary : textSecondary),
                      ),
                      if (startTime != null && onClearStartTime != null)
                        GestureDetector(
                          onTap: onClearStartTime,
                          child: Icon(Icons.close_rounded, size: 16, color: textSecondary),
                        ),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: onPickEndTime,
                borderRadius: AppRadius.roundedSm,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: border),
                    borderRadius: AppRadius.roundedSm,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.access_time_rounded, size: 16, color: textSecondary),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        endTime != null ? DateFormat('h:mm a').format(endTime!) : 'End',
                        style: TextStyle(color: endTime != null ? textPrimary : textSecondary),
                      ),
                      if (endTime != null && onClearEndTime != null)
                        GestureDetector(
                          onTap: onClearEndTime,
                          child: Icon(Icons.close_rounded, size: 16, color: textSecondary),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (durationText != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Icon(Icons.schedule_rounded, size: 14, color: textSecondary),
                const SizedBox(width: 4),
                Text(durationText, style: TextStyle(fontSize: 12, color: textSecondary)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
