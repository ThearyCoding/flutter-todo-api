class TodoModel {
  final String? id;
  final String title;
  final bool isCompleted;
  final String description;
  final DateTime? createdAt;

  TodoModel({
    this.id,
    required this.title,
    required this.description,
    required this.isCompleted,
    this.createdAt,
  });

  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      id: json['_id'] as String?,
      title: json['title'] as String? ?? '',
      isCompleted: json['completed'] as bool? ?? false,
      description: json['description'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'completed': isCompleted,
      'description': description,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  TodoModel copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    DateTime? createdAt,
    String? description,
  }) {
    return TodoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
