// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_detail_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(clientById)
final clientByIdProvider = ClientByIdFamily._();

final class ClientByIdProvider
    extends $FunctionalProvider<Client?, Client?, Client?>
    with $Provider<Client?> {
  ClientByIdProvider._({
    required ClientByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'clientByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$clientByIdHash();

  @override
  String toString() {
    return r'clientByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<Client?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Client? create(Ref ref) {
    final argument = this.argument as String;
    return clientById(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Client? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Client?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ClientByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$clientByIdHash() => r'946adc836ae7f7d0dcad101e036da9451ad06f5a';

final class ClientByIdFamily extends $Family
    with $FunctionalFamilyOverride<Client?, String> {
  ClientByIdFamily._()
    : super(
        retry: null,
        name: r'clientByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ClientByIdProvider call(String clientId) =>
      ClientByIdProvider._(argument: clientId, from: this);

  @override
  String toString() => r'clientByIdProvider';
}

@ProviderFor(sessionRepository)
final sessionRepositoryProvider = SessionRepositoryProvider._();

final class SessionRepositoryProvider
    extends
        $FunctionalProvider<
          SessionRepository,
          SessionRepository,
          SessionRepository
        >
    with $Provider<SessionRepository> {
  SessionRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionRepositoryHash();

  @$internal
  @override
  $ProviderElement<SessionRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SessionRepository create(Ref ref) {
    return sessionRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SessionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SessionRepository>(value),
    );
  }
}

String _$sessionRepositoryHash() => r'8d11fddb1db6b47173eadbae0eb08f07cf86dfbb';

@ProviderFor(clientSessions)
final clientSessionsProvider = ClientSessionsFamily._();

final class ClientSessionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Session>>,
          List<Session>,
          Stream<List<Session>>
        >
    with $FutureModifier<List<Session>>, $StreamProvider<List<Session>> {
  ClientSessionsProvider._({
    required ClientSessionsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'clientSessionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$clientSessionsHash();

  @override
  String toString() {
    return r'clientSessionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Session>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Session>> create(Ref ref) {
    final argument = this.argument as String;
    return clientSessions(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ClientSessionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$clientSessionsHash() => r'af5e3c068760d0f9c9a691381fa828bd3d642fe7';

final class ClientSessionsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Session>>, String> {
  ClientSessionsFamily._()
    : super(
        retry: null,
        name: r'clientSessionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ClientSessionsProvider call(String clientId) =>
      ClientSessionsProvider._(argument: clientId, from: this);

  @override
  String toString() => r'clientSessionsProvider';
}
