class Todo {
  String title;
  bool isCompleted;
  String? id;

  Todo({
    required this.title,
    this.isCompleted = false,
    this.id,
  });

// Factory method để tạo đối tượng Todo từ một Map (JSON) được trả về từ API
  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      title: json['title'],
      isCompleted: json['isCompleted'],
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'isCompleted': isCompleted,
    };
  }
}