import 'package:core_openapi/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/experimental/persist.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:pieces_core_connector/pieces_core_connector.dart';
import 'package:riverpod_annotation/experimental/json_persist.dart';
import 'package:riverpod_annotation/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_sqflite/riverpod_sqflite.dart';
import 'package:runtime_client/foundation.dart';
import 'package:runtime_client/particle.dart';
import 'package:sqflite/sqflite.dart';

part 'main.g.dart';

late final Connector connectorApp;

void main() async {
  connectorApp = connector;
  await setupPiecesServices(
    // port: 39301,
    seededConnectorConnection: SeededConnectorConnection(
      application: SeededTrackedApplication(
        name: ApplicationNameEnum.gOOGLECHROMEEXTENSIONMV3,
        version: '2.9.8',
        platform: ParticlePlatform.isMacOS
            ? PlatformEnum.MACOS
            : ParticlePlatform.isWindows
                ? PlatformEnum.WINDOWS
                : ParticlePlatform.isLinux
                    ? PlatformEnum.LINUX
                    : PlatformEnum.UNKNOWN,
      ),
    ),
  );

  runApp(
    ProviderScope(child: MyApp()),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  final List<ListItemNotifier> _items = [
    ListItemNotifier(),
    ListItemNotifier(),
    ListItemNotifier(),
    ListItemNotifier(),
    ListItemNotifier(),
    ListItemNotifier(),
    ListItemNotifier(),
  ];

  @override
  Widget build(BuildContext context) {
    // final state = ref.watch(listItemsProvider);
    final todos = ref.watch(todosNotifierProvider);

    return ParticleAesthetics(
      builder: (context) {
        return MaterialApp(
            darkTheme: ParticleTheme.dark(context),
            themeMode: ThemeMode.dark,
            home: Scaffold(
                appBar: AppBar(
                  title: const Text('Example'),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        // Clear all data in the state and the DB
                        ref.read(todosNotifierProvider.notifier).clearAllData();
                      },
                    ),
                  ],
                ),
                floatingActionButton: Consumer(builder: (context, ref, _) {
                  final todoState = ref.watch(todosNotifierProvider.add);

                  print('Todo state: $todoState');

                  return switch (todoState.state) {
                    IdleMutation() => FloatingActionButton(
                        onPressed: () {
                          // state.insertItemInBetween();

                          // setState(() {
                          //   _items.add(ListItemNotifier());
                          // });

                          ref.read(todosNotifierProvider.notifier).add(
                                Todo(id: DateTime.now().millisecond, description: "Test", completed: false),
                              );
                        },
                        child: const Icon(Icons.add),
                      ),
                    PendingMutation() => const CircularProgressIndicator(),
                    ErrorMutation() => ElevatedButton(
                        onPressed: () {
                          // We can retry the side-effect by calling the mutation again
                          ref.read(todosNotifierProvider.add).call(
                                Todo(id: DateTime.now().millisecond, description: "Test", completed: false),
                              );
                        },
                        child: const Text('Retry'),
                      ),
                    SuccessMutation() => const Text('Todo added!'),
                  };
                }),
                body: //
                    Column(
                  children: [
                    Expanded(
                      child: todos.when(data: (todos) {
                        // Rebuilds enitire list on item updates.
                        return ListView.builder(
                          itemCount: todos.length,
                          itemBuilder: (context, index) {
                            final Todo todo = todos[index];

                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListTile(
                                title: Text("id ${todo.id}"),
                                subtitle: Text('Status: ${todo.completed}'),
                                trailing: Checkbox(
                                  value: todo.completed,
                                  onChanged: (value) {
                                    ref.read(todosNotifierProvider.notifier).updateTodo(
                                          Todo(
                                            id: todo.id,
                                            description: todo.description,
                                            completed: value ?? false,
                                          ),
                                        );
                                  },
                                ),
                              ),
                            );
                          },
                        );

                        // Rebuilds only the changed ui widget on item updates.

                        // return ListView.builder(
                        //   itemCount: todos.length,
                        //   itemBuilder: (context, index) {
                        //     final Todo todo = todos[index];
                        //     final TodoNotifierProvider todoNotifier = todoNotifierProvider(todo);
                        //     return Consumer(builder: (context, ref, _) {
                        //       final todoState = ref.watch(todoNotifier);

                        //       return Padding(
                        //         padding: const EdgeInsets.all(8.0),
                        //         child: ListTile(
                        //           title: Text(todoState.id.toString()),
                        //           subtitle: RepaintBoundary(
                        //             child: Consumer(builder: (context, ref, _) {
                        //               final status = ref.watch(todoNotifier.select((todo) => todo.completed));

                        //               return Text('Status: $status');
                        //             }),
                        //           ),
                        //           trailing: RepaintBoundary(
                        //             child: Consumer(builder: (context, ref, _) {
                        //               final status = ref.watch(todoNotifier.select((todo) => todo.completed));

                        //               return Checkbox(
                        //                 value: status,
                        //                 onChanged: (value) {
                        //                   ref.read(todoNotifier.notifier).updateTodo(
                        //                         Todo(
                        //                           id: todoState.id,
                        //                           description: todoState.description,
                        //                           completed: value ?? false,
                        //                         ),
                        //                       );
                        //                 },
                        //               );
                        //             }),
                        //           ),
                        //         ),
                        //       );
                        //     });
                        //   },
                        // );
                      }, error: (e, stk) {
                        return Center(
                          child: Text('Error: $e'),
                        );
                      }, loading: () {
                        return const Center(child: CircularProgressIndicator());
                      }),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                  ],
                )
                // ListView rebuilding - doesn't rebuilds items on scroll.

                // ListenableBuilder(
                //     listenable: state,
                //     builder: (context, _) {
                //       return ListView.builder(
                //         itemCount: state.items.length,
                //         itemBuilder: (context, index) {
                //           final item = state.items[index];

                //           // return item.widget;
                //           return ListItemBuilder(
                //             index: index,
                //             item: item,
                //           );
                //         },
                //       );
                //     }),

                // ListView rebuilding - all items rebuild on list items updates

                //     ListView.builder(
                //   itemCount: _items.length,
                //   itemBuilder: (context, index) {
                //     final item = _items[index];

                //     // return item.widget;
                //     return Padding(
                //       padding: const EdgeInsets.all(8.0),
                //       child: ListenableBuilder(
                //           listenable: item,
                //           builder: (context, _) {
                //             return FloatingActionButton(
                //               onPressed: () {
                //                 item.increment();
                //               },
                //               child: Text(
                //                 'Item $index: ${item.count}',
                //                 style: const TextStyle(fontSize: 24),
                //               ),
                //             );
                //           }),
                //     );
                //   },
                // ),
                ));
      },
    );
  }
}

