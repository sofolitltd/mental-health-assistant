class _Sentinel {
  const _Sentinel();
}

const _sentinel = _Sentinel();

class Session {
  final String id;
  final String organizationId;
  final String clientId;
  final String clientAlias;
  final List<String> counselorIds;
  final String title;
  final DateTime date;
  final String notes;
  final String status;
  final DateTime createdAt;
  final DateTime? followUpDate;
  final DateTime? startTime;
  final DateTime? endTime;
  final double? latitude;
  final double? longitude;
  final DateTime? locationTimestamp;

  const Session({
    required this.id,
    this.organizationId = '',
    required this.clientId,
    required this.clientAlias,
    this.counselorIds = const [],
    this.title = '',
    required this.date,
    this.notes = '',
    this.status = 'scheduled',
    required this.createdAt,
    this.followUpDate,
    this.startTime,
    this.endTime,
    this.latitude,
    this.longitude,
    this.locationTimestamp,
  });

  Session copyWith({
    String? id,
    String? organizationId,
    String? clientId,
    String? clientAlias,
    List<String>? counselorIds,
    String? title,
    DateTime? date,
    String? notes,
    String? status,
    DateTime? createdAt,
    Object? followUpDate = _sentinel,
    Object? startTime = _sentinel,
    Object? endTime = _sentinel,
    Object? latitude = _sentinel,
    Object? longitude = _sentinel,
    Object? locationTimestamp = _sentinel,
  }) {
    return Session(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      clientId: clientId ?? this.clientId,
      clientAlias: clientAlias ?? this.clientAlias,
      counselorIds: counselorIds ?? this.counselorIds,
      title: title ?? this.title,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      followUpDate: followUpDate is _Sentinel ? this.followUpDate : followUpDate as DateTime?,
      startTime: startTime is _Sentinel ? this.startTime : startTime as DateTime?,
      endTime: endTime is _Sentinel ? this.endTime : endTime as DateTime?,
      latitude: latitude is _Sentinel ? this.latitude : latitude as double?,
      longitude: longitude is _Sentinel ? this.longitude : longitude as double?,
      locationTimestamp: locationTimestamp is _Sentinel ? this.locationTimestamp : locationTimestamp as DateTime?,
    );
  }

  Map<String, dynamic> toMap() => {
        'organizationId': organizationId,
        'clientId': clientId,
        'clientAlias': clientAlias,
        'counselorIds': counselorIds,
        'title': title,
        'date': date.toIso8601String(),
        'notes': notes,
        'status': status,
        'createdAt': createdAt.toIso8601String(),
        if (followUpDate != null) 'followUpDate': followUpDate!.toIso8601String(),
        if (startTime != null) 'startTime': startTime!.toIso8601String(),
        if (endTime != null) 'endTime': endTime!.toIso8601String(),
        'latitude': latitude,
        'longitude': longitude,
        'locationTimestamp': locationTimestamp?.toIso8601String(),
      };

  factory Session.fromMap(Map<String, dynamic> map, String id) => Session(
        id: id,
        organizationId: map['organizationId'] as String? ?? '',
        clientId: map['clientId'] as String,
        clientAlias: map['clientAlias'] as String? ?? '',
        counselorIds: map['counselorIds'] != null
            ? List<String>.from(map['counselorIds'] as List)
            : map['psychologistId'] != null
                ? [map['psychologistId'] as String]
                : [],
        title: map['title'] as String? ?? '',
        date: DateTime.parse(map['date'] as String),
        notes: map['notes'] as String? ?? '',
        status: map['status'] as String? ?? 'scheduled',
        createdAt: DateTime.parse(map['createdAt'] as String),
        followUpDate: map['followUpDate'] != null
            ? DateTime.parse(map['followUpDate'] as String)
            : null,
        startTime: map['startTime'] != null
            ? DateTime.parse(map['startTime'] as String)
            : null,
        endTime: map['endTime'] != null
            ? DateTime.parse(map['endTime'] as String)
            : null,
        latitude: (map['latitude'] as num?)?.toDouble(),
        longitude: (map['longitude'] as num?)?.toDouble(),
        locationTimestamp: map['locationTimestamp'] != null
            ? DateTime.parse(map['locationTimestamp'] as String)
            : null,
      );
}
