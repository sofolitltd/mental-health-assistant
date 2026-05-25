// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assessment_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Assessment)
final assessmentProvider = AssessmentProvider._();

final class AssessmentProvider
    extends $NotifierProvider<Assessment, AssessmentState> {
  AssessmentProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'assessmentProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$assessmentHash();

  @$internal
  @override
  Assessment create() => Assessment();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AssessmentState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AssessmentState>(value),
    );
  }
}

String _$assessmentHash() => r'c0df9a56552dfdf1c3d5aab117f33641aab9ea48';

abstract class _$Assessment extends $Notifier<AssessmentState> {
  AssessmentState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AssessmentState, AssessmentState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AssessmentState, AssessmentState>,
              AssessmentState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
