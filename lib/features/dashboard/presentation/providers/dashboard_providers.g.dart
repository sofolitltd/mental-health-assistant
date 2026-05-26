// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(allSessions)
final allSessionsProvider = AllSessionsProvider._();

final class AllSessionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Session>>,
          List<Session>,
          FutureOr<List<Session>>
        >
    with $FutureModifier<List<Session>>, $FutureProvider<List<Session>> {
  AllSessionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allSessionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allSessionsHash();

  @$internal
  @override
  $FutureProviderElement<List<Session>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Session>> create(Ref ref) {
    return allSessions(ref);
  }
}

String _$allSessionsHash() => r'705f491bb7e20672812d4df2e87b99203b7d2414';

@ProviderFor(allAssessmentSessions)
final allAssessmentSessionsProvider = AllAssessmentSessionsProvider._();

final class AllAssessmentSessionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AssessmentSession>>,
          List<AssessmentSession>,
          FutureOr<List<AssessmentSession>>
        >
    with
        $FutureModifier<List<AssessmentSession>>,
        $FutureProvider<List<AssessmentSession>> {
  AllAssessmentSessionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allAssessmentSessionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allAssessmentSessionsHash();

  @$internal
  @override
  $FutureProviderElement<List<AssessmentSession>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<AssessmentSession>> create(Ref ref) {
    return allAssessmentSessions(ref);
  }
}

String _$allAssessmentSessionsHash() =>
    r'efc39221a2332ff6e20b3f36e45fdae57f5f90b4';

@ProviderFor(dashboardData)
final dashboardDataProvider = DashboardDataProvider._();

final class DashboardDataProvider
    extends
        $FunctionalProvider<
          AsyncValue<DashboardData>,
          DashboardData,
          FutureOr<DashboardData>
        >
    with $FutureModifier<DashboardData>, $FutureProvider<DashboardData> {
  DashboardDataProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dashboardDataProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dashboardDataHash();

  @$internal
  @override
  $FutureProviderElement<DashboardData> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DashboardData> create(Ref ref) {
    return dashboardData(ref);
  }
}

String _$dashboardDataHash() => r'395b718cebe3fcc9e13720296615c80e44e25250';
