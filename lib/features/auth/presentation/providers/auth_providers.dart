import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/auth_repository.dart';
import '../../domain/models/auth_state.dart' show AuthState;
import '../../domain/models/organization.dart';

part 'auth_providers.g.dart';

@riverpod
class Auth extends _$Auth {
  @override
  AuthState build() {
    _init();
    return AuthState();
  }

  void _init() {
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user != null) {
        state = state.copyWith(
          isAuthenticated: true,
          uid: user.uid,
          email: user.email,
        );
        await _fetchUserInfo(user.uid);
      } else {
        state = AuthState();
      }
    });
  }

  Future<void> _fetchUserInfo(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('counselors')
          .doc(uid)
          .get();
      if (doc.exists) {
        final data = doc.data();
        state = state.copyWith(
          organizationId: data?['organizationId'],
          name: data?['name'],
          phone: data?['phone'],
          designation: data?['designation'],
          employeeId: data?['employeeId'],
          joinedAt: (data?['createdAt'] as dynamic)?.toDate(),
        );
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repository = ref.read(authRepositoryProvider);
      final success = await repository.login(email, password);
      if (!success) {
        state = state.copyWith(
          isLoading: false,
          error: 'Login failed. Please check your credentials.',
        );
      } else {
        state = state.copyWith(isLoading: false, error: null);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _formatError(e));
    }
  }

  Future<void> register({
    required String organizationId,
    required String employeeId,
    required String designation,
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repository = ref.read(authRepositoryProvider);
      final success = await repository.register(
        organizationId: organizationId,
        employeeId: employeeId,
        designation: designation,
        name: name,
        phone: phone,
        email: email,
        password: password,
      );
      if (!success) {
        state = state.copyWith(isLoading: false, error: 'Registration failed');
      } else {
        state = state.copyWith(isLoading: false, error: null);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _formatError(e));
    }
  }

  String _formatError(dynamic e) {
    if (e.toString().contains('user-not-found')) return 'No user found for that email.';
    if (e.toString().contains('wrong-password')) return 'Wrong password provided.';
    if (e.toString().contains('email-already-in-use')) return 'The account already exists for that email.';
    if (e.toString().contains('weak-password')) return 'The password provided is too weak.';
    return e.toString();
  }

  void updateProfile({
    required String name,
    required String employeeId,
    required String designation,
    required String phone,
  }) {
    state = state.copyWith(
      name: name,
      employeeId: employeeId,
      designation: designation,
      phone: phone,
    );
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await ref.read(authRepositoryProvider).changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = AuthState();
  }
}

@riverpod
Future<List<Organization>> organizations(Ref ref) async {
  return ref.watch(authRepositoryProvider).getOrganizations();
}
