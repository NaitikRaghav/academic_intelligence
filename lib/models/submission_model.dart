// lib/models/submission_model.dart

class SubmissionModel {
  final String id;
  final String assignmentId;
  final String studentId;
  final String rawText; // Text either typed or extracted via OCR
  final String? originalImageUrl; // Link to the Firebase Storage image if it was handwritten
  
  // AI Evaluation Fields
  final double? aiScore; // The score out of 10
  final String? aiSummary;
  final List<String>? aiStrengths;
  final List<String>? aiWeaknesses;
  
  final DateTime submittedAt;
  final bool isGraded; // Turns true once Gemini finishes evaluation

  SubmissionModel({
    required this.id,
    required this.assignmentId,
    required this.studentId,
    required this.rawText,
    this.originalImageUrl,
    this.aiScore,
    this.aiSummary,
    this.aiStrengths,
    this.aiWeaknesses,
    required this.submittedAt,
    this.isGraded = false,
  });

  SubmissionModel copyWith({
    String? id,
    String? assignmentId,
    String? studentId,
    String? rawText,
    String? originalImageUrl,
    double? aiScore,
    String? aiSummary,
    List<String>? aiStrengths,
    List<String>? aiWeaknesses,
    DateTime? submittedAt,
    bool? isGraded,
  }) {
    return SubmissionModel(
      id: id ?? this.id,
      assignmentId: assignmentId ?? this.assignmentId,
      studentId: studentId ?? this.studentId,
      rawText: rawText ?? this.rawText,
      originalImageUrl: originalImageUrl ?? this.originalImageUrl,
      aiScore: aiScore ?? this.aiScore,
      aiSummary: aiSummary ?? this.aiSummary,
      aiStrengths: aiStrengths ?? this.aiStrengths,
      aiWeaknesses: aiWeaknesses ?? this.aiWeaknesses,
      submittedAt: submittedAt ?? this.submittedAt,
      isGraded: isGraded ?? this.isGraded,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'assignmentId': assignmentId,
      'studentId': studentId,
      'rawText': rawText,
      'originalImageUrl': originalImageUrl,
      'aiScore': aiScore,
      'aiSummary': aiSummary,
      'aiStrengths': aiStrengths,
      'aiWeaknesses': aiWeaknesses,
      'submittedAt': submittedAt.toIso8601String(),
      'isGraded': isGraded,
    };
  }

  factory SubmissionModel.fromMap(Map<String, dynamic> map, String documentId) {
    return SubmissionModel(
      id: documentId,
      assignmentId: map['assignmentId'] ?? '',
      studentId: map['studentId'] ?? '',
      rawText: map['rawText'] ?? '',
      originalImageUrl: map['originalImageUrl'],
      aiScore: map['aiScore']?.toDouble(),
      aiSummary: map['aiSummary'],
      aiStrengths: map['aiStrengths'] != null ? List<String>.from(map['aiStrengths']) : null,
      aiWeaknesses: map['aiWeaknesses'] != null ? List<String>.from(map['aiWeaknesses']) : null,
      submittedAt: map['submittedAt'] != null ? DateTime.parse(map['submittedAt']) : DateTime.now(),
      isGraded: map['isGraded'] ?? false,
    );
  }
}