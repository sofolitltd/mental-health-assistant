import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/organization.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository());

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<List<Organization>> getOrganizations() async {
    try {
      final snapshot = await _firestore.collection('organizations').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Organization(
          id: doc.id,
          name: data['name'] ?? '',
          code: data['code'],
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
}
