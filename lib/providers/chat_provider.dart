import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_provider.dart';

// 📦 1. The Message Blueprint
class MessageModel {
  final String id;
  final String sender; // 'user' or 'ai'
  final String message;
  final DateTime createdAt;

  MessageModel({required this.id, required this.sender, required this.message, required this.createdAt});

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'],
      sender: map['sender'],
      message: map['message'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}

// 📦 2. Automatically get or create a Chat ID for this assignment
final chatIdProvider = FutureProvider.family<String, String>((ref, assignmentId) async {
  final supabase = Supabase.instance.client;
  final user = ref.watch(authStateProvider).value; 
  
  if (user == null) throw Exception('User not authenticated');

  // 🛡️ THE FIX: Convert 'general' string into a true database null
  final String? validDbAssignmentId = (assignmentId == 'general') ? null : assignmentId;

  // Look for an existing chat
  var query = supabase.from('chats').select('id').eq('user_id', user.id);
  
  if (validDbAssignmentId == null) {
    // 👇 FIXED: Dart uses .isFilter() instead of .is_()
    query = query.isFilter('assignment_id', null);
  } else {
    query = query.eq('assignment_id', validDbAssignmentId);
  }

  final existingChat = await query.maybeSingle();

  if (existingChat != null) {
    return existingChat['id'];
  }

  // If none exists, create a new chat session!
  final newChatData = {
    'user_id': user.id,
  };
  
  // Only attach the assignment_id if it's a real UUID
  if (validDbAssignmentId != null) {
    newChatData['assignment_id'] = validDbAssignmentId;
  }

  final newChat = await supabase.from('chats').insert(newChatData).select('id').single();

  return newChat['id'];
});

// 📦 3. Stream the messages for that specific Chat ID
final chatMessagesProvider = StreamProvider.family<List<MessageModel>, String>((ref, assignmentId) {
  final chatIdAsync = ref.watch(chatIdProvider(assignmentId));

  return chatIdAsync.when(
    data: (chatId) {
      // Return the pure Supabase stream so WebSockets stay open permanently!
      return Supabase.instance.client
          .from('messages')
          .stream(primaryKey: ['id'])
          .eq('chat_id', chatId)
          .order('created_at', ascending: true) 
          .map((data) => data.map((m) => MessageModel.fromMap(m)).toList());
    },
    loading: () => const Stream.empty(),
    error: (e, st) => Stream.value([]), // Safe fallback
  );
});