import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/todo.dart';
import '../controllers/todo_list_controller.dart';

class TodoListBuilder extends ConsumerWidget {
  const TodoListBuilder({
    super.key,
    required this.filteredTodoListProvider,
    required this.todoListProviderNotifier,
    required TextEditingController textEditController,
    required TextEditingController textController,
  })  : _textEditController = textEditController,
        _textController = textController;

  final List<Todo> filteredTodoListProvider;
  final TodoListControllerNotifier todoListProviderNotifier;
  final TextEditingController _textEditController;
  final TextEditingController _textController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Expanded(
      child: ReorderableListView.builder(
        onReorder: (oldIndex, newIndex) {
          ref
              .read(todoListControllerProvider.notifier)
              .reorderTodo(oldIndex, newIndex);
        },
        itemCount: filteredTodoListProvider.length,
        itemBuilder: (context, index) {
          return filteredTodoListProvider.isEmpty
              ? const Center(
                  child: Text('No todos added yet!'),
                )
              : Dismissible(
                  key: ValueKey(filteredTodoListProvider[index].id),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) => todoListProviderNotifier
                      .removeTodo(filteredTodoListProvider[index]),
                  confirmDismiss: (direction) {
                    return showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Remove Todo'),
                          content: const Text(
                              'This action is irreversible. Please confirm deletion'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(true);
                              },
                              child: const Text('Yes'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(false);
                              },
                              child: const Text('No'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Card(
                    child: ListTile(
                      key: ValueKey(filteredTodoListProvider[index].id),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            _textEditController.text =
                                filteredTodoListProvider[index].description;
                            return StatefulBuilder(
                              builder: (context, setState) {
                                return AlertDialog(
                                  title: const Text('Edit Todo'),
                                  content: Column(
                                    children: [
                                      SizedBox(
                                        height: 80,
                                        child: CarouselSlider(
                                          items: filteredTodoListProvider[index]
                                              .images
                                              .map(
                                                (i) => Card(
                                                  child: Container(
                                                    // width: 100,
                                                    height: 70,
                                                    margin: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 5),
                                                    child: Image.file(
                                                      File(i),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                          options: CarouselOptions(
                                            viewportFraction: 0.5,
                                            enableInfiniteScroll: false,
                                          ),
                                        ),
                                      ),
                                      TextField(
                                        controller: _textEditController,
                                        autofocus: true,
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(false);
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        if (_textEditController.text.isEmpty) {
                                          return;
                                        }
                                        todoListProviderNotifier.editTodo(
                                          filteredTodoListProvider[index].id,
                                          _textEditController.text,
                                        );
                                        _textController.clear();
                                        Navigator.of(context).pop(true);
                                      },
                                      child: const Text('Update'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        );
                      },
                      leading: Checkbox(
                        value: filteredTodoListProvider[index].isDone,
                        onChanged: (value) {
                          todoListProviderNotifier.updateTodoStatus(
                            filteredTodoListProvider[index].id,
                            value!,
                          );
                        },
                      ),
                      title: Text(filteredTodoListProvider[index].description),
                      trailing: SizedBox(
                        width: 30,
                        child: Image.file(
                            File(filteredTodoListProvider[index].images[0])),
                      ),
                    ),
                  ),
                );
        },
      ),
    );
  }
}
