class CourseModel {
  final int id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final List<LessonModel> lessons;
  final bool isEnrolled;
  final double progress; // 0.0 to 1.0
  final bool isDownloaded;

  CourseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.lessons,
    this.isEnrolled = false,
    this.progress = 0.0,
    this.isDownloaded = false,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      thumbnailUrl: json['thumbnail_url'],
      lessons: (json['lessons'] as List).map((e) => LessonModel.fromJson(e)).toList(),
      isEnrolled: json['is_enrolled'] ?? false,
      progress: (json['progress'] ?? 0.0).toDouble(),
      isDownloaded: json['is_downloaded'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'thumbnail_url': thumbnailUrl,
      'lessons': lessons.map((e) => e.toJson()).toList(),
      'is_enrolled': isEnrolled,
      'progress': progress,
      'is_downloaded': isDownloaded,
    };
  }
}

class LessonModel {
  final int id;
  final String title;
  final String type; // 'video' or 'pdf'
  final String url;
  final int duration; // in seconds for video
  final bool isCompleted;

  LessonModel({
    required this.id,
    required this.title,
    required this.type,
    required this.url,
    required this.duration,
    this.isCompleted = false,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: json['id'],
      title: json['title'],
      type: json['type'],
      url: json['url'],
      duration: json['duration'] ?? 0,
      isCompleted: json['is_completed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'url': url,
      'duration': duration,
      'is_completed': isCompleted,
    };
  }
}