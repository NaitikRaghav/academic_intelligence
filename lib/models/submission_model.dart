class SubmissionModel {
  final String id;
  final String assignmentId;
  final String studentId;
  final String fileUrl;
  final String? fileType;
  final String? ocrText;
  final String? cleanedText;
  final DateTime submittedAt;
  final bool isLate;

  SubmissionModel({
    required this.id,
    required this.assignmentId,
    required this.studentId,
    required this.fileUrl,
    this.fileType,
    this.ocrText,
    this.cleanedText,
    required this.submittedAt,
    this.isLate = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'assignment_id': assignmentId,
      'student_id': studentId,
      'file_url': fileUrl,
      // 👇 We will use the ocr_text column to store the quiz answers!
      'ocr_text': ocrText, 
      
      // 🛑 FIXED: Commented out fields that don't exist in Supabase yet to prevent crashes!
      // 'file_type': fileType,
      // 'cleaned_text': cleanedText,
      // 'submitted_at': submittedAt.toIso8601String(),
      // 'is_late': isLate,
    };
  }

  factory SubmissionModel.fromMap(Map<String, dynamic> map, String documentId) {
    return SubmissionModel(
      id: documentId,
      assignmentId: map['assignment_id'] ?? '',
      studentId: map['student_id'] ?? '',
      fileUrl: map['file_url'] ?? '',
      fileType: map['file_type'],
      ocrText: map['ocr_text'],
      cleanedText: map['cleaned_text'],
      // Fallback to 'created_at' if 'submitted_at' is missing from DB
      submittedAt: map['submitted_at'] != null 
          ? DateTime.parse(map['submitted_at']) 
          : (map['created_at'] != null ? DateTime.parse(map['created_at']) : DateTime.now()),
      isLate: map['is_late'] ?? false,
    );
  }
}