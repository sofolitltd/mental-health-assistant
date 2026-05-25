// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assessment_session_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(assessmentSessionRepository)
final assessmentSessionRepositoryProvider =
    AssessmentSessionRepositoryProvider._();

final class AssessmentSessionRepositoryProvider
    extends
        $FunctionalProvider<
          AssessmentSessionRepository,
          AssessmentSessionRepository,
          AssessmentSessionRepository
        >
    with $Provider<AssessmentSessionRepository> {
  AssessmentSessionRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'assessmentSessionRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$assessmentSessionRepositoryHash();

  @$internal
  @override
  $ProviderElement<AssessmentSessionRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AssessmentSessionRepository create(Ref ref) {
    return assessmentSessionRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AssessmentSessionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AssessmentSessionRepository>(value),
    );
  }
}

String _$assessmentSessionRepositoryHash() =>
    r'5336c965ecbdbda767ca8746fb22a67baebc1e3e';
