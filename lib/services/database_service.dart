import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/assignment_model.dart';
import '../models/submission_model.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- ASSIGNMENT METHODS ---

  /// 📝 Create a new assignment (Teacher)
  Future<void> createAssignment(AssignmentModel assignment) async {
    try {
      await _firestore
          .collection('assignments')
          .doc(assignment.id)
          .set(assignment.toMap());
    } catch (e) {
      throw Exception('Failed to create assignment: $e');
    }
  }

  /// 📡 Stream all assignments (For Student Dashboard)
  Stream<List<AssignmentModel>> streamAllAssignments() {
    return _firestore
        .collection('assignments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AssignmentModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  /// 📡 Stream assignments by a specific teacher
  Stream<List<AssignmentModel>> streamTeacherAssignments(String teacherId) {
    return _firestore
        .collection('assignments')
        .where('teacherId', isEqualTo: teacherId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AssignmentModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // --- SUBMISSION METHODS ---

  /// 📤 Submit an assignment (Student)
  Future<void> submitAssignment(SubmissionModel submission) async {
    try {
      await _firestore
          .collection('submissions')
          .doc(submission.id)
          .set(submission.toMap());
    } catch (e) {
      throw Exception('Failed to upload submission: $e');
    }
  }

  /// 🧠 Update a submission with AI grading results
  Future<void> updateSubmissionWithAIGrading({
    required String submissionId,
    required double score,
    required String summary,
    required List<String> strengths,
    required List<String> weaknesses,
  }) async {
    try {
      await _firestore.collection('submissions').doc(submissionId).update({
        'aiScore': score,
        'aiSummary': summary,
        'aiStrengths': strengths,
        'aiWeaknesses': weaknesses,
        'isGraded': true,
      });
    } catch (e) {
      throw Exception('Failed to save AI evaluation: $e');
    }
  }

  /// 📡 Stream all submissions for a specific assignment (For Teacher Dashboard)
  Stream<List<SubmissionModel>> streamSubmissionsForAssignment(String assignmentId) {
    return _firestore
        .collection('submissions')
        .where('assignmentId', isEqualTo: assignmentId)
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => SubmissionModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }
  
  /// 📡 Stream a student's specific submissions
  Stream<List<SubmissionModel>> streamStudentSubmissions(String studentId) {
    return _firestore
        .collection('submissions')
        .where('studentId', isEqualTo: studentId)
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => SubmissionModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }
}