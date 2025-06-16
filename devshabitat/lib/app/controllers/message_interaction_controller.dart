import 'package:get/get.dart';
import '../services/reaction_service.dart';
import 'dart:async';

class MessageInteractionController extends GetxController {
  final ReactionService _reactionService = Get.find<ReactionService>();
  final reactions = <String, Map<String, List<String>>>{}.obs;
  Timer? _debounceTimer;

  void addReaction(String messageId, String emoji, String userId,
      {required String conversationId}) {
    if (!reactions.containsKey(messageId)) {
      reactions[messageId] = <String, List<String>>{};
    }

    if (!reactions[messageId]!.containsKey(emoji)) {
      reactions[messageId]![emoji] = <String>[];
    }

    if (!reactions[messageId]![emoji]!.contains(userId)) {
      reactions[messageId]![emoji]!.add(userId);
      _debounceReactionUpdate(messageId, emoji, userId, conversationId, true);
    }
  }

  void removeReaction(String messageId, String emoji, String userId,
      {required String conversationId}) {
    if (reactions[messageId]?[emoji]?.contains(userId) ?? false) {
      reactions[messageId]![emoji]!.remove(userId);
      if (reactions[messageId]![emoji]!.isEmpty) {
        reactions[messageId]!.remove(emoji);
      }
      if (reactions[messageId]!.isEmpty) {
        reactions.remove(messageId);
      }
      _debounceReactionUpdate(messageId, emoji, userId, conversationId, false);
    }
  }

  void _debounceReactionUpdate(String messageId, String emoji, String userId,
      String conversationId, bool isAdding) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (isAdding) {
        _reactionService.addReaction(
          conversationId: conversationId,
          messageId: messageId,
          emoji: emoji,
          userId: userId,
        );
      } else {
        _reactionService.removeReaction(
          conversationId: conversationId,
          messageId: messageId,
          emoji: emoji,
          userId: userId,
        );
      }
    });
  }

  List<String> getUsersForReaction(String messageId, String emoji) {
    return reactions[messageId]?[emoji] ?? [];
  }

  Map<String, List<String>> getReactionsForMessage(String messageId) {
    return reactions[messageId] ?? {};
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    super.onClose();
  }
}