class ListItemBuilder extends StatefulWidget {
  const ListItemBuilder({
    super.key,
    required this.index,
    required this.item,
  });

  final int index;
  final ListItemNotifier item;

  @override
  State<ListItemBuilder> createState() => _ListItemBuilderState();
}

class _ListItemBuilderState extends State<ListItemBuilder> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListenableBuilder(
          listenable: widget.item,
          builder: (context, _) {
            return FloatingActionButton(
              onPressed: () {
                widget.item.increment();
              },
              child: Text(
                'Item ${widget.index}: ${widget.item.count}',
                style: const TextStyle(fontSize: 24),
              ),
            );
          }),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

// final listItemsProvider = ChangeNotifierProvider<ListItemsStateNotifier>(
//   (ref) => ListItemsStateNotifier(),
// );

@riverpod
ListItemsStateNotifier listItems(Ref ref) {
  return ListItemsStateNotifier();
}

class ListItemsStateNotifier extends ChangeNotifier {
  List<ListItemNotifier> _items = [
    ListItemNotifier(),
    ListItemNotifier(),
    ListItemNotifier(),
    ListItemNotifier(),
    ListItemNotifier(),
    ListItemNotifier(),
    ListItemNotifier(),
  ];

  List<ListItemNotifier> get items => _items;

  void addItem() {
    final items = List<ListItemNotifier>.from(_items);
    items.add(ListItemNotifier());

    _items = items;

    notifyListeners();
  }

  void insertItemInBetween() {
    final items = List<ListItemNotifier>.from(_items);
    items.insert(3, ListItemNotifier(count: 10));

    _items = items;

    notifyListeners();
  }
}

class ListItemNotifier extends ChangeNotifier {
  ListItemNotifier({this.count = 0});

  int count = 0;

  void increment() {
    count++;
    notifyListeners();
  }
}

@riverpod
Future<JsonSqFliteStorage> storage(Ref ref) async {
  // Initialize SQFlite. We should share the Storage instance between providers.
  return JsonSqFliteStorage.open(
    join(await getDatabasesPath(), 'riverpod1.db'),
  );
}

/// A serializable Todo class. We're using Freezed for simple serialization.
class Todo {
  const Todo({
    required this.id,
    required this.description,
    required this.completed,
  });

