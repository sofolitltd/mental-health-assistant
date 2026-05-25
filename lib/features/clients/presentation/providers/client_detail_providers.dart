import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/models/client.dart';
import '../../domain/session.dart';
import '../../data/session_repository.dart';
import 'clients_provider.dart';

part 'client_detail_providers.g.dart';

@riverpod
Client? clientById(ref, String clientId) {
  final clientsAsync = ref.watch(clientsProvider);
  final clients = clientsAsync.value;
  if (clients == null) return null;
  
  for (final c in clients) {
    if (c.id == clientId) return c;
  }
  return null;
}

@riverpod
SessionRepository sessionRepository(ref) {
  return SessionRepository();
}

@riverpod
Stream<List<Session>> clientSessions(ref, String clientId) {
  final repository = ref.watch(sessionRepositoryProvider);
  return repository.watchSessionsByClientId(clientId);
}
