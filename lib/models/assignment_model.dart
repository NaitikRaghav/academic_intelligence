import 'package:cloud_firestore/cloud_firestore.dart';
// 👇 ADD THIS ENUM RIGHT HERE 👇
enum DifficultyLevel {
  beginner,
  intermediate,
  advanced
}
class AssignmentModel {
  final String id;
  final String teacherId;
  final String title;
  final String description;
  final DateTime dueDate;
  final bool aiGenerated; // The badge we just built!
  final DateTime createdAt;

  AssignmentModel({
    required this.id,
    required this.teacherId,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.aiGenerated,
    required this.createdAt,
  });

  // 📤 Converts our Dart Object into a JSON Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'teacherId': teacherId,
      'title': title,
      'description': description,
      'dueDate': Timestamp.fromDate(dueDate),
      'aiGenerated': aiGenerated,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // 📥 Converts a Firebase JSON Map back into our Dart Object
  factory AssignmentModel.fromMap(Map<String, dynamic> map, String documentId) {
    return AssignmentModel(
      id: documentId,
      teacherId: map['teacherId'] ?? '',
      title: map['title'] ?? 'Untitled Assignment',
      description: map['description'] ?? '',
      // Firebase stores dates as Timestamps, so we convert them back to DateTimes
      dueDate: (map['dueDate'] as Timestamp).toDate(),
      aiGenerated: map['aiGenerated'] ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}