import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/assignment_model.dart';
import '../models/submission_model.dart';

class DatabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ===========================================================================
  // --- ASSIGNMENT METHODS ---
  // ===========================================================================

  /// 📝 Create a new assignment (Teacher)
  Future<void> createAssignment(AssignmentModel assignment) async {
    try {
      await _supabase
          .from('assignments')
          .insert(assignment.toMap());
    } catch (e) {
      throw Exception('Failed to create assignment: $e');
    }
  }

  /// 📡 Stream all assignments (For Student Dashboard)
  Stream<List<AssignmentModel>> streamAllAssignments() {
    return _supabase
        .from('assignments')
        .stream(primaryKey: ['id'])
        // 👇 FIXED: Changed 'createdAt' to 'created_at'
        .order('created_at', ascending: false)
        .map((data) {
      return data
          .map((map) => AssignmentModel.fromMap(map, map['id']))
          .toList();
    });
  }

  /// 📡 Stream assignments by a specific teacher
  Stream<List<AssignmentModel>> streamTeacherAssignments(String teacherId) {
    return _supabase
        .from('assignments')
        .stream(primaryKey: ['id'])
        // 👇 FIXED: Changed 'teacherId' to 'created_by' to match new schema
        .eq('created_by', teacherId) 
        // 👇 FIXED: Changed 'createdAt' to 'created_at'
        .order('created_at', ascending: false)
        .map((data) {
      return data
          .map((map) => AssignmentModel.fromMap(map, map['id']))
          .toList();
    });
  }

  // ===========================================================================
  // --- SUBMISSION METHODS ---
  // ===========================================================================

  /// 📤 Submit an assignment (Student)
  Future<void> submitAssignment(SubmissionModel submission) async {
    try {
      await _supabase
          .from('submissions')
          .insert(submission.toMap());
    } catch (e) {
      throw Exception('Failed to upload submission: $e');
    }
  }

  /// 📡 Stream all submissions for a specific assignment (For Teacher Dashboard)
  Stream<List<SubmissionModel>> streamSubmissionsForAssignment(String assignmentId) {
    return _supabase
        .from('submissions')
        .stream(primaryKey: ['id'])
        // 👇 FIXED: Changed 'assignmentId' to 'assignment_id'
        .eq('assignment_id', assignmentId)
        // 👇 FIXED: Changed 'submittedAt' to 'submitted_at'
        .order('submitted_at', ascending: false)
        .map((data) {
      return data
          .map((map) => SubmissionModel.fromMap(map, map['id']))
          .toList();
    });
  }
  
  /// 📡 Stream a student's specific submissions
  Stream<List<SubmissionModel>> streamStudentSubmissions(String studentId) {
    return _supabase
        .from('submissions')
        .stream(primaryKey: ['id'])
        // 👇 FIXED: Changed 'studentId' to 'student_id'
        .eq('student_id', studentId)
        // 👇 FIXED: Changed 'submittedAt' to 'submitted_at'
        .order('submitted_at', ascending: false)
        .map((data) {
      return data
          .map((map) => SubmissionModel.fromMap(map, map['id']))
          .toList();
    });
  }
}