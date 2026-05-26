// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contacts_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(contactRepository)
final contactRepositoryProvider = ContactRepositoryProvider._();

final class ContactRepositoryProvider
    extends
        $FunctionalProvider<
          ContactRepository,
          ContactRepository,
          ContactRepository
        >
    with $Provider<ContactRepository> {
  ContactRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'contactRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$contactRepositoryHash();

  @$internal
  @override
  $ProviderElement<ContactRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ContactRepository create(Ref ref) {
    return contactRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ContactRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ContactRepository>(value),
    );
  }
}

String _$contactRepositoryHash() => r'e3dd732abba8f645f073f9b051553af095b018fa';

@ProviderFor(clientContacts)
final clientContactsProvider = ClientContactsFamily._();

final class ClientContactsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Contact>>,
          List<Contact>,
          Stream<List<Contact>>
        >
    with $FutureModifier<List<Contact>>, $StreamProvider<List<Contact>> {
  ClientContactsProvider._({
    required ClientContactsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'clientContactsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$clientContactsHash();

  @override
  String toString() {
    return r'clientContactsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Contact>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Contact>> create(Ref ref) {
    final argument = this.argument as String;
    return clientContacts(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ClientContactsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$clientContactsHash() => r'bacc9bf25e6257630c83f777ee3ec27df15e6f40';

final class ClientContactsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Contact>>, String> {
  ClientContactsFamily._()
    : super(
        retry: null,
        name: r'clientContactsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ClientContactsProvider call(String clientId) =>
      ClientContactsProvider._(argument: clientId, from: this);

  @override
  String toString() => r'clientContactsProvider';
}

@ProviderFor(allContacts)
final allContactsProvider = AllContactsProvider._();

final class AllContactsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Contact>>,
          List<Contact>,
          Stream<List<Contact>>
        >
    with $FutureModifier<List<Contact>>, $StreamProvider<List<Contact>> {
  AllContactsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allContactsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allContactsHash();

  @$internal
  @override
  $StreamProviderElement<List<Contact>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Contact>> create(Ref ref) {
    return allContacts(ref);
  }
}

String _$allContactsHash() => r'c3e1facf514c1c1d8560882d859911ec99fe8009';

@ProviderFor(counselorRepository)
final counselorRepositoryProvider = CounselorRepositoryProvider._();

final class CounselorRepositoryProvider
    extends
        $FunctionalProvider<
          CounselorRepository,
          CounselorRepository,
          CounselorRepository
        >
    with $Provider<CounselorRepository> {
  CounselorRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'counselorRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$counselorRepositoryHash();

  @$internal
  @override
  $ProviderElement<CounselorRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CounselorRepository create(Ref ref) {
    return counselorRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CounselorRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CounselorRepository>(value),
    );
  }
}

String _$counselorRepositoryHash() =>
    r'a86bd8869d8a838ce5fb3f58e3d80b3def6a3250';

@ProviderFor(allCounselors)
final allCounselorsProvider = AllCounselorsProvider._();

final class AllCounselorsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Counselor>>,
          List<Counselor>,
          Stream<List<Counselor>>
        >
    with $FutureModifier<List<Counselor>>, $StreamProvider<List<Counselor>> {
  AllCounselorsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allCounselorsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allCounselorsHash();

  @$internal
  @override
  $StreamProviderElement<List<Counselor>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Counselor>> create(Ref ref) {
    return allCounselors(ref);
  }
}

String _$allCounselorsHash() => r'7fbd106c25767c40c33f47a0a566539d4bee3ab1';
