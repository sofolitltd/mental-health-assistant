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
    Object? uid = _unset,
    Object? email = _unset,
    Object? name = _unset,
    Object? phone = _unset,
    Object? designation = _unset,
    Object? employeeId = _unset,
    Object? organizationId = _unset,
    Object? joinedAt = _unset,
    bool? isLoading,
    Object? error = _unset,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      uid: identical(uid, _unset) ? this.uid : uid as String?,
      email: identical(email, _unset) ? this.email : email as String?,
      name: identical(name, _unset) ? this.name : name as String?,
      phone: identical(phone, _unset) ? this.phone : phone as String?,
      designation: identical(designation, _unset) ? this.designation : designation as String?,
      employeeId: identical(employeeId, _unset) ? this.employeeId : employeeId as String?,
      organizationId: identical(organizationId, _unset) ? this.organizationId : organizationId as String?,
      joinedAt: identical(joinedAt, _unset) ? this.joinedAt : joinedAt as DateTime?,
      isLoading: isLoading ?? this.isLoading,
      error: identical(error, _unset) ? this.error : error as String?,
    );
  }

  static const _unset = Object();
}
