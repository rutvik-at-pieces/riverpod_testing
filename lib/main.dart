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

final anchorCardView = GlobalKey();

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

final List<String> chatMessages = [];
int id = 0;
final chatMessanger = ChatMessagesManager();

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
    final items = ListView.builder(
      itemCount: chatMessages.length,
      itemBuilder: (context, index) {
        return chatMessanger.getMessageWidget(chatMessages[index]);
      },
    );

    return ParticleAesthetics(
      builder: (context) {
        return MaterialApp(
            darkTheme: ParticleTheme.dark(context),
            themeMode: ThemeMode.dark,
            home: Builder(builder: (context) {
              return Scaffold(
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
                  body: DefaultTabController(
                    length: 5,
                    child: TabBarView(
                      children: [
                        Column(
                          children: [
                            // Chat Messages
                            Expanded(child: items),

                            // List Items
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      id += 1;
                                      chatMessages.add(id.toString());
                                    });
                                  },
                                  child: const Text('Add Item'),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Scaffold(
                                          appBar: AppBar(
                                            title: const Text('Chat Messages'),
                                          ),
                                          body: Column(
                                            children: [
                                              Expanded(
                                                child: items,
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    );

                                    setState(() {});
                                  },
                                  child: const Text('Navigage to Different Route'),
                                ),
                              ],
                            ),
                          ],
                        ),
                        // ListView rebuilding - doesn't repaints items on scroll.
                        Column(
                          children: [
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              'ListView with AutomaticKeepAliveClientMixin on list item',
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Expanded(
                              child: Consumer(builder: (context, ref, _) {
                                final state = ref.watch(listItemsProvider);

                                return ListenableBuilder(
                                    listenable: state,
                                    builder: (context, _) {
                                      return ListView.builder(
                                        itemCount: state.items.length,
                                        itemBuilder: (context, index) {
                                          final item = state.items[index];

                                          return ListItemBuilder(
                                            index: index,
                                            item: item,
                                          );
                                        },
                                      );
                                    });
                              }),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                ref.read(listItemsProvider).addItem();
                              },
                              child: const Text('Add Item'),
                            ),
                          ],
                        ),

                        // Regular ListView with no AutomaticKeepAliveClientMixin on list item.
                        // By default, items are created and disposed of as they enter/exit the scrolling view.
                        // This is costlier when user is scrolling within a chat messages list.
                        Column(
                          children: [
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              'Regular ListView',
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Expanded(
                              child: ListView.builder(
                                itemCount: _items.length,
                                itemBuilder: (context, index) {
                                  final item = _items[index];

                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ListenableBuilder(
                                        listenable: item,
                                        builder: (context, _) {
                                          return FloatingActionButton(
                                            onPressed: () {
                                              item.increment();
                                            },
                                            child: Text(
                                              'Item $index: ${item.count}',
                                              style: const TextStyle(fontSize: 24),
                                            ),
                                          );
                                        }),
                                  );
                                },
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _items.add(ListItemNotifier());
                                });
                              },
                              child: const Text('Add Item'),
                            ),
                          ],
                        ),
                        // Builds a list of todos watching the todosNotifierProvider.
                        // Changes from individual todos are propagated through the change
                        // in the todosNotifierProvider state.
                        // As a result, the entire list is re-build when a todo is updated,
                        // instead of rebuilding the part of the todo widget which depended
                        // on the changed value.
                        Column(
                          children: [
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              'ListView with Todos state managed by TodoNotifierProvider',
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Expanded(
                              child: Consumer(builder: (context, ref, _) {
                                final todos = ref.watch(todosNotifierProvider);

                                return todos.when(data: (todos) {
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
                                          leading: CircularProgressIndicator(),
                                        ),
                                      );
                                    },
                                  );
                                }, error: (e, stk) {
                                  return Center(
                                    child: Text('Error: $e'),
                                  );
                                }, loading: () {
                                  return const Center(child: CircularProgressIndicator());
                                });
                              }),
                            ),
                            SizedBox(
                              height: 50,
                            ),
                            ElevatedButton(
                              onPressed: () {
                                ref.read(todosNotifierProvider.notifier).add(
                                      Todo(
                                        id: DateTime.now().millisecondsSinceEpoch,
                                        description: 'New Todo',
                                        completed: false,
                                      ),
                                    );
                              },
                              child: const Text('Add Item'),
                            ),
                          ],
                        ),
                        // State of each todo is watched individually using the todoNotifierProvider.
                        // This allows us to re-build only the changed todo item when a todo is updated.
                        // Allows for more granular control over the rebuilding phase.
                        Column(
                          children: [
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              'ListView with each Todo state managed by TodoNotifierProvider',
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Expanded(
                              child: Consumer(builder: (context, ref, _) {
                                final todos = ref.watch(todosNotifierProvider);

                                return todos.when(data: (todos) {
                                  return ListView.builder(
                                    itemCount: todos.length,
                                    itemBuilder: (context, index) {
                                      final Todo todo = todos[index];
                                      final TodoNotifierProvider todoNotifier = todoNotifierProvider(todo);
                                      return Consumer(builder: (context, ref, _) {
                                        return Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: ListTile(
                                            title: Text(ref.read(todoNotifier).id.toString()),
                                            subtitle: Consumer(builder: (context, ref, _) {
                                              final status = ref.watch(todoNotifier.select((todo) => todo.completed));

                                              return Text('Status: $status');
                                            }),
                                            trailing: Consumer(builder: (context, ref, _) {
                                              final status = ref.watch(todoNotifier.select((todo) => todo.completed));

                                              return Checkbox(
                                                value: status,
                                                onChanged: (value) {
                                                  ref.read(todoNotifier.notifier).updateTodo(
                                                        Todo(
                                                          id: ref.read(todoNotifier).id,
                                                          description: ref.read(todoNotifier).description,
                                                          completed: value ?? false,
                                                        ),
                                                      );
                                                },
                                              );
                                            }),
                                            leading: RepaintBoundary(child: CircularProgressIndicator()),
                                          ),
                                        );
                                      });
                                    },
                                  );
                                }, error: (e, stk) {
                                  return Center(
                                    child: Text('Error: $e'),
                                  );
                                }, loading: () {
                                  return const Center(child: CircularProgressIndicator());
                                });
                              }),
                            ),
                            SizedBox(
                              height: 50,
                            ),
                            ElevatedButton(
                              onPressed: () {
                                ref.read(todosNotifierProvider.notifier).add(
                                      Todo(
                                        id: DateTime.now().millisecondsSinceEpoch,
                                        description: 'New Todo',
                                        completed: false,
                                      ),
                                    );
                              },
                              child: const Text('Add Item'),
                            ),
                          ],
                        )
                      ],
                    ),
                  ));
            }));
      },
    );
  }
}

