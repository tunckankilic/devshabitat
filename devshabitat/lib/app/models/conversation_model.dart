
/// Konuşma türlerini tanımlayan enum
enum ConversationType { direct, group }

/// Konuşma modeli sınıfı
/// Bu sınıf, uygulama içindeki konuşmaların yapısını temsil eder
class ConversationModel {
  final String id;
  final String participantId;
  final String participantName;
  final String? lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool isActive;

  ConversationModel({
    required this.id,
    required this.participantId,
    required this.participantName,
    this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.isActive = true,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'] as String,
      participantId: json['participantId'] as String,
      participantName: json['participantName'] as String,
      lastMessage: json['lastMessage'] as String?,
      lastMessageTime: DateTime.parse(json['lastMessageTime'] as String),
      unreadCount: json['unreadCount'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participantId': participantId,
      'participantName': participantName,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime.toIso8601String(),
      'unreadCount': unreadCount,
      'isActive': isActive,
    };
  }

  ConversationModel copyWith({
    String? id,
    String? participantId,
    String? participantName,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
    bool? isActive,
  }) {
    return ConversationModel(
      id: id ?? this.id,
      participantId: participantId ?? this.participantId,
      participantName: participantName ?? this.participantName,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      isActive: isActive ?? this.isActive,
    );
  }
}
