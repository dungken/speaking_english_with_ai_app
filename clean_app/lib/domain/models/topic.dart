class Topic {
  final String id;
  final String title;
  final String description;
  final String level;
  final List<Topic> subtopics;
  bool isCompleted;

  Topic({
    required this.id,
    required this.title,
    required this.description,
    required this.level,
    this.subtopics = const [],
    this.isCompleted = false,
  });

  Topic copyWith({
    String? id,
    String? title,
    String? description,
    String? level,
    List<Topic>? subtopics,
    bool? isCompleted,
  }) {
    return Topic(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      level: level ?? this.level,
      subtopics: subtopics ?? this.subtopics,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'level': level,
      'isCompleted': isCompleted,
      'subtopics': subtopics.map((topic) => topic.toJson()).toList(),
    };
  }

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      level: json['level'] as String,
      isCompleted: json['isCompleted'] as bool,
      subtopics: (json['subtopics'] as List<dynamic>?)
              ?.map((e) => Topic.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class Subtopic {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;

  Subtopic({
    required this.id,
    required this.title,
    required this.description,
    required this.isCompleted,
  });

  Subtopic copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
  }) {
    return Subtopic(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  factory Subtopic.fromJson(Map<String, dynamic> json) {
    return Subtopic(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      isCompleted: json['isCompleted'] as bool,
    );
  }
}
