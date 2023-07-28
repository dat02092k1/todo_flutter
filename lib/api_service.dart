import 'dart:convert';
import 'package:http/http.dart' as http;
import './models/todo.dart';

const String apiUrl = "https://64c215b3fa35860baea12848.mockapi.io/Tasks";

  Future<List<Todo>> fetchTodos() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      // Nếu yêu cầu thành công, phân tích chuỗi JSON và cập nhật danh sách todos
      List<dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((todo) => Todo.fromJson(todo)).toList();

    } else {
      print('Request failed with status: ${response.statusCode}.');
      return [];
    }
  }

  Future<Todo> addTask(Todo todo) async {
    final res = await http.post(Uri.parse(apiUrl), headers: {'Content-Type': 'application/json'}, body: jsonEncode(todo.toJson()));

    if (res.statusCode == 201) {
      final jsonResponse = jsonDecode(res.body);
      return Todo.fromJson(jsonResponse);
    }
    else {
      throw Exception('Failed to create task.');
    }
  }

  Future<void> updateTask(Todo todo, String taskId) async {
    final url = '$apiUrl/${taskId}';
    final response = await http.put(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(todo.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update task');
    }
  }

  Future<String> deleteTask(String taskId) async {
    try {
      final url = '$apiUrl/$taskId';
      final response = await http.delete(Uri.parse(url));
      if (response.statusCode != 200) {
        throw Exception('Failed to delete task');
      }
      return 'task deleted';
    } catch (e) {
      throw Exception('Failed to delete task: ${e.toString()}');
    }
  }