/// Adds [AutomaticKeepAliveClientMixin] to the widget to prevent it from being disposed of
/// when user is scrolling through the list or when the widget is off-screen.
///
/// Note: As this widget is kept alive as long as the parent listview is alive, whenever
/// the list count changes, it triggers re-builds on all items in the list and not just
/// the items visible on the screen.
///
/// re-build refers to the build method being called again, not widget creation.
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
  void initState() {
    super.initState();

    print("ListItemBuilder: ${widget.index}");
  }

  @override
  Widget build(BuildContext context) {
    print("ListItemBuilder build: ${widget.index}");
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

// class AnchorCardView extends StatefulWidget {
//   const AnchorCardView({super.key});

//   @override
//   State<AnchorCardView> createState() => _AnchorCardViewState();
// }

// class _AnchorCardViewState extends State<AnchorCardView> {
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
//   void initState() {
//     super.initState();
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

class ChatMessagesManager {
  // create a singleton

  ChatMessagesManager._();
  static final ChatMessagesManager _instance = ChatMessagesManager._();
  factory ChatMessagesManager() {
    return _instance;
  }

  Map<String, GlobalKey> messagesGlobalKey = {};

  Widget getMessageWidget(String messageId) {
    if (messagesGlobalKey[messageId] != null) {
      return ChatMessage(
        messageId: messageId,
        key: messagesGlobalKey[messageId]!,
      );
    }

    final key = messagesGlobalKey[messageId] ?? GlobalKey();

    final messageWidget = ChatMessage(
      messageId: messageId,
      key: key,
    );

    messagesGlobalKey[messageId] = key;

    return messageWidget;
  }
}

class ChatMessage extends StatefulWidget {
  const ChatMessage({
    super.key,
    required this.messageId,
  });

  final String messageId;

  @override
  State<ChatMessage> createState() => _ChatMessageState();
}

class _ChatMessageState extends State<ChatMessage> {
  int count = 0;

  @override
  void initState() {
    super.initState();

    print("Message: ${widget.messageId}");
  }

  @override
  Widget build(BuildContext context) {
    print("Message build: ${widget.messageId}");
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: FloatingActionButton(
        onPressed: () {
          setState(() {
            count++;
          });
        },
        child: Text(
          'Message Id ${widget.messageId}' " Count: $count",
          style: TextStyle(color: Colors.black87, fontSize: 16),
        ),
      ),
    );
  }
}
