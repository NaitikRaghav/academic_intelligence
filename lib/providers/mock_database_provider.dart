import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/assignment_model.dart';

// =========================================================================
// 📚 MOCK ASSIGNMENTS DATABASE
// =========================================================================

class MockAssignmentsNotifier extends StateNotifier<List<AssignmentModel>> {
  MockAssignmentsNotifier() : super([
    // Our initial database state
    AssignmentModel(
      id: 'mock_1',
      teacherId: 'teacher_123',
      title: 'Advanced Thermodynamics',
      description: 'Please explain the Second Law of Thermodynamics using real-world examples.',
      dueDate: DateTime.now().add(const Duration(days: 3)),
      aiGenerated: true,
      createdAt: DateTime.now(),
    ),
  ]);

  // Simulates Gemini generating an assignment and saving to database
  Future<void> generateWithAI(String topic, DifficultyLevel difficulty) async {
    await Future.delayed(const Duration(seconds: 3)); // Network delay
    
    final newAssignment = AssignmentModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      teacherId: 'teacher_123',
      title: '$topic (${difficulty.name})',
      description: 'AI-Generated assignment for $topic. Please provide a detailed analysis based on class lectures.',
      dueDate: DateTime.now().add(const Duration(days: 7)),
      aiGenerated: true,
      createdAt: DateTime.now(),
    );

    // Update the state (This instantly updates all dashboards!)
    state = [newAssignment, ...state];
  }
}

final mockAssignmentsProvider = StateNotifierProvider<MockAssignmentsNotifier, List<AssignmentModel>>((ref) {
  return MockAssignmentsNotifier();
});


// =========================================================================
// 💬 MOCK CHAT DATABASE
// =========================================================================

class MockChatNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  MockChatNotifier() : super([
    {
      'isAI': true,
      'text': 'Hello! I am Academic AI. How can I help you today?',
      'timestamp': DateTime.now(),
    }
  ]);

  Future<void> sendMessage(String text) async {
    // 1. Add user message
    state = [...state, {'isAI': false, 'text': text, 'timestamp': DateTime.now()}];
    
    // 2. Simulate AI processing
    await Future.delayed(const Duration(seconds: 2));
    
    // 3. Add AI response
    state = [...state, {
      'isAI': true, 
      'text': 'I see you are asking about "$text". In a real environment, I would pull data from your course materials to answer this!', 
      'timestamp': DateTime.now()
    }];
  }
}

// We use autoDispose so the chat clears when you close the screen
final mockChatProvider = StateNotifierProvider.autoDispose<MockChatNotifier, List<Map<String, dynamic>>>((ref) {
  return MockChatNotifier();
});