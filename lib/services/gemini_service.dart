import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../core/constants/api_keys.dart';
import '../models/assignment_model.dart';

class GeminiService {
  // Using the lightning-fast Flash model, perfect for mobile SaaS
  late final GenerativeModel _model;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: ApiKeys.geminiApiKey,
      // 🛡️ Enforcing JSON output so our app doesn't break trying to parse text
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
      ),
    );
  }

  // --- 📝 1. ASSIGNMENT GENERATOR ---

  Future<Map<String, dynamic>> generateAssignment({
    required String subject,
    required String topic,
    required DifficultyLevel difficulty,
  }) async {
    final prompt = '''
      You are an expert academic professor. Create an assignment for the subject "$subject" 
      focusing on the topic "$topic". The difficulty level is ${difficulty.name}.
      
      You MUST return your response as a valid JSON object with the exact following structure:
      {
        "title": "A catchy, academic title for the assignment",
        "questions": [
          "Question 1...",
          "Question 2...",
          "Question 3..."
        ],
        "expected_outcomes": "A short paragraph explaining what the student should learn."
      }
    ''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final rawText = response.text;

      if (rawText != null) {
        // Parse the AI's JSON string back into a Dart Map
        return jsonDecode(rawText) as Map<String, dynamic>;
      } else {
        throw Exception("AI returned an empty response.");
      }
    } catch (e) {
      throw Exception('Failed to generate assignment: $e');
    }
  }

  // --- 🤖 2. ASSIGNMENT EVALUATOR ---

  Future<Map<String, dynamic>> evaluateSubmission({
    required String assignmentTitle,
    required String assignmentQuestions,
    required String studentSubmissionText,
  }) async {
    final prompt = '''
      You are an expert AI grader. You are grading an assignment titled "$assignmentTitle".
      
      Here are the original questions:
      $assignmentQuestions
      
      Here is the student's submitted text (extracted via OCR or typed):
      "$studentSubmissionText"
      
      Analyze the submission strictly against the questions. 
      You MUST return your response as a valid JSON object with the exact following structure:
      {
        "score": <A number between 0.0 and 10.0>,
        "summary": "A 2-3 sentence overall feedback summary.",
        "strengths": ["Strength 1", "Strength 2"],
        "weaknesses": ["Weakness 1", "Weakness 2", "Missing concept 1"]
      }
    ''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final rawText = response.text;

      if (rawText != null) {
        return jsonDecode(rawText) as Map<String, dynamic>;
      } else {
        throw Exception("AI failed to evaluate the submission.");
      }
    } catch (e) {
      throw Exception('Failed to evaluate submission: $e');
    }
  }

  // --- 💬 3. STUDENT CHATBOT HELPER ---

  Future<String> askChatbot({
    required String studentQuestion,
    required String assignmentContext,
  }) async {
    // For the chatbot, we want standard markdown text, not JSON
    final chatModel = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: ApiKeys.geminiApiKey,
    );

    final prompt = '''
      You are a helpful, encouraging teaching assistant. 
      A student is working on an assignment about: "$assignmentContext".
      
      They asked: "$studentQuestion"
      
      Rules:
      1. Give them hints, explanations, or concepts.
      2. DO NOT just give them the direct answer to the assignment. Guide them to it.
      3. Keep the tone encouraging and concise.
    ''';

    try {
      final response = await chatModel.generateContent([Content.text(prompt)]);
      return response.text ?? "I'm sorry, I couldn't process that right now.";
    } catch (e) {
      throw Exception('Chatbot error: $e');
    }
    
  }
  // --- 🎯 4. QUIZ GENERATOR ---

  Future<Map<String, dynamic>> generateQuiz({
    required String subject,
    required String topic,
    required DifficultyLevel difficulty,
    int numberOfQuestions = 5,
  }) async {
    final prompt = '''
      You are an expert academic professor. Create a multiple-choice quiz for the subject "$subject" 
      focusing on the topic "$topic". The difficulty level is ${difficulty.name}.
      Generate exactly $numberOfQuestions questions.
      
      You MUST return your response as a valid JSON object with the exact following structure:
      {
        "title": "A catchy title for the quiz",
        "questions": [
          {
            "question": "The question text...",
            "options": ["Option A", "Option B", "Option C", "Option D"],
            "correct_answer": "The exact string of the correct option",
            "explanation": "A short explanation of why this is correct."
          }
        ]
      }
    ''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final rawText = response.text;

      if (rawText != null) {
        return jsonDecode(rawText) as Map<String, dynamic>;
      } else {
        throw Exception("AI returned an empty quiz response.");
      }
    } catch (e) {
      throw Exception('Failed to generate quiz: $e');
    }
  }
}