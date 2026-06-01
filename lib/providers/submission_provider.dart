import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/submission_model.dart';

// 👇 FIXED: Pointing to the correct provider file now!
import 'database_provider.dart'; 

// 1. Stream a specific student's submissions 
// (Used on the Student Dashboard to track their past work and grades)
final studentSubmissionsProvider = StreamProvider.autoDispose.family<List<SubmissionModel>, String>((ref, studentId) {
  final db = ref.watch(databaseServiceProvider);
  return db.streamStudentSubmissions(studentId);
});

// 2. Stream all submissions for a specific assignment 
// (Used on the Teacher Dashboard when they tap on an assignment to grade it)
final assignmentSubmissionsProvider = StreamProvider.autoDispose.family<List<SubmissionModel>, String>((ref, assignmentId) {
  final db = ref.watch(databaseServiceProvider);
  return db.streamSubmissionsForAssignment(assignmentId);
});