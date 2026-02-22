// models/task_model.dart
class TaskModel {
  final String title;
  final String? childUid;
  bool completed;

  TaskModel({
    required this.title,
    this.childUid,
    this.completed = false,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    final rawCompleted = json['completed'] ?? json['status'];
    bool parsedCompleted = false;

    if (rawCompleted is bool) {
      parsedCompleted = rawCompleted;
    } else if (rawCompleted is int) {
      parsedCompleted = rawCompleted != 0;
    } else if (rawCompleted is String) {
      parsedCompleted = rawCompleted.toLowerCase() == 'true' ||
          rawCompleted.toLowerCase() == 'completed' ||
          rawCompleted == '1';
    }

    return TaskModel(
      title: json['title']?.toString() ?? 'Untitled Task',
      childUid: json['userId']?.toString() ?? json['childUid']?.toString(),
      completed: parsedCompleted,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'childUid': childUid,
        'completed': completed,
      };
}