import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/counselor.dart';

class CounselorRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Counselor>> watchAllCounselors() {
    return _firestore
        .collection('counselors')
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                Counselor.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> updateCounselor({
    required String uid,
    required String name,
    required String designation,
    required String employeeId,
    required String phone,
  }) async {
    await _firestore.collection('counselors').doc(uid).update({
      'name': name,
      'designation': designation,
      'employeeId': employeeId,
      'phone': phone,
    });
  }
}
