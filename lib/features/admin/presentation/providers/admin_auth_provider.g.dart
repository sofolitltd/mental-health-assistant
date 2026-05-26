// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AdminAuth)
final adminAuthProvider = AdminAuthProvider._();

final class AdminAuthProvider extends $AsyncNotifierProvider<AdminAuth, bool> {
  AdminAuthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminAuthProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminAuthHash();

  @$internal
  @override
  AdminAuth create() => AdminAuth();
}

String _$adminAuthHash() => r'58c7ea4a4283ffb2445a717ea481208dfb12a526';

abstract class _$AdminAuth extends $AsyncNotifier<bool> {
  FutureOr<bool> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(AdminOrganizationId)
final adminOrganizationIdProvider = AdminOrganizationIdProvider._();

final class AdminOrganizationIdProvider
    extends $AsyncNotifierProvider<AdminOrganizationId, String> {
  AdminOrganizationIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminOrganizationIdProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminOrganizationIdHash();

  @$internal
  @override
  AdminOrganizationId create() => AdminOrganizationId();
}

String _$adminOrganizationIdHash() =>
    r'd0b96861412dae8bc8c134f477b6738d188eec5c';

abstract class _$AdminOrganizationId extends $AsyncNotifier<String> {
  FutureOr<String> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<String>, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<String>, String>,
              AsyncValue<String>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(AdminRole)
final adminRoleProvider = AdminRoleProvider._();

final class AdminRoleProvider
    extends $AsyncNotifierProvider<AdminRole, String> {
  AdminRoleProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminRoleProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminRoleHash();

  @$internal
  @override
  AdminRole create() => AdminRole();
}

String _$adminRoleHash() => r'c1aa80322607caa5ee9591cf979f92584bd0e305';

abstract class _$AdminRole extends $AsyncNotifier<String> {
  FutureOr<String> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<String>, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<String>, String>,
              AsyncValue<String>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(AdminDocId)
final adminDocIdProvider = AdminDocIdProvider._();

final class AdminDocIdProvider
    extends $AsyncNotifierProvider<AdminDocId, String> {
  AdminDocIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminDocIdProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminDocIdHash();

  @$internal
  @override
  AdminDocId create() => AdminDocId();
}

String _$adminDocIdHash() => r'bcba03c95204b00bcfc0269fc7af414198a042bb';

abstract class _$AdminDocId extends $AsyncNotifier<String> {
  FutureOr<String> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<String>, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<String>, String>,
              AsyncValue<String>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(adminProfile)
final adminProfileProvider = AdminProfileProvider._();

final class AdminProfileProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, dynamic>?>,
          Map<String, dynamic>?,
          FutureOr<Map<String, dynamic>?>
        >
    with
        $FutureModifier<Map<String, dynamic>?>,
        $FutureProvider<Map<String, dynamic>?> {
  AdminProfileProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminProfileProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminProfileHash();

  @$internal
  @override
  $FutureProviderElement<Map<String, dynamic>?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, dynamic>?> create(Ref ref) {
    return adminProfile(ref);
  }
}

String _$adminProfileHash() => r'13cef2f1d688859d492bdf47e4e7028c7f5364c9';
