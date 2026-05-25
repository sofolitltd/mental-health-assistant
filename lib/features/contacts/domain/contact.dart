class Contact {
  final String id;
  final String clientId;
  final String clientAlias;
  final String name;
  final String designation;
  final String phone;
  final String? altPhone;
  final String email;
  final DateTime createdAt;

  const Contact({
    required this.id,
    required this.clientId,
    required this.clientAlias,
    required this.name,
    required this.designation,
    required this.phone,
    this.altPhone,
    required this.email,
    required this.createdAt,
  });

  Contact copyWith({
    String? id,
    String? clientId,
    String? clientAlias,
    String? name,
    String? designation,
    String? phone,
    String? altPhone,
    String? email,
    DateTime? createdAt,
  }) {
    return Contact(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      clientAlias: clientAlias ?? this.clientAlias,
      name: name ?? this.name,
      designation: designation ?? this.designation,
      phone: phone ?? this.phone,
      altPhone: altPhone ?? this.altPhone,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'clientId': clientId,
        'clientAlias': clientAlias,
        'name': name,
        'designation': designation,
        'phone': phone,
        if (altPhone != null) 'altPhone': altPhone,
        'email': email,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Contact.fromMap(Map<String, dynamic> map, String id) => Contact(
        id: id,
        clientId: map['clientId'] as String,
        clientAlias: map['clientAlias'] as String? ?? '',
        name: map['name'] as String? ?? '',
        designation: map['designation'] as String? ?? '',
        phone: map['phone'] as String? ?? '',
        altPhone: map['altPhone'] as String?,
        email: map['email'] as String? ?? '',
        createdAt: DateTime.parse(map['createdAt'] as String),
      );
}
