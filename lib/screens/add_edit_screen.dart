import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/bloc/todo_bloc.dart';
import '/bloc/todo_event.dart';
import '/models/todo.dart';

class AddEditScreen extends StatefulWidget {
  final bool isEditing;
  final Todo? todo;

  const AddEditScreen({
    super.key,
    required this.isEditing,
    this.todo,
  });

  @override
  State<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String _task;
  late String _note;

  @override
  void initState() {
    super.initState();
    _task = widget.isEditing ? widget.todo!.task : '';
    _note = widget.isEditing ? widget.todo!.note : '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Sửa Todo' : 'Thêm Todo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                initialValue: _task,
                decoration: const InputDecoration(
                  labelText: 'Công việc',
                  hintText: 'Nhập công việc cần làm',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                ),
                validator: (val) {
                  return val!.trim().isEmpty ? 'Công việc không được để trống' : null;
                },
                onSaved: (value) => _task = value!,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                initialValue: _note,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Ghi chú',
                  hintText: 'Thêm ghi chú (tùy chọn)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                ),
                onSaved: (value) => _note = value!,
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    if (widget.isEditing) {
                      // Cập nhật todo hiện có
                      context.read<TodoBloc>().add(
                            UpdateTodo(
                              widget.todo!.copyWith(task: _task, note: _note),
                            ),
                          );
                    } else {
                      // Thêm todo mới
                      context.read<TodoBloc>().add(
                            AddTodo(
                              Todo(task: _task, note: _note),
                            ),
                          );
                    }
                    Navigator.pop(context); // Quay lại màn hình trước
                  }
                },
                child: Text(widget.isEditing ? 'Lưu thay đổi' : 'Thêm Todo'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}