import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database_service.dart';
import '../models/assignment_model.dart';

// 1. Expose the raw service
final databaseServiceProvider = Provider((ref) => DatabaseService());

// 2. Stream ALL assignments (For the Student Dashboard)
final allAssignmentsStreamProvider = StreamProvider<List<AssignmentModel>>((ref) {
  final db = ref.watch(databaseServiceProvider);
  return db.streamAllAssignments();
});

// 3. Stream TEACHER SPECIFIC assignments (For the Teacher Dashboard)
final teacherAssignmentsStreamProvider = StreamProvider.family<List<AssignmentModel>, String>((ref, teacherId) {
  final db = ref.watch(databaseServiceProvider);
  return db.streamTeacherAssignments(teacherId);
});