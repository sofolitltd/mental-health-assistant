import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../domain/contact.dart';

class ContactRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _contacts => _firestore.collection('contacts');

  Future<void> addContact(Contact contact) async {
    await _contacts.add(contact.toMap());
  }

  Future<void> updateContact(Contact contact) async {
    await _contacts.doc(contact.id).update(contact.toMap());
  }

  Future<void> deleteContact(String id) async {
    await _contacts.doc(id).delete();
  }

  Stream<List<Contact>> watchContactsByClientId(String clientId) {
    return _contacts
        .where('clientId', isEqualTo: clientId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Contact.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList())
        .handleError((error) {
          debugPrint('═══ Firestore Index Required ═══');
          debugPrint('$error');
          debugPrint('════════════════════════════════');
        });
  }

  Stream<List<Contact>> watchAllContacts() {
    return _contacts
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Contact.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList())
        .handleError((error) {
          debugPrint('═══ Firestore Error ═══');
          debugPrint('$error');
          debugPrint('═══════════════════════');
        });
  }
}
