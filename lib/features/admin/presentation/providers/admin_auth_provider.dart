import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'admin_auth_provider.g.dart';

const _adminSessionKey = 'is_admin';
const _adminOrgIdKey = 'admin_org_id';
const _adminRoleKey = 'admin_role';
const _adminDocIdKey = 'admin_doc_id';
const _adminOrgFilterKey = 'admin_org_filter';

@Riverpod(keepAlive: true)
class AdminAuth extends _$AdminAuth {
  @override
  FutureOr<bool> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_adminSessionKey) ?? false;
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('admins')
          .where('email', isEqualTo: email)
          .get();

      if (snapshot.docs.isEmpty) {
        throw Exception('Invalid credentials');
      }

      final doc = snapshot.docs.first;
      final storedPassword = doc['password'] as String;

      if (storedPassword != password) {
        throw Exception('Invalid credentials');
      }

      final orgId = doc['organizationId'] as String? ?? '';
      final role = doc['role'] as String? ?? 'admin';

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_adminSessionKey, true);
      await prefs.setString(_adminDocIdKey, doc.id);
      if (orgId.isNotEmpty) {
        await prefs.setString(_adminOrgIdKey, orgId);
      }
      await prefs.setString(_adminRoleKey, role);
      state = const AsyncData(true);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_adminSessionKey, false);
    await prefs.remove(_adminOrgIdKey);
    await prefs.remove(_adminRoleKey);
    await prefs.remove(_adminDocIdKey);
    await prefs.remove(_adminOrgFilterKey);
    AdminOrgFilterCache.value = null;
    state = const AsyncData(false);
  }
}

@Riverpod(keepAlive: true)
class AdminOrganizationId extends _$AdminOrganizationId {
  @override
  FutureOr<String> build() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_adminOrgIdKey) ?? '';
    } catch (_) {
      return '';
    }
  }
}

@Riverpod(keepAlive: true)
class AdminRole extends _$AdminRole {
  @override
  FutureOr<String> build() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_adminRoleKey) ?? 'admin';
    } catch (_) {
      return 'admin';
    }
  }
}

@Riverpod(keepAlive: true)
class AdminDocId extends _$AdminDocId {
  @override
  FutureOr<String> build() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_adminDocIdKey) ?? '';
    } catch (_) {
      return '';
    }
  }
}

@riverpod
Future<Map<String, dynamic>?> adminProfile(Ref ref) async {
  try {
    final docId = ref.watch(adminDocIdProvider).asData?.value ?? '';
    if (docId.isEmpty) return null;
    final doc = await FirebaseFirestore.instance.collection('admins').doc(docId).get();
    return doc.data();
  } catch (_) {
    return null;
  }
}

class AdminOrgFilterCache {
  static String? value;
}

class _AdminOrgFilter extends Notifier<String?> {
  @override
  String? build() => AdminOrgFilterCache.value;

  Future<void> setOrg(String? orgId) async {
    state = orgId;
    AdminOrgFilterCache.value = orgId;
    final prefs = await SharedPreferences.getInstance();
    if (orgId != null) {
      await prefs.setString(_adminOrgFilterKey, orgId);
    } else {
      await prefs.remove(_adminOrgFilterKey);
    }
  }
}

final adminOrgFilterProvider = NotifierProvider<_AdminOrgFilter, String?>(_AdminOrgFilter.new);
