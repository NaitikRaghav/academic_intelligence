enum DifficultyLevel { beginner, intermediate, advanced }

class AssignmentModel {
  final String id;
  final String title;
  final String? subject;
  final String? topic;
  final DifficultyLevel? difficulty;
  final String generatedContent; 
  final String createdBy;        
  final DateTime? deadline;      
  final double maxScore;
  final DateTime createdAt;

  AssignmentModel({
    required this.id,
    required this.title,
    this.subject,
    this.topic,
    this.difficulty,
    required this.generatedContent,
    required this.createdBy,
    this.deadline,
    this.maxScore = 10.0,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'subject': subject,
      'topic': topic,
      'difficulty': difficulty?.name,
      'generated_content': generatedContent,
      'created_by': createdBy,
      'deadline': deadline?.toIso8601String(),
      // 👇 FIXED: We commented this out so it doesn't crash Supabase!
      // 'max_score': maxScore, 
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory AssignmentModel.fromMap(Map<String, dynamic> map, String documentId) {
    return AssignmentModel(
      id: documentId,
      title: map['title'] ?? 'Untitled',
      subject: map['subject'],
      topic: map['topic'],
      difficulty: map['difficulty'] != null 
          ? DifficultyLevel.values.firstWhere((e) => e.name == map['difficulty'], orElse: () => DifficultyLevel.intermediate)
          : null,
      generatedContent: map['generated_content'] ?? '',
      createdBy: map['created_by'] ?? '',
      deadline: map['deadline'] != null ? DateTime.parse(map['deadline']) : null,
      maxScore: (map['max_score'] ?? 10).toDouble(),
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : DateTime.now(),
    );
  }
}