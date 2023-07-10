import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

Uuid uuid = const Uuid();

enum TodoFilter {
  all,
  active,
  done,
}

class Todo {
  final String id;
  final String description;
  final bool isDone;
  final List<String> images;
  Todo({
    String? id,
    required this.description,
    this.isDone = false,
    required this.images,
  }) : id = id ?? uuid.v4();

  Todo copyWith({
    String? id,
    String? description,
    bool? isDone,
    List<String>? images,
  }) {
    return Todo(
      id: id ?? this.id,
      description: description ?? this.description,
      isDone: isDone ?? this.isDone,
      images: images ?? this.images,
    );
  }

  @override
  String toString() {
    return 'Todo(id: $id, description: $description, isDone: $isDone, images: $images)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Todo &&
        other.id == id &&
        other.description == description &&
        other.isDone == isDone &&
        listEquals(other.images, images);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        description.hashCode ^
        isDone.hashCode ^
        images.hashCode;
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'id': id});
    result.addAll({'description': description});
    result.addAll({'isDone': isDone});
    result.addAll({'images': images});

    return result;
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'] ?? '',
      description: map['description'] ?? '',
      isDone: map['isDone'] ?? false,
      images: List<String>.from(map['images']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Todo.fromJson(String source) => Todo.fromMap(json.decode(source));
}
