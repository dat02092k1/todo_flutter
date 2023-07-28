import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'models/todo.dart';

class TodoList extends StatelessWidget {
  final List<Todo> todos;

  TodoList({Key key, this.todos}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(itemBuilder: (context, index) {
      return GestureDetector(
        child: Container(
          padding: EdgeInsets.all(10, 0),
          color: index % 2 == 0? Colors.greenAccent : Colors.cyan,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Text(todos[index].name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),)
            ],
          ),
      ),)
    })
  }
}
  @override
  Widget build(BuildContext context) {
}

class TodoScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TodoScreenState();
  }
}

class _TodoScreenState extends State<TodoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fetching Todo'),
      ),
      body: FutureBuilder(
      future: fecthTodos(http.Client()),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print(snapshot.error);
        }
        return snapshot.hasData ? Todolist(todos: snapshot.data) : Center(child: CircularProgressIndicator());
    })
    );
  }
}