  final int id;
  final String description;
  final bool completed;

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json["id"] as int,
      description: json["description"] as String,
      completed: json["completed"] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "description": description,
      "completed": completed,
    };
  }
}

@riverpod
@JsonPersist()
class TodosNotifier extends _$TodosNotifier {
  @override
  FutureOr<List<Todo>> build() async {
    // We call persist at the start of our 'build' method.
    // This will:
    // - Read the DB and update the state with the persisted value the first
    //   time this method executes.
    // - Listen to changes on this provider and write those changes to the DB.
    // We "await" for persist to complete to make sure that the decoding is done
    // before we return the state.
    await persist(
      // We pass our JsonSqFliteStorage instance. No need to "await" the Future.
      // Riverpod will take care of that.
      storage: ref.watch(storageProvider.future),
      // By default, state is cached offline only for 2 days.
      // In this example, we tell Riverpod to cache the state forever.
      options: const StorageOptions(cacheTime: StorageCacheTime.unsafe_forever),
    );

    return state.value ?? [];
  }

  @mutation
  Future<void> add(Todo todo) async {
    // When modifying the state, no need for any extra logic to persist the change.
    // Riverpod will automatically cache the new state and write it to the DB.
    state = AsyncData([...await future, todo]);
  }

  Future<void> updateTodo(Todo todo) async {
    // Update the todo in the state
    final todos = await future;
    final index = todos.indexWhere((t) => t.id == todo.id);
    if (index != -1) {
      todos[index] = todo;
      state = AsyncData([...todos]);
    }
  }

  Future<void> clearAllData() async {
    state = AsyncData([]);
  }
}

@riverpod
@JsonPersist()
class TodoNotifier extends _$TodoNotifier {
  TodoNotifier();

  @override
  Todo build(Todo todo) {
    return todo;
  }

  Future<void> updateTodo(Todo todo) async {
    // update cached state
    state = todo;

    // update in db
  }
}

// class AnchorCardView extends StatelessWidget {
//   const AnchorCardView({super.key});

//   Future<String?> _fetchTitle() async {
//     // String _path = "/Users/rutvik-pieces/work/runtime_client/example/lib/main.dart";
//     String? result;

//     try {
//       // _result = await AOTApi().chatGPT(
//       //   prompt:
//       //       'Please use the keywords in this file path to return me a human-readable title to represent the path in 4 words or less. Please only return the raw text without quotations or markup.',
//       //   value: _path,
//       // );

//       return result ?? "NA";
//     } catch (error) {
//       /// Log
//     }

//     return result;
//   }

//   Stream<LocalAnchorPointMetadata> fetchAnchorData(LocalAnchorPoint point) {
//     return AnchorRendering.streamAnchorPointMetadata(point: point);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final anchor = LocalAnchor(
//       pfd: "NA",
//       points: const [
//         LocalAnchorPoint(
//           pfd: "awdaw",
//           path: "/Users/rutvik-pieces/work/riverpod_testing/lib/anchor_rendering.dart",
//           platform: PlatformEnum.MACOS,
//         ),
//         // LocalAnchorPoint(
//         //   pfd: "awdaw2",
//         //   path: "/Users/rutvik-pieces/work/runtime_client/example/lib/demo_page.dart",
//         //   platform: PlatformEnum.MACOS,
//         // ),
//         // LocalAnchorPoint(
//         //   pfd: "awdaw3",
//         //   path: "/Users/rutvik-pieces/work/runtime_client/example/lib/demo_page.dart",
//         //   platform: PlatformEnum.MACOS,
//         // ),
//       ],
//       type: AnchorTypeEnum.FILE,
//       updated: DateTime.now(),
//     );

//     return PiecesAnchorCard(
//       fetchTitle: _fetchTitle,
//       logInteractionEvent: (event) {},
//       onAnchorPointVerificationUpdate: (value) {},
//       anchorPointMetadataStreamBuilder: fetchAnchorData,
//       anchor: anchor,
//       onAnchorTitleUpdate: (value) {},
//       onAddAnchorPoint: () {},
//       onEnterKeyPressed: () {},
//       onDeleteAnchor: (value) {},
//       onReconnectAnchorPoint: (value) {},
//       contentFooterBuilder: () {
//         return ContentCardActionsFooter<LocalAnchor>(
//           value: anchor,
//           onInteractionEvent: (value, event, [scroeEvent]) {},
//           onDelete: (value) {},
//         );
//       },
//       onDeleteAnchorPoint: (anchor) {},
//     );
//   }
// }
