import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

// Sử dụng Uuid để tạo ID duy nhất cho mỗi Todo
final Uuid _uuid = const Uuid();

class Todo extends Equatable {
  final String id;
  final String task;
  final String note;
  final bool complete;
  final DateTime createdAt;

  Todo({
    String? id, // Đảm bảo id có thể là null khi tạo mới
    required this.task,
    this.note = '',
    this.complete = false,
    DateTime? createdAt,
  }) : id = id ?? _uuid.v4(), // Nếu ID không được cung cấp, tạo một ID mới
       createdAt = (createdAt ?? DateTime.now().toUtc()).toUtc().add(
         const Duration(hours: 0),
       );

  // Phương thức copyWith để tạo một bản sao của Todo với các thuộc tính được cập nhật
  Todo copyWith({
    String? id,
    String? task,
    String? note,
    bool? complete,
    DateTime? createdAt,
  }) {
    return Todo(
      id: id ?? this.id,
      task: task ?? this.task,
      note: note ?? this.note,
      complete: complete ?? this.complete,
      createdAt: createdAt != null
          ? createdAt.toUtc().add(const Duration(hours: 7))
          : this.createdAt,
    );
  }

  // Chuyển đổi đối tượng Todo thành Map để lưu trữ
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'task': task,
      'note': note,
      'complete': complete,
      'createdAt': createdAt
          .toUtc()
          .add(const Duration(hours: 7))
          .toIso8601String(),
    };
  }

  // Tạo đối tượng Todo từ Map
  factory Todo.fromJson(Map<String, dynamic> json) {
    DateTime createdAt;
    if (json['createdAt'] != null) {
      createdAt = DateTime.parse(
        json['createdAt'] as String,
      ).toUtc().add(const Duration(hours: 7));
    } else {
      createdAt = DateTime.now().toUtc().add(const Duration(hours: 7));
    }
    return Todo(
      id: json['id'] as String,
      task: json['task'] as String,
      note: json['note'] as String,
      complete: json['complete'] as bool,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [id, task, note, complete, createdAt];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Todo &&
        other.id == id &&
        other.task == task &&
        other.note == note &&
        other.complete == complete &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(id, task, note, complete, createdAt);
  }

  @override
  String toString() {
    return 'Todo{id: $id, task: $task, note: $note, complete: $complete, createdAt: $createdAt}';
  }
}
