class Counselor {
  final String id;
  final String organizationId;
  final String employeeId;
  final String designation;
  final String name;
  final String phone;
  final String email;

  const Counselor({
    required this.id,
    required this.organizationId,
    required this.employeeId,
    required this.designation,
    required this.name,
    required this.phone,
    required this.email,
  });

  factory Counselor.fromMap(Map<String, dynamic> map, String id) => Counselor(
        id: id,
        organizationId: map['organizationId'] as String? ?? '',
        employeeId: map['employeeId'] as String? ?? '',
        designation: map['designation'] as String? ?? '',
        name: map['name'] as String? ?? '',
        phone: map['phone'] as String? ?? '',
        email: map['email'] as String? ?? '',
      );
}
