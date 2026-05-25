// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assessment_session_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(clientAssessmentSessions)
final clientAssessmentSessionsProvider = ClientAssessmentSessionsFamily._();

final class ClientAssessmentSessionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AssessmentSession>>,
          List<AssessmentSession>,
          FutureOr<List<AssessmentSession>>
        >
    with
        $FutureModifier<List<AssessmentSession>>,
        $FutureProvider<List<AssessmentSession>> {
  ClientAssessmentSessionsProvider._({
    required ClientAssessmentSessionsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'clientAssessmentSessionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$clientAssessmentSessionsHash();

  @override
  String toString() {
    return r'clientAssessmentSessionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<AssessmentSession>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<AssessmentSession>> create(Ref ref) {
    final argument = this.argument as String;
    return clientAssessmentSessions(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ClientAssessmentSessionsProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$clientAssessmentSessionsHash() =>
    r'1751f4c1eb1c5a5cbb51e8e7060f6345dd9e1db3';

final class ClientAssessmentSessionsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<AssessmentSession>>, String> {
  ClientAssessmentSessionsFamily._()
    : super(
        retry: null,
        name: r'clientAssessmentSessionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ClientAssessmentSessionsProvider call(String clientId) =>
      ClientAssessmentSessionsProvider._(argument: clientId, from: this);

  @override
  String toString() => r'clientAssessmentSessionsProvider';
}
