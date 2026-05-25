import 'package:flutter/material.dart';

import '/core/design_system/app_design_system.dart';
import '../../../../assessment_engine/domain/assessment_session.dart';

class HighRiskBanner extends StatelessWidget {
  final List<AssessmentSession> alerts;
  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;
  final String fontFamily;
  final ValueChanged<String> onDismiss;

  const HighRiskBanner({
    super.key,
    required this.alerts,
    required this.isDark,
    required this.textPrimary,
    required this.textSecondary,
    required this.fontFamily,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: AppRadius.roundedMd,
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Attention Required',
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  fontFamily: fontFamily,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ...alerts.take(3).map((a) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    '${a.clientAlias.isNotEmpty ? a.clientAlias : a.clientId} — ${a.scores.values.where((s) => s.severity == 'High Risk' || s.severity == 'Severe' || s.severity == 'Extremely Severe' || s.severity == 'Moderate Risk').map((s) => '${s.scale.replaceAll('_', ' ')}: ${s.severity}').join(', ')}',
                    style: TextStyle(
                      color: Colors.red.shade800,
                      fontSize: 13,
                      fontFamily: fontFamily,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () => onDismiss(a.sessionId),
                  child: Icon(Icons.close, size: 16, color: Colors.red.shade300),
                ),
              ],
            ),
          )),
          if (alerts.length > 3)
            Text(
              '+${alerts.length - 3} more',
              style: TextStyle(
                color: textSecondary,
                fontSize: 12,
                fontFamily: fontFamily,
              ),
            ),
        ],
      ),
    );
  }
}
