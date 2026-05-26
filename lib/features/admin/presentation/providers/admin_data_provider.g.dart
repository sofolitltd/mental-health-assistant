// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_data_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(adminEffectiveOrgId)
final adminEffectiveOrgIdProvider = AdminEffectiveOrgIdProvider._();

final class AdminEffectiveOrgIdProvider
    extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
  AdminEffectiveOrgIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminEffectiveOrgIdProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminEffectiveOrgIdHash();

  @$internal
  @override
  $ProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String? create(Ref ref) {
    return adminEffectiveOrgId(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$adminEffectiveOrgIdHash() =>
    r'8d96ddca71e0fc7b3f0556d23df7e9c355772b8f';

@ProviderFor(adminFilteredClients)
final adminFilteredClientsProvider = AdminFilteredClientsProvider._();

final class AdminFilteredClientsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Client>>,
          List<Client>,
          FutureOr<List<Client>>
        >
    with $FutureModifier<List<Client>>, $FutureProvider<List<Client>> {
  AdminFilteredClientsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminFilteredClientsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminFilteredClientsHash();

  @$internal
  @override
  $FutureProviderElement<List<Client>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Client>> create(Ref ref) {
    return adminFilteredClients(ref);
  }
}

String _$adminFilteredClientsHash() =>
    r'b6c98d25e649247bb78d37ac2c4ba43c51e825dc';

@ProviderFor(AdminDashboardData)
final adminDashboardDataProvider = AdminDashboardDataProvider._();

final class AdminDashboardDataProvider
    extends $AsyncNotifierProvider<AdminDashboardData, AdminDashboardStats> {
  AdminDashboardDataProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminDashboardDataProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminDashboardDataHash();

  @$internal
  @override
  AdminDashboardData create() => AdminDashboardData();
}

String _$adminDashboardDataHash() =>
    r'64c5ee69249e19954b788b47f6444a0d96070db6';

abstract class _$AdminDashboardData
    extends $AsyncNotifier<AdminDashboardStats> {
  FutureOr<AdminDashboardStats> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<AdminDashboardStats>, AdminDashboardStats>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AdminDashboardStats>, AdminDashboardStats>,
              AsyncValue<AdminDashboardStats>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
