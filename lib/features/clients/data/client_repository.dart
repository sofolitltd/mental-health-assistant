import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/client.dart';

final clientRepositoryProvider = Provider((ref) => ClientRepository());

class ClientRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ClientRepository() {
    debugPrint(
      'Firebase composite index needed for sorted clients query:\n'
      'Collection: clients\n'
      'Fields: organizationId (Ascending), counselorIds (Array), joinDate (Descending)\n'
      'Create at: https://console.firebase.google.com/project/_/firestore/indexes',
    );
  }

  Future<List<Client>> getClients(String organizationId, String uid) async {
    final snapshot = await _firestore
        .collection('clients')
        .where('organizationId', isEqualTo: organizationId)
        .where('counselorIds', arrayContains: uid)
        .get();

    return snapshot.docs
        .map((doc) => Client.fromMap(doc.data(), doc.id))
        .toList();
  }

  Stream<List<Client>> watchClients(String organizationId, String uid) {
    return _firestore
        .collection('clients')
        .where('organizationId', isEqualTo: organizationId)
        .where('counselorIds', arrayContains: uid)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Client.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> addClient(Client client) async {
    final data = client.toMap();
    data['createdAt'] = FieldValue.serverTimestamp();
    await _firestore.collection('clients').add(data);
  }

  Future<void> updateClient(Client client) async {
    await _firestore
        .collection('clients')
        .doc(client.id)
        .update(client.toMap());
  }

  Future<void> deleteClient(String clientId) async {
    await _firestore.collection('clients').doc(clientId).delete();
  }
}
