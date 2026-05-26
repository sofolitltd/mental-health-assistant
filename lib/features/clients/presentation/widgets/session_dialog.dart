import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '/core/design_system/app_design_system.dart';
import '/features/auth/presentation/providers/auth_providers.dart';
import '../../domain/session.dart';
import '../providers/client_detail_providers.dart';

class AddSessionDialog extends ConsumerStatefulWidget {
  final String clientId;
  final String clientAlias;
  final Session? session;

  const AddSessionDialog({
    super.key,
    required this.clientId,
    required this.clientAlias,
    this.session,
  });

  @override
  ConsumerState<AddSessionDialog> createState() => _AddSessionDialogState();
}

class _AddSessionDialogState extends ConsumerState<AddSessionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  late DateTime _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  late String _status;
  late List<String> _counselorIds;
  bool _isLoading = false;

  bool get _isEditing => widget.session != null;

  @override
  void initState() {
    super.initState();
    final s = widget.session;
    _titleController.text = s?.title ?? '';
    _notesController.text = s?.notes ?? '';
    _selectedDate = s?.date ?? DateTime.now();
    _startTime = s?.startTime != null ? TimeOfDay.fromDateTime(s!.startTime!) : null;
    _endTime = s?.endTime != null ? TimeOfDay.fromDateTime(s!.endTime!) : null;
    _status = s?.status ?? 'scheduled';
    final uid = ref.read(authProvider).uid;
    _counselorIds = s?.counselorIds ?? (uid != null ? [uid] : []);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final border = isDark ? AppColors.borderDark : AppColors.border;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surface;
    return MaxWidthContainer(
      maxWidth: 500,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Dialog(
          backgroundColor: surface,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedLg),
          insetPadding: const EdgeInsets.all(12),
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
                          Icons.add_task_rounded,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          _isEditing ? 'Edit Session' : 'Add Session',
                          style: TextStyle(
                            fontSize: Theme.of(context).textTheme.titleLarge?.fontSize,
                            fontWeight: FontWeight.bold,
                              color: textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text('Title', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textPrimary)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleController,
                      style: TextStyle(color: textPrimary),
                      decoration: InputDecoration(
                        hintText: 'e.g., Session 1, Intake, Follow-up',
                        hintStyle: TextStyle(color: textSecondary),
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
                    Text('Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textPrimary)),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (date == null) return;
                        setState(() {
                          _selectedDate = DateTime(date.year, date.month, date.day);
                        });
                      },
                      borderRadius: AppRadius.roundedSm,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(
                          border: Border.all(color: border),
                          borderRadius: AppRadius.roundedSm,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                DateFormat.yMMMd().format(_selectedDate),
                                style: TextStyle(color: textPrimary),
                              ),
                            ),
                            Icon(Icons.calendar_today_rounded, size: 20, color: textSecondary),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Start Time', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textPrimary)),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: () async {
                                  final time = await showTimePicker(
                                    context: context,
                                    initialTime: _startTime ?? const TimeOfDay(hour: 9, minute: 0),
                                    helpText: 'Select start time',
                                  );
                                  if (time == null) return;
                                  setState(() => _startTime = time);
                                },
                                borderRadius: AppRadius.roundedSm,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: border),
                                    borderRadius: AppRadius.roundedSm,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          _startTime != null
                                              ? DateFormat('HH:mm a').format(
                                                  DateTime(2000, 1, 1, _startTime!.hour, _startTime!.minute))
                                              : 'Start',
                                          style: TextStyle(
                                            color: _startTime != null ? textPrimary : textSecondary,
                                          ),
                                        ),
                                      ),
                                      if (_startTime != null)
                                        GestureDetector(
                                          onTap: () => setState(() => _startTime = null),
                                          child: Icon(Icons.close_rounded, size: 18, color: textSecondary),
                                        )
                                      else
                                        Icon(Icons.access_time_rounded, size: 18, color: textSecondary),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('End Time', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textPrimary)),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: () async {
                                  final time = await showTimePicker(
                                    context: context,
                                    initialTime: _endTime ?? _startTime ?? const TimeOfDay(hour: 10, minute: 0),
                                    helpText: 'Select end time',
                                  );
                                  if (time == null) return;
                                  setState(() => _endTime = time);
                                },
                                borderRadius: AppRadius.roundedSm,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: border),
                                    borderRadius: AppRadius.roundedSm,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          _endTime != null
                                              ? DateFormat('HH:mm a').format(
                                                  DateTime(2000, 1, 1, _endTime!.hour, _endTime!.minute))
                                              : 'End',
                                          style: TextStyle(
                                            color: _endTime != null ? textPrimary : textSecondary,
                                          ),
                                        ),
                                      ),
                                      if (_endTime != null)
                                        GestureDetector(
                                          onTap: () => setState(() => _endTime = null),
                                          child: Icon(Icons.close_rounded, size: 18, color: textSecondary),
                                        )
                                      else
                                        Icon(Icons.access_time_rounded, size: 18, color: textSecondary),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (_startTime != null && _endTime != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: DurationBadge(startTime: _startTime!, endTime: _endTime!),
                      ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Status',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textPrimary),
                    ),
                    const SizedBox(height: 8),
                    ButtonTheme(
                      alignedDropdown: true,
                      child: DropdownButtonFormField<String>(
                        value: _status,
                        dropdownColor: isDark ? AppColors.surfaceDark : null,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                          ),
                          labelStyle: TextStyle(color: textSecondary),
                          border: OutlineInputBorder(
                            borderRadius: AppRadius.roundedSm,
                            borderSide: BorderSide(color: border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: AppRadius.roundedSm,
                            borderSide: BorderSide(color: border),
                          ),
                        ),
                        items: ['scheduled', 'completed', 'cancelled']
                            .map((s) => DropdownMenuItem(
                              value: s,
                              child: Text(s, style: TextStyle(color: textPrimary)),
                            ))
                            .toList(),
                        onChanged: (v) => setState(() => _status = v!),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Notes',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textPrimary),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 3,
                      style: TextStyle(color: textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Enter session notes (optional)',
                        hintStyle: TextStyle(color: textSecondary),
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
                    const SizedBox(height: AppSpacing.xl),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed:
                              _isLoading ? null : () => Navigator.pop(context),
                          child: Text('Cancel', style: TextStyle(color: textPrimary)),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleSave,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(120, 48),
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
                              : Text(_isEditing ? 'Update' : 'Save'),
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
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final startDateTime = _startTime != null
            ? DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day,
                _startTime!.hour, _startTime!.minute)
            : null;
        final endDateTime = _endTime != null
            ? DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day,
                _endTime!.hour, _endTime!.minute)
            : null;

        final organizationId = ref.read(clientByIdProvider(widget.clientId))?.organizationId ?? '';

        final session = Session(
          id: _isEditing ? widget.session!.id : '',
          organizationId: _isEditing ? widget.session!.organizationId : organizationId,
          clientId: widget.clientId,
          clientAlias: widget.clientAlias,
          counselorIds: _counselorIds,
          title: _titleController.text.trim(),
          date: _selectedDate,
          startTime: startDateTime,
          endTime: endDateTime,
          notes: _notesController.text.trim(),
          status: _status,
          createdAt: _isEditing ? widget.session!.createdAt : DateTime.now(),
        );

        if (_isEditing) {
          await ref.read(sessionRepositoryProvider).updateSession(session);
        } else {
          await ref.read(sessionRepositoryProvider).addSession(session);
        }
        if (mounted) Navigator.pop(context);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: AppColors.accent,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }
}

class DurationBadge extends StatelessWidget {
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  const DurationBadge({super.key, required this.startTime, required this.endTime});

  @override
  Widget build(BuildContext context) {
    final start = DateTime(2000, 1, 1, startTime.hour, startTime.minute);
    final end = DateTime(2000, 1, 1, endTime.hour, endTime.minute);
    final diff = end.difference(start);
    final hours = diff.inHours;
    final minutes = diff.inMinutes.remainder(60);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    String text;
    if (hours > 0 && minutes > 0) {
      text = '${hours}h ${minutes}m';
    } else if (hours > 0) {
      text = '${hours}h';
    } else {
      text = '${minutes}m';
    }

    return Row(
      children: [
        Icon(Icons.schedule_rounded, size: 14, color: textSecondary),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(fontSize: 12, color: textSecondary),
        ),
      ],
    );
  }
}
