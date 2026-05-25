import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/session.dart';
import '../../providers/client_detail_providers.dart';
import '../session_detail_screen.dart';

class SessionDetailLoader extends ConsumerWidget {
  final String sessionId;

  const SessionDetailLoader({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<Session?>(
      future: ref.read(sessionRepositoryProvider).getSessionById(sessionId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return const Scaffold(
            body: Center(child: Text('Session not found')),
          );
        }
        return SessionDetailScreen(session: snapshot.data!);
      },
    );
  }
}
