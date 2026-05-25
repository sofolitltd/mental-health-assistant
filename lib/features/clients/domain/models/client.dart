import 'package:cloud_firestore/cloud_firestore.dart';

class Client {
  final String id;
  final String organizationId;
  final List<String> counselorIds;
  final String aliasCode;
  final String gender;
  final DateTime createdAt;
  final DateTime? joinDate;
  final DateTime? dateOfBirth;

  Client({
    required this.id,
    required this.organizationId,
    required this.counselorIds,
    required this.aliasCode,
    required this.gender,
    required this.createdAt,
    this.joinDate,
    this.dateOfBirth,
  });

  int get age {
    if (dateOfBirth == null) return 0;
    final now = DateTime.now();
    int calc = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      calc--;
    }
    return calc;
  }

  factory Client.fromMap(Map<String, dynamic> map, String id) {
    return Client(
      id: id,
      organizationId: map['organizationId'] ?? '',
      counselorIds: List<String>.from(map['counselorIds'] ?? []),
      aliasCode: map['aliasCode'] ?? '',
      gender: map['gender'] ?? '',
      createdAt: map['createdAt'] is Timestamp 
          ? (map['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
      joinDate: map['joinDate'] is Timestamp
          ? (map['joinDate'] as Timestamp).toDate()
          : map['joinDate'] is String
              ? DateTime.parse(map['joinDate'] as String)
              : null,
      dateOfBirth: map['dateOfBirth'] is Timestamp
          ? (map['dateOfBirth'] as Timestamp).toDate()
          : map['dateOfBirth'] is String
              ? DateTime.parse(map['dateOfBirth'] as String)
              : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'organizationId': organizationId,
      'counselorIds': counselorIds,
      'aliasCode': aliasCode,
      'gender': gender,
      'createdAt': Timestamp.fromDate(createdAt),
      if (joinDate != null) 'joinDate': Timestamp.fromDate(joinDate!),
      if (dateOfBirth != null) 'dateOfBirth': Timestamp.fromDate(dateOfBirth!),
    };
  }
}
