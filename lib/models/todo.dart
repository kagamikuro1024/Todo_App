import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

// Sử dụng Uuid để tạo ID duy nhất cho mỗi Todo
final Uuid _uuid = const Uuid();

class Todo extends Equatable {
  final String id;
  final String task;
  final String note;
  final bool complete;

  Todo({
    String? id,
    required this.task,
    this.note = '',
    this.complete = false,
  }) : id = id ?? _uuid.v4(); // Nếu ID không được cung cấp, tạo một ID mới

  // Phương thức copyWith để tạo một bản sao của Todo với các thuộc tính được cập nhật
  Todo copyWith({
    String? id,
    String? task,
    String? note,
    bool? complete,
  }) {
    return Todo(
      id: id ?? this.id,
      task: task ?? this.task,
      note: note ?? this.note,
      complete: complete ?? this.complete,
    );
  }

  // Chuyển đổi đối tượng Todo thành Map để lưu trữ
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'task': task,
      'note': note,
      'complete': complete,
    };
  }

  // Tạo đối tượng Todo từ Map
  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'] as String,
      task: json['task'] as String,
      note: json['note'] as String,
      complete: json['complete'] as bool,
    );
  }

  @override
  List<Object?> get props => [id, task, note, complete];

  @override
  String toString() {
    return 'Todo{id: $id, task: $task, note: $note, complete: $complete}';
  }
}