class AuthState {
  final bool isAuthenticated;
  final String? uid;
  final String? email;
  final String? name;
  final String? phone;
  final String? designation;
  final String? employeeId;
  final String? organizationId;
  final DateTime? joinedAt;
  final bool isLoading;
  final String? error;

  AuthState({
    this.isAuthenticated = false,
    this.uid,
    this.email,
    this.name,
    this.phone,
    this.designation,
    this.employeeId,
    this.organizationId,
    this.joinedAt,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    String? uid,
    String? email,
    String? name,
    String? phone,
    String? designation,
    String? employeeId,
    String? organizationId,
    DateTime? joinedAt,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      designation: designation ?? this.designation,
      employeeId: employeeId ?? this.employeeId,
      organizationId: organizationId ?? this.organizationId,
      joinedAt: joinedAt ?? this.joinedAt,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
