import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/assignment_model.dart';
import '../services/database_service.dart';

// 1. Expose the DatabaseService globally so we don't instantiate it multiple times
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

// 2. Stream ALL assignments (Useful if a student wants to browse all available topics)
final allAssignmentsProvider = StreamProvider.autoDispose<List<AssignmentModel>>((ref) {
  final db = ref.watch(databaseServiceProvider);
  return db.streamAllAssignments();
});

// 3. Stream assignments created by a specific teacher 
// We use '.family' here so the UI can pass the specific teacherId into the provider
final teacherAssignmentsProvider = StreamProvider.autoDispose.family<List<AssignmentModel>, String>((ref, teacherId) {
  final db = ref.watch(databaseServiceProvider);
  return db.streamTeacherAssignments(teacherId);
});