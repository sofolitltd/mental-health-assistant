import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/contact.dart';
import '../../domain/counselor.dart';
import '../../data/contact_repository.dart';
import '../../data/counselor_repository.dart';

part 'contacts_providers.g.dart';

@riverpod
ContactRepository contactRepository(ref) {
  return ContactRepository();
}

@riverpod
Stream<List<Contact>> clientContacts(ref, String clientId) {
  final repository = ref.watch(contactRepositoryProvider);
  return repository.watchContactsByClientId(clientId).handleError((_) => <Contact>[]);
}

@riverpod
Stream<List<Contact>> allContacts(ref) {
  final repository = ref.watch(contactRepositoryProvider);
  return repository.watchAllContacts().handleError((_) => <Contact>[]);
}

@riverpod
CounselorRepository counselorRepository(ref) {
  return CounselorRepository();
}

@riverpod
Stream<List<Counselor>> allCounselors(ref) {
  final repository = ref.watch(counselorRepositoryProvider);
  return repository.watchAllCounselors().handleError((_) => <Counselor>[]);
}
