import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/client.dart';
import '../../data/client_repository.dart';
import '/features/auth/presentation/providers/auth_providers.dart';

part 'clients_provider.g.dart';

@riverpod
class Clients extends _$Clients {
  @override
  Stream<List<Client>> build() {
    final authState = ref.watch(authProvider);
    final organizationId = authState.organizationId;
    final uid = authState.uid;

    if (organizationId == null || uid == null) {
      return Stream.value([]);
    }

    return ref.read(clientRepositoryProvider).watchClients(organizationId, uid);
  }

  Future<void> addClient(String aliasCode, String gender, {DateTime? joinDate, DateTime? dateOfBirth}) async {
    final authState = ref.read(authProvider);
    final orgId = authState.organizationId;
    final uid = authState.uid;

    if (orgId == null || uid == null) {
      throw Exception('User information not found. Please try again.');
    }

    final newClient = Client(
      id: '', // Firestore will generate this
      organizationId: orgId,
      counselorIds: [uid],
      aliasCode: aliasCode,
      gender: gender,
      createdAt: DateTime.now(),
      joinDate: joinDate,
      dateOfBirth: dateOfBirth,
    );

    await ref.read(clientRepositoryProvider).addClient(newClient);
  }
}
