import 'package:flutter/material.dart';
import 'package:todo_shit/complete_task.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:todo_shit/api_service.dart' as service;
import 'package:todo_shit/models/todo.dart';

void main() => runApp(MyApp());

const String apiUrl = "https://64c215b3fa35860baea12848.mockapi.io/Tasks";

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple CRUD App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TodoListScreen(),
    );
  }
}

class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  List<Todo> todos = [];
  String searchText = '';

  @override
  void initState() {
    super.initState();
    fetchTodos();
  }

  Future<void> fetchTodos() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      // Nếu yêu cầu thành công, phân tích chuỗi JSON và cập nhật danh sách todos
      List<dynamic> jsonResponse = jsonDecode(response.body);
      setState(() {
        todos = jsonResponse.map((todo) => Todo.fromJson(todo)).toList();
      });
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo List'),
      ),
      body: Column(
        children: [
          Padding(padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Search',
                suffixIcon: Icon(Icons.search),
              ),
            ),),
          Expanded(
            child: buildListView(),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _addTodoDialog,
            child: Icon(Icons.add),
          ),
          SizedBox(height: 16), // Để tạo khoảng cách giữa các nút
          FloatingActionButton(
            onPressed: _showCompletedTodos,
            child: Icon(Icons.done_all),
          ),
        ],
      ),
    );
  }

  ListView buildListView() {
    List<Todo> filteredTodos = todos.where((todo) {
      return todo.title.toLowerCase().contains(searchText.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: filteredTodos.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(filteredTodos[index].title),
          leading: Checkbox(
            value: filteredTodos[index].isCompleted,
            onChanged: (newValue) async {
              setState(() {
                filteredTodos[index].isCompleted = newValue!;
              });
            },
          ),
          trailing: IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
              // final taskId = filteredTodos[index].id;
              // final url = '$apiUrl/$taskId';
              // final res = await http.delete(Uri.parse(url));
              //
              // if (res.statusCode != 200) {
              //   throw Exception('Failed to delete task');
              // }
              // else {
              //   setState(() {
              //     filteredTodos.removeAt(index);
              //   });
              // }
              final taskId = filteredTodos[index].id;
              if (taskId != null) {
                await service.deleteTask(taskId);
                fetchTodos();
              }
            }
          ),
          onTap: () {
            _editTodoDialog(index);
          },
        );
      },
    );
  }

  void _addTodoDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String newTodoTitle = '';

        return AlertDialog(
          title: Text('Add New Todo'),
          content: TextField(
            onChanged: (value) {
              newTodoTitle = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final newTodo = Todo(
                  title: newTodoTitle,
                  isCompleted: false,
                );

                try {
                  final res = await service.addTask(newTodo);

                  setState(() {
                    todos.add(res);
                  });
                  Navigator.of(context).pop();

                }
                catch(e) {
                  print('Failed to create task: $e');
                }

              },
              child: Text('Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _editTodoDialog(int index) {
    showDialog(
      context: context,
      builder: (context) {
        String editedTodoTitle = todos[index].title;
        bool? editedTodoStatus = todos[index].isCompleted;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Edit Todo'),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: editedTodoStatus ?? false,
                    onChanged: (newValue) {
                      setState(() {
                        editedTodoStatus = newValue;
                      });
                    },
                  ),
                  SizedBox(width: 16),
                  Expanded(child: TextField(
                    onChanged: (value) {
                      editedTodoTitle = value;
                    },
                    controller: TextEditingController(text: todos[index].title),
                  ),)
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    final todo = Todo(
                      title: editedTodoTitle,
                      isCompleted: editedTodoStatus ?? false,
                    );

                    final taskId = todos[index].id;
                    if (taskId != null) {
                      await service.updateTask(todo, taskId);
                      fetchTodos();
                    }

                    // final response = await http.put(
                    //   Uri.parse('$apiUrl/$taskId'),
                    //   headers: {'Content-Type': 'application/json'},
                    //   body: jsonEncode(todo.toJson()),
                    // );
                    // if (response.statusCode != 200) {
                    //   throw Exception('Failed to update task');
                    // } else {
                    //   service.fetchTodos();
                    // }
                    Navigator.of(context).pop();
                  },
                  child: Text('Save'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showCompletedTodos() {
    List<Todo> completedTodos = todos.where((todo) => todo.isCompleted).toList();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CompletedTodoListScreen(completedTodos),
      ),
    );
  }

}