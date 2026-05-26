// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Auth)
final authProvider = AuthProvider._();

final class AuthProvider extends $NotifierProvider<Auth, AuthState> {
  AuthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authHash();

  @$internal
  @override
  Auth create() => Auth();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthState>(value),
    );
  }
}

String _$authHash() => r'533e9211d1d9fcc5a437af7ceb5cf7f874fecf5a';

abstract class _$Auth extends $Notifier<AuthState> {
  AuthState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AuthState, AuthState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AuthState, AuthState>,
              AuthState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(organizations)
final organizationsProvider = OrganizationsProvider._();

final class OrganizationsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Organization>>,
          List<Organization>,
          FutureOr<List<Organization>>
        >
    with
        $FutureModifier<List<Organization>>,
        $FutureProvider<List<Organization>> {
  OrganizationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'organizationsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$organizationsHash();

  @$internal
  @override
  $FutureProviderElement<List<Organization>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Organization>> create(Ref ref) {
    return organizations(ref);
  }
}

String _$organizationsHash() => r'0e19f1581e3b28b620024826c674e8a61812519a';
