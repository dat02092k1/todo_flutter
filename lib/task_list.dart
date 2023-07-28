import 'package:flutter/material.dart';
import 'package:todo_shit/models/task.dart';
import 'package:todo_shit/api_service.dart';

class TaskList extends StatefulWidget {
  final ApiService apiService;

  TaskList({required this.apiService});

  @override
  _TaskListState createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  List<Task> tasks = [];

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    List<Task> fetchedTasks = await widget.apiService.fetchTasks();
    setState(() {
      tasks = fetchedTasks;
    });
  }

  Future<void> _refreshTasks() async {
    setState(() {
      tasks.clear();
    });
    await _fetchTasks();
  }

  void _showAddTaskDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddTaskDialog(apiService: widget.apiService, onTaskAdded: _refreshTasks);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter CRUD App'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshTasks,
        child: ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(tasks[index].title),
              leading: Checkbox(
                value: tasks[index].isCompleted,
                onChanged: (value) async {
                  Task updatedTask = Task(
                    id: tasks[index].id,
                    title: tasks[index].title,
                    isCompleted: value!,
                  );
                  await widget.apiService.updateTask(updatedTask);
                  await _refreshTasks();
                },
              ),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () async {
                  await widget.apiService.deleteTask(tasks[index].id);
                  await _refreshTasks();
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTaskDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class AddTaskDialog extends StatefulWidget {
  final ApiService apiService;
  final VoidCallback onTaskAdded;

  AddTaskDialog({required this.apiService, required this.onTaskAdded});

  @override
  _AddTaskDialogState createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add New Task'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _titleController,
          decoration: InputDecoration(labelText: 'Task Title'),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a title';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _addTask,
          child: _isLoading ? CircularProgressIndicator() : Text('Add'),
        ),
      ],
    );
  }

  Future<void> _addTask() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final newTask = Task(
          id: '',
          title: _titleController.text,
          isCompleted: false,
        );

        await widget.apiService.createTask(newTask);

        setState(() {
          _isLoading = false;
        });

        Navigator.of(context).pop();
        widget.onTaskAdded(); // Notify the parent about the new task added
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        // Handle error
        print('Error: $e');
      }
    }
  }
}