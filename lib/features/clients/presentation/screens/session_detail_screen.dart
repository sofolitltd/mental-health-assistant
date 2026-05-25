import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '/core/design_system/app_design_system.dart';
import '/core/logger/app_logger.dart';
import '../../domain/session.dart';
import '../providers/client_detail_providers.dart';
import '../../../contacts/presentation/providers/contacts_providers.dart';
import '../../../assessment_engine/presentation/providers/assessment_session_providers.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import 'widgets/session_info_card.dart';
import 'widgets/session_sections.dart';
import 'widgets/session_assessment_section.dart';
import 'widgets/session_counselors_section.dart';
import 'widgets/session_location_section.dart';

export 'widgets/session_detail_loader.dart';

class SessionDetailScreen extends ConsumerStatefulWidget {
  final Session session;
  const SessionDetailScreen({super.key, required this.session});
  @override
  ConsumerState<SessionDetailScreen> createState() => _SessionDetailScreenState();
}

class _SessionDetailScreenState extends ConsumerState<SessionDetailScreen> {
  late final TextEditingController _notesController;
  late String _status;
  late DateTime _date;
  DateTime? _startTime;
  DateTime? _endTime;
  DateTime? _followUpDate;
  late List<String> _counselorIds;
  double? _latitude;
  double? _longitude;
  DateTime? _locationTimestamp;
  bool _isSaving = false;
  bool _isLocating = false;
  final _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.session.notes);
    _status = widget.session.status;
    _date = widget.session.date;
    _startTime = widget.session.startTime;
    _endTime = widget.session.endTime;
    _followUpDate = widget.session.followUpDate;
    _counselorIds = List.from(widget.session.counselorIds);
    _latitude = widget.session.latitude;
    _longitude = widget.session.longitude;
    _locationTimestamp = widget.session.locationTimestamp;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  bool get _hasChanges =>
      _notesController.text != widget.session.notes ||
      _status != widget.session.status ||
      _date != widget.session.date ||
      _startTime != widget.session.startTime ||
      _endTime != widget.session.endTime ||
      _followUpDate != widget.session.followUpDate ||
      !listEquals(_counselorIds, widget.session.counselorIds) ||
      _latitude != widget.session.latitude ||
      _longitude != widget.session.longitude ||
      _locationTimestamp != widget.session.locationTimestamp;

  Future<void> _save() async {
    if (!_hasChanges) return;
    setState(() => _isSaving = true);
    try {
      final original = widget.session;
      final updated = original.copyWith(
        notes: _notesController.text.trim(),
        status: _status,
        date: _date,
        startTime: _startTime,
        endTime: _endTime,
        followUpDate: _followUpDate,
        counselorIds: _counselorIds,
        latitude: _latitude,
        longitude: _longitude,
        locationTimestamp: _locationTimestamp,
      );
      await ref.read(sessionRepositoryProvider).updateSession(updated);
      ref.invalidate(allSessionsProvider);
      ref.invalidate(dashboardDataProvider);
      AppLogger.info('Session saved', {
        'sessionId': original.id,
        'clientId': original.clientId,
        'hasLocation': _latitude != null,
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session saved')),
        );
      }
    } catch (e, stack) {
      AppLogger.error('Failed to save session', {'sessionId': widget.session.id}, e, stack);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _recordLocation() async {
    if (_isLocating) {
      AppLogger.warn('Record location skipped — already in progress');
      return;
    }
    setState(() => _isLocating = true);
    AppLogger.info('Record location started', {'sessionId': widget.session.id});

    try {
      final permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        AppLogger.warn('Location permission denied');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied.')),
          );
        }
        setState(() => _isLocating = false);
        return;
      }
      if (permission == LocationPermission.deniedForever) {
        AppLogger.warn('Location permission denied forever');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission permanently denied. Enable in settings.')),
          );
        }
        setState(() => _isLocating = false);
        return;
      }
    } catch (e, stack) {
      AppLogger.error('Location permission request failed', null, e, stack);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Permission error: $e')),
        );
      }
      setState(() => _isLocating = false);
      return;
    }

    const desiredAccuracy = 10.0;
    const maxAttempts = 5;
    Position? best;
    var latSum = 0.0;
    var lngSum = 0.0;
    var goodCount = 0;

    final locationSettings = kIsWeb
        ? const LocationSettings(
            accuracy: LocationAccuracy.low,
            timeLimit: Duration(seconds: 30),
          )
        : const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 5),
          );

    for (var i = 0; i < maxAttempts; i++) {
      try {
        final pos = await Geolocator.getCurrentPosition(
          locationSettings: locationSettings,
        );
        final acc = pos.accuracy;
        if (best == null || best.accuracy > acc) {
          best = pos;
        }
        if (acc <= desiredAccuracy && acc > 0) {
          latSum += pos.latitude;
          lngSum += pos.longitude;
          goodCount++;
        }
        if (goodCount >= 2) break;
      } catch (e, stack) {
        AppLogger.warn('GPS attempt $i failed', {'sessionId': widget.session.id}, e);
        if (i == maxAttempts - 1) {
          AppLogger.error('All GPS attempts exhausted', {'sessionId': widget.session.id}, e, stack);
        }
      }
      if (i < maxAttempts - 1) await Future.delayed(const Duration(milliseconds: 800));
    }

    final pos = goodCount >= 1
        ? Position(
            latitude: latSum / goodCount,
            longitude: lngSum / goodCount,
            accuracy: 0,
            altitude: 0,
            heading: 0,
            speed: 0,
            speedAccuracy: 0,
            timestamp: DateTime.now(),
            altitudeAccuracy: 0,
            headingAccuracy: 0,
          )
        : best;
    if (!mounted) return;
    setState(() {
      _isLocating = false;
      if (pos != null) {
        _latitude = pos.latitude;
        _longitude = pos.longitude;
        _locationTimestamp = DateTime.now();
        AppLogger.info('Location recorded', {
          'sessionId': widget.session.id,
          'latitude': pos.latitude,
          'longitude': pos.longitude,
          'accuracy': pos.accuracy,
          'goodReadings': goodCount,
        });
      }
    });
    if (pos == null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not get GPS fix. Try stepping outside.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final fontFamily = GoogleFonts.outfit().fontFamily!;
    final assessmentsAsync = ref.watch(
      linkedAssessmentSessionsProvider(widget.session.id),
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.backgroundDark : AppColors.background;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: bg,
        elevation: 0,
        title: MaxWidthContainer(
          padding: EdgeInsets.zero,
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.arrow_back_rounded,
                  color: textPrimary,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  widget.session.title.isNotEmpty
                      ? widget.session.title
                      : 'Session Details',
                  style: TextStyle(
                    fontFamily: fontFamily,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
              ),
              if (_hasChanges)
                ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(80, 36),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.roundedSm,
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Save'),
                ),
            ],
          ),
        ),
      ),
      body: MaxWidthContainer(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            SessionInfoCard(
              fontFamily: fontFamily,
              date: _date,
              startTime: _startTime,
              endTime: _endTime,
              title: widget.session.title,
              clientAlias: widget.session.clientAlias,
              onPickDate: _pickDate,
              onPickStartTime: _pickStartTime,
              onPickEndTime: _pickEndTime,
              onClearStartTime: () => setState(() => _startTime = null),
              onClearEndTime: () => setState(() => _endTime = null),
            ),
            const SizedBox(height: AppSpacing.lg),
            SessionStatusSection(
              fontFamily: fontFamily,
              status: _status,
              onStatusChanged: (s) => setState(() => _status = s),
            ),
            const SizedBox(height: AppSpacing.lg),
            SessionFollowUpSection(
              fontFamily: fontFamily,
              followUpDate: _followUpDate,
              onPickDate: _pickFollowUpDate,
              onClearDate: () => setState(() => _followUpDate = null),
            ),
            const SizedBox(height: AppSpacing.lg),
            SessionCounselorsSection(
              fontFamily: fontFamily,
              counselorIds: _counselorIds,
              onRemoveCounselor: (uid) => setState(() => _counselorIds.remove(uid)),
              onAddCounselor: _showAddCounselorDialog,
            ),
            const SizedBox(height: AppSpacing.lg),
            SessionAssessmentSection(
              fontFamily: fontFamily,
              assessmentsAsync: assessmentsAsync,
              onStartAssessment: () => _startAssessment(context),
            ),
            const SizedBox(height: AppSpacing.lg),
            SessionNotesSection(
              fontFamily: fontFamily,
              controller: _notesController,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppSpacing.lg),
            SessionLocationSection(
              fontFamily: fontFamily,
              latitude: _latitude,
              longitude: _longitude,
              locationTimestamp: _locationTimestamp,
              isLoading: _isLocating,
              mapController: _mapController,
              onRecord: _recordLocation,
              onRemove: () => setState(() { _latitude = null; _longitude = null; _locationTimestamp = null; }),
              onOpenInMaps: () => launchUrl(
                Uri.parse('https://www.google.com/maps?q=$_latitude,$_longitude'),
                mode: LaunchMode.externalApplication,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCounselorDialog() {
    final client = ref.read(clientByIdProvider(widget.session.clientId));
    if (client == null) return;

    final clientCounselorIds = client.counselorIds.toSet();
    final allCounselorsValue = ref.read(allCounselorsProvider);
    final all = allCounselorsValue.value;
    if (all == null) return;

    final clientCounselors = all.where((c) => clientCounselorIds.contains(c.id)).toList();
    final assigned = _counselorIds.toSet();
    final available = clientCounselors.where((c) => !assigned.contains(c.id)).toList();

    if (available.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _counselorIds.isEmpty
                ? 'No counselors assigned to this client.'
                : 'All client counselors are already assigned.',
          ),
        ),
      );
      return;
    }

    final selected = <String>{};
    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
        final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
        final surface = isDark ? AppColors.surfaceDark : AppColors.surface;
        final border = isDark ? AppColors.borderDark : AppColors.border;

        return StatefulBuilder(
          builder: (ctx, setDialogState) => MaxWidthContainer(
            maxWidth: 500,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Dialog(
                backgroundColor: surface,
                shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedLg),
                insetPadding: const EdgeInsets.all(12),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.md,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: 300,
                      maxHeight: MediaQuery.of(ctx).size.height * 0.75,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.person_add_rounded, color: AppColors.primary),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                'Add Counselor',
                                style: TextStyle(
                                  fontSize: Theme.of(ctx).textTheme.titleLarge?.fontSize,
                                  fontWeight: FontWeight.bold,
                                  color: textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Expanded(
                          child: available.isEmpty
                              ? Center(
                                  child: Text('No counselors available.',
                                      style: TextStyle(color: textSecondary)),
                                )
                              : ListView(
                                  children: available.map((c) {
                                    final isSelected = selected.contains(c.id);
                                    return InkWell(
                                      borderRadius: AppRadius.roundedSm,
                                      onTap: () {
                                        setDialogState(() {
                                          if (isSelected) {
                                            selected.remove(c.id);
                                          } else {
                                            selected.add(c.id);
                                          }
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: AppSpacing.md,
                                          vertical: AppSpacing.sm,
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border(
                                              bottom: BorderSide(color: border, width: 0.5)),
                                        ),
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              backgroundColor:
                                                  AppColors.primary.withValues(alpha: 0.15),
                                              child: Text(
                                                c.name.isNotEmpty
                                                    ? c.name[0].toUpperCase()
                                                    : '?',
                                                style: const TextStyle(
                                                  color: AppColors.primary,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: AppSpacing.md),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(c.name,
                                                      style: TextStyle(
                                                          fontWeight: FontWeight.w500,
                                                          color: textPrimary,
                                                          fontSize: 14)),
                                                  Text(
                                                    '${c.employeeId}${c.designation.isNotEmpty ? ' — ${c.designation}' : ''}',
                                                    style: TextStyle(
                                                        color: textSecondary, fontSize: 12),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Icon(
                                              isSelected
                                                  ? Icons.check_circle_rounded
                                                  : Icons.radio_button_unchecked_rounded,
                                              color: isSelected
                                                  ? AppColors.primary
                                                  : textSecondary,
                                              size: 22,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: Text('Cancel', style: TextStyle(color: textPrimary)),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(140, 48),
                                shape: RoundedRectangleBorder(
                                    borderRadius: AppRadius.roundedMd),
                              ),
                              onPressed: selected.isEmpty
                                  ? null
                                  : () {
                                      Navigator.pop(ctx);
                                      setState(() {
                                        _counselorIds = [
                                          ..._counselorIds,
                                          ...selected.where(
                                              (id) => !_counselorIds.contains(id)),
                                        ];
                                      });
                                    },
                              child: Text('Add (${selected.length})'),
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

  void _startAssessment(BuildContext context) {
    context.go(
      '/clients/${widget.session.clientId}/new-assessment?clientAlias=${Uri.encodeComponent(widget.session.clientAlias)}&from=session&sessionId=${widget.session.id}',
    );
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) setState(() => _date = date);
  }

  Future<void> _pickStartTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _startTime != null
          ? TimeOfDay.fromDateTime(_startTime!)
          : const TimeOfDay(hour: 9, minute: 0),
      helpText: 'Select start time',
    );
    if (time == null) return;
    setState(() {
      _startTime = DateTime(_date.year, _date.month, _date.day, time.hour, time.minute);
    });
  }

  Future<void> _pickEndTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _endTime != null
          ? TimeOfDay.fromDateTime(_endTime!)
          : _startTime != null
              ? TimeOfDay.fromDateTime(_startTime!.add(const Duration(hours: 1)))
              : const TimeOfDay(hour: 10, minute: 0),
      helpText: 'Select end time',
    );
    if (time == null) return;
    setState(() {
      _endTime = DateTime(_date.year, _date.month, _date.day, time.hour, time.minute);
    });
  }

  Future<void> _pickFollowUpDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _followUpDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date != null) setState(() => _followUpDate = date);
  }
}

