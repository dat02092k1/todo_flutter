import 'package:flutter/material.dart';
import 'package:todo_shit/main.dart';
import 'package:todo_shit/models/todo.dart';

class CompletedTodoListScreen extends StatelessWidget {
  final List<Todo> completedTodos;

  CompletedTodoListScreen(this.completedTodos);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Completed Todo List'),
      ),
      body: buildListView(),
    );
  }

  ListView buildListView() {
    return ListView.builder(
      itemCount: completedTodos.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(completedTodos[index].title),
          leading: Checkbox(
            value: true,
            onChanged: null,
          ),
        );
      },
    );
  }
}
