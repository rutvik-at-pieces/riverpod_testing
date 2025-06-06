// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'main.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

@ProviderFor(listItems)
const listItemsProvider = ListItemsProvider._();

final class ListItemsProvider
    extends $FunctionalProvider<ListItemsStateNotifier, ListItemsStateNotifier>
    with $Provider<ListItemsStateNotifier> {
  const ListItemsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'listItemsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$listItemsHash();

  @$internal
  @override
  $ProviderElement<ListItemsStateNotifier> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ListItemsStateNotifier create(Ref ref) {
    return listItems(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ListItemsStateNotifier value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $ValueProvider<ListItemsStateNotifier>(value),
    );
  }
}

String _$listItemsHash() => r'b613d66fa48041ca74f6e76f2738d8e48dcb7e5a';

@ProviderFor(storage)
const storageProvider = StorageProvider._();

final class StorageProvider extends $FunctionalProvider<
        AsyncValue<JsonSqFliteStorage>, FutureOr<JsonSqFliteStorage>>
    with
        $FutureModifier<JsonSqFliteStorage>,
        $FutureProvider<JsonSqFliteStorage> {
  const StorageProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'storageProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$storageHash();

  @$internal
  @override
  $FutureProviderElement<JsonSqFliteStorage> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<JsonSqFliteStorage> create(Ref ref) {
    return storage(ref);
  }
}

String _$storageHash() => r'559c9d2d99049c949b2c95539dced642767a8a4b';

@ProviderFor(TodosNotifier)
@JsonPersist()
const todosNotifierProvider = TodosNotifierProvider._();

final class TodosNotifierProvider
    extends $AsyncNotifierProvider<TodosNotifier, List<Todo>> {
  const TodosNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'todosNotifierProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$todosNotifierHash();

  @$internal
  @override
  TodosNotifier create() => TodosNotifier();

  @$internal
  @override
  _$TodosNotifierElement $createElement($ProviderPointer pointer) =>
      _$TodosNotifierElement(pointer);

  ProviderListenable<TodosNotifier$Add> get add =>
      $LazyProxyListenable<TodosNotifier$Add, AsyncValue<List<Todo>>>(
        this,
        (element) {
          element as _$TodosNotifierElement;

          return element._$add;
        },
      );
}

String _$todosNotifierHash() => r'48b84d84f4de243c135281bf352bf3944be1a2ff';

abstract class _$TodosNotifierBase extends $AsyncNotifier<List<Todo>> {
  FutureOr<List<Todo>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<List<Todo>>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<Todo>>>,
        AsyncValue<List<Todo>>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}

class _$TodosNotifierElement
    extends $AsyncNotifierProviderElement<TodosNotifier, List<Todo>> {
  _$TodosNotifierElement(super.pointer) {
    _$add.result = $Result.data(_$TodosNotifier$Add(this));
  }
  final _$add = $ElementLense<_$TodosNotifier$Add>();
  @override
  void mount() {
    super.mount();
    _$add.result!.value!.reset();
  }

  @override
  void visitListenables(
    void Function($ElementLense element) listenableVisitor,
  ) {
    super.visitListenables(listenableVisitor);

    listenableVisitor(_$add);
  }
}

sealed class TodosNotifier$Add extends MutationBase<void> {
  /// Starts the mutation.
  ///
  /// This will first set the state to [PendingMutation], then
  /// will call [TodosNotifier.add] with the provided parameters.
  ///
  /// After the method completes, the mutation state will be updated to either
  /// [SuccessMutation] or [ErrorMutation] based on if the method
  /// threw or not.
  ///
  /// **Note**:
  /// If the notifier threw in its constructor, the mutation won't start
  /// and [call] will throw.
  /// This should generally never happen though, as Notifiers are not supposed
  /// to have logic in their constructors.
  Future<void> call(Todo todo);
}

final class _$TodosNotifier$Add
    extends $AsyncMutationBase<void, _$TodosNotifier$Add, TodosNotifier>
    implements TodosNotifier$Add {
  _$TodosNotifier$Add(this.element, {super.state, super.key});

  @override
  final _$TodosNotifierElement element;

  @override
  $ElementLense<_$TodosNotifier$Add> get listenable => element._$add;

  @override
  Future<void> call(Todo todo) {
    return mutate(
      Invocation.method(
        #add,
        [todo],
      ),
      ($notifier) => $notifier.add(
        todo,
      ),
    );
  }

  @override
  _$TodosNotifier$Add copyWith(MutationState<void> state, {Object? key}) =>
      _$TodosNotifier$Add(element, state: state, key: key);
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

// **************************************************************************
// JsonGenerator
// **************************************************************************

abstract class _$TodosNotifier extends _$TodosNotifierBase
    with Persistable<List<Todo>, String, String> {
  @override
  FutureOr<void> persist({
    String? key,
    required FutureOr<Storage<String, String>> storage,
    String Function(List<Todo> state)? encode,
    List<Todo> Function(String encoded)? decode,
    StorageOptions options = const StorageOptions(),
  }) {
    const resolvedKey = "TodosNotifier";

    return super.persist(
      key: key ?? resolvedKey,
      storage: storage,
      encode: encode ?? (value) => $jsonCodex.encode(state.requireValue),
      decode: decode ??
          (encoded) {
            final e = $jsonCodex.decode(encoded);
            return (e as List)
                .map((e) => Todo.fromJson(e as Map<String, Object?>))
                .toList();
          },
      options: options,
    );
  }
}
