// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clients_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Clients)
final clientsProvider = ClientsProvider._();

final class ClientsProvider
    extends $StreamNotifierProvider<Clients, List<Client>> {
  ClientsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clientsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clientsHash();

  @$internal
  @override
  Clients create() => Clients();
}

String _$clientsHash() => r'743b894eff92b76a4b60e1c87f0fc1d3c6310438';

abstract class _$Clients extends $StreamNotifier<List<Client>> {
  Stream<List<Client>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Client>>, List<Client>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Client>>, List<Client>>,
              AsyncValue<List<Client>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
