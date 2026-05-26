import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../domain/models/organization.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository());

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const _apiKey = 'AIzaSyD4mQDU_rcIKEA_Hl7OlvewM7zRA33xbuk';

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<List<Organization>> getOrganizations() async {
    try {
      final snapshot = await _firestore.collection('organizations').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        final ts = data['createdAt'];
        return Organization(
          id: doc.id,
          name: data['name'] ?? '',
          code: data['code'],
          createdAt: ts is Timestamp ? ts.toDate() : null,
        );
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> register({
    required String organizationId,
    required String employeeId,
    required String designation,
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        await _firestore.collection('counselors').doc(user.uid).set({
          'organizationId': organizationId,
          'employeeId': employeeId,
          'designation': designation,
          'name': name,
          'phone': phone,
          'email': email,
          'uid': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
        });
        return true;
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw Exception('No authenticated user.');
    }
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }

  Future<bool> adminCreateCounselor({
    required String organizationId,
    required String employeeId,
    required String designation,
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'returnSecureToken': false,
        }),
      );

      if (response.statusCode != 200) {
        final err = jsonDecode(response.body)['error'] as Map?;
        final message = err?['message'] as String? ?? 'Failed to create account';
        if (message == 'EMAIL_EXISTS') {
          throw Exception('A user with this email already exists.');
        }
        throw Exception(message);
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final uid = data['localId'] as String;

      await _firestore.collection('counselors').doc(uid).set({
        'organizationId': organizationId,
        'employeeId': employeeId,
        'designation': designation,
        'name': name,
        'phone': phone,
        'email': email,
        'uid': uid,
        'password': password,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> adminDeleteCounselor(String uid) async {
    final doc = await _firestore.collection('counselors').doc(uid).get();
    if (!doc.exists) throw Exception('Counselor not found.');

    final email = doc.data()?['email'] as String? ?? '';
    final password = doc.data()?['password'] as String? ?? '';

    if (email.isNotEmpty && password.isNotEmpty) {
      final signInRes = await http.post(
        Uri.parse('https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }),
      );

      if (signInRes.statusCode == 200) {
        final idToken = jsonDecode(signInRes.body)['idToken'] as String;
        await http.post(
          Uri.parse('https://identitytoolkit.googleapis.com/v1/accounts:delete?key=$_apiKey'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'idToken': idToken}),
        );
      }
    }

    await _firestore.collection('counselors').doc(uid).delete();
  }

  Future<String> createOrganization(String name, String? code) async {
    final doc = await _firestore.collection('organizations').add({
      'name': name,
      'code': code,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  Future<void> updateOrganization(String id, String name, String? code) async {
    await _firestore.collection('organizations').doc(id).update({
      'name': name,
      if (code != null) 'code': code,
    });
  }

  Future<void> deleteOrganization(String id) async {
    await _firestore.collection('organizations').doc(id).delete();
  }

  Future<List<Map<String, dynamic>>> getAdmins() async {
    try {
      final snapshot = await _firestore.collection('admins').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> createAdmin({
    required String name,
    required String email,
    required String password,
    required String organizationId,
    required String role,
  }) async {
    await _firestore.collection('admins').add({
      'name': name,
      'email': email,
      'password': password,
      'organizationId': organizationId,
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateAdmin({
    required String id,
    required String name,
    required String email,
    required String organizationId,
    required String role,
  }) async {
    await _firestore.collection('admins').doc(id).update({
      'name': name,
      'email': email,
      'organizationId': organizationId,
      'role': role,
    });
  }

  Future<void> deleteAdmin(String id) async {
    await _firestore.collection('admins').doc(id).delete();
  }

  Future<void> changeAdminPassword({
    required String adminDocId,
    required String currentPassword,
    required String newPassword,
  }) async {
    final doc = await _firestore.collection('admins').doc(adminDocId).get();
    if (!doc.exists) throw Exception('Admin not found.');
    final storedPassword = doc.data()?['password'] as String? ?? '';
    if (storedPassword != currentPassword) {
      throw Exception('Current password is incorrect.');
    }
    await _firestore.collection('admins').doc(adminDocId).update({
      'password': newPassword,
    });
  }
}
