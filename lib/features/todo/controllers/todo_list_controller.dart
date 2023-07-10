import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';

import '../../../models/todo.dart';

class TodoListControllerNotifier extends StateNotifier<List<Todo>> {
  TodoListControllerNotifier() : super([]);

  Future<Database> _getDatabse() async {
    final dbPath = await sql.getDatabasesPath();
    final db = await sql.openDatabase(
      path.join(dbPath, 'todo.db'),
      onCreate: (db, version) {
        return db.execute(
            'CREATE TABLE todo(id TEXT PRIMARY KEY, description TEXT, isDone TEXT, images TEXT)');
      },
      version: 1,
    );
    return db;
  }

  List<Todo> get todos => state;

  int getActiveTodoCount() {
    final activeTodos = state.where((todo) => !todo.isDone).toList();
    return activeTodos.length;
  }

  void addTodo(String description, List<String> images) async {
    final newTodo = Todo(
      description: description,
      images: images,
    );

    final db = await _getDatabse();
    db.insert(
      'todo',
      {
        'id': newTodo.id,
        'description': newTodo.description,
        'isDone': newTodo.isDone == true ? 'true' : 'false',
        'images': json.encode(newTodo.images),
      },
    );

    state = [newTodo, ...state];
  }

  Future<void> loadTodos() async {
    final db = await _getDatabse();
    final data = await db.query('todo');
    final todos = data.map((row) {
      final List<dynamic> imageList = json.decode(row['images'] as String);
      final List<String> images = List<String>.from(imageList);
      return Todo(
        id: row['id'] as String,
        description: row['description'] as String,
        isDone: (row['isDone'] as String) == 'true' ? true : false,
        images: images,
      );
    }).toList();
    state = todos;
  }

  void updateTodoStatus(String updatableTodoId, bool value) async {
    final newTodoList = state.map((todo) {
      if (todo.id == updatableTodoId) {
        return Todo(
          id: updatableTodoId,
          isDone: value,
          description: todo.description,
          images: todo.images,
        );
      }
      return todo;
    }).toList();

    final db = await _getDatabse();
    final data = {
      'isDone': value == true ? 'true' : 'false',
    };
    db.update('todo', data, where: "id = ?", whereArgs: [updatableTodoId]);

    state = newTodoList;
  }

  void editTodo(String updatableTodoId, String newDescription) async {
    final newTodoList = state.map((todo) {
      if (todo.id == updatableTodoId) {
        return Todo(
            id: updatableTodoId,
            isDone: todo.isDone,
            description: newDescription,
            images: todo.images
            // -----------------------------------------------------------------
            // -----------------------------------------------------------------
            // -----------------------------------------------------------------
            // -----------------------------------------------------------------
            // -----------------------------------------------------------------
            // -----------------------------------------------------------------
            // -----------------------------------------------------------------
            // -----------------------------------------------------------------
            // -----------------------------------------------------------------
            );
      }
      return todo;
    }).toList();

    final db = await _getDatabse();
    final data = {
      'description': newDescription,
    };
    db.update('todo', data, where: "id = ?", whereArgs: [updatableTodoId]);

    state = newTodoList;
  }

//   void editTodo(String updatableTodoId, String newDescription, List<String> newImages) async {
//   final newTodoList = state.map((todo) {
//     if (todo.id == updatableTodoId) {
//       return Todo(
//         id: updatableTodoId,
//         isDone: todo.isDone,
//         description: newDescription,
//         images: newImages,
//       );
//     }
//     return todo;
//   }).toList();

//   final db = await _getDatabse();
//   final data = {
//     'description': newDescription,
//     'images': json.encode(newImages), // Store images as JSON string
//   };
//   db.update('todo', data, where: "id = ?", whereArgs: [updatableTodoId]);

//   state = newTodoList;
// }

  void removeTodo(Todo deleatableTodo) async {
    final db = await _getDatabse();
    await db.rawDelete(
      'DELETE FROM todo WHERE id = ?',
      [deleatableTodo.id],
    );
    state = state.where((todo) => todo != deleatableTodo).toList();
  }

  void reorderTodo(int oldIndex, int newIndex) async {
    final tile = state.removeAt(oldIndex);
    state.insert(newIndex, tile);
    final db = await _getDatabse();
    await db.rawDelete('DELETE FROM todo');
    for (var todo in state) {
      db.insert(
        'todo',
        {
          'id': todo.id,
          'description': todo.description,
          'isDone': todo.isDone == true ? 'true' : 'false',
          'images': json.encode(todo.images),
        },
      );
    }
  }

  //   void addTodo(String description, List<String> images) async {
  //   final newTodo = Todo(
  //     description: description,
  //     images: images,
  //   );

  //   final db = await _getDatabse();
  //   db.insert(
  //     'todo',
  //     {
  //       'id': newTodo.id,
  //       'description': newTodo.description,
  //       'isDone': newTodo.isDone == true ? 'true' : 'false',
  //       'images': json.encode(newTodo.images),
  //     },
  //   );

  //   state = [newTodo, ...state];
  // }
}

final todoListControllerProvider =
    StateNotifierProvider<TodoListControllerNotifier, List<Todo>>((ref) {
  return TodoListControllerNotifier();
});
