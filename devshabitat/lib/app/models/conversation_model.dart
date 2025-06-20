import 'package:cloud_firestore/cloud_firestore.dart';

/// Konuşma türlerini tanımlayan enum
enum ConversationType { direct, group }

/// Konuşma modeli sınıfı
/// Bu sınıf, uygulama içindeki konuşmaların yapısını temsil eder
class ConversationModel {
  final String id;
  final String participantId;
  final String participantName;
  final String? lastMessage;
  final String? lastMessageSenderId;
  final DateTime lastMessageTime;
  final bool isRead;
  final String? participantAvatar;
  final int unreadCount;

  ConversationModel({
    required this.id,
    required this.participantId,
    required this.participantName,
    this.lastMessage,
    this.lastMessageSenderId,
    required this.lastMessageTime,
    required this.isRead,
    this.participantAvatar,
    required this.unreadCount,
  });

  factory ConversationModel.fromMap(Map<String, dynamic> map) {
    return ConversationModel(
      id: map['id'] as String,
      participantId: map['participantId'] as String,
      participantName: map['participantName'] as String,
      lastMessage: map['lastMessage'] as String?,
      lastMessageSenderId: map['lastMessageSenderId'] as String?,
      lastMessageTime: (map['lastMessageTime'] as Timestamp).toDate(),
      isRead: map['isRead'] as bool? ?? false,
      participantAvatar: map['participantAvatar'] as String?,
      unreadCount: map['unreadCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'participantId': participantId,
      'participantName': participantName,
      'lastMessage': lastMessage,
      'lastMessageSenderId': lastMessageSenderId,
      'lastMessageTime': Timestamp.fromDate(lastMessageTime),
      'isRead': isRead,
      'participantAvatar': participantAvatar,
      'unreadCount': unreadCount,
    };
  }

  ConversationModel copyWith({
    String? id,
    String? participantId,
    String? participantName,
    String? lastMessage,
    String? lastMessageSenderId,
    DateTime? lastMessageTime,
    bool? isRead,
    String? participantAvatar,
    int? unreadCount,
  }) {
    return ConversationModel(
      id: id ?? this.id,
      participantId: participantId ?? this.participantId,
      participantName: participantName ?? this.participantName,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      isRead: isRead ?? this.isRead,
      participantAvatar: participantAvatar ?? this.participantAvatar,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

class Conversation {
  final String id;
  final List<String> participants;
  final String lastMessage;
  final DateTime lastMessageTime;
  final Map<String, bool> unreadCount;
  final Map<String, bool> typing;

  Conversation({
    required this.id,
    required this.participants,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
    required this.typing,
  });

  factory Conversation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Conversation(
      id: doc.id,
      participants: List<String>.from(data['participants'] ?? []),
      lastMessage: data['lastMessage'] ?? '',
      lastMessageTime: (data['lastMessageTime'] as Timestamp).toDate(),
      unreadCount: Map<String, bool>.from(data['unreadCount'] ?? {}),
      typing: Map<String, bool>.from(data['typing'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'participants': participants,
      'lastMessage': lastMessage,
      'lastMessageTime': Timestamp.fromDate(lastMessageTime),
      'unreadCount': unreadCount,
      'typing': typing,
    };
  }

  Conversation copyWith({
    String? id,
    List<String>? participants,
    String? lastMessage,
    DateTime? lastMessageTime,
    Map<String, bool>? unreadCount,
    Map<String, bool>? typing,
  }) {
    return Conversation(
      id: id ?? this.id,
      participants: participants ?? this.participants,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      typing: typing ?? this.typing,
    );
  }
}
