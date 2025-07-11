import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/models/todo.dart';

class TodoItem extends StatelessWidget {
  final Todo todo;
  final Function() onTap;
  final Function(DismissDirection) onDismissed;
  final Function(bool?) onCheckboxChanged;

  const TodoItem({
    super.key,
    required this.todo,
    required this.onTap,
    required this.onDismissed,
    required this.onCheckboxChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Dismissible(
      key: ValueKey(
        'TodoItem_${todo.id}_${todo.task.hashCode}_${todo.complete}',
      ), // Key duy nhất bao gồm cả trạng thái
      onDismissed: onDismissed,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          onTap: onTap,
          leading: Checkbox(value: todo.complete, onChanged: onCheckboxChanged),
          title: Text(
            todo.task,
            style: TextStyle(
              decoration: todo.complete ? TextDecoration.lineThrough : null,
              color: todo.complete
                  ? (isDarkMode ? Colors.grey : Colors.grey)
                  : (isDarkMode ? Colors.grey : Colors.black),
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (todo.note.isNotEmpty)
                Text(
                  todo.note,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    decoration: todo.complete
                        ? TextDecoration.lineThrough
                        : null,
                    color: todo.complete
                        ? (isDarkMode ? Colors.grey[500] : Colors.grey[600])
                        : (isDarkMode ? Colors.grey[300] : Colors.grey[700]),
                  ),
                ),
              Text(
                'Tạo lúc: ${DateFormat('dd/MM/yyyy_HH:mm').format(todo.createdAt)}',
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}
