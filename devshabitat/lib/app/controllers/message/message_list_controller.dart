// ignore_for_file: overridden_fields

import 'package:get/get.dart';
import 'dart:async';
import '../../models/conversation_model.dart';
import 'message_base_controller.dart';

class MessageListController extends MessageBaseController {
  @override
  final RxList<ConversationModel> conversations = <ConversationModel>[].obs;
  final RxList<ConversationModel> filteredConversations =
      <ConversationModel>[].obs;
  final RxList<ConversationModel> _allConversations = <ConversationModel>[].obs;
  final Rx<ConversationModel?> selectedConversation =
      Rx<ConversationModel?>(null);
  final RxBool isSearching = false.obs;
  final RxString searchQuery = ''.obs;

  // Debouncing için timer
  Timer? _searchDebouncer;

  MessageListController({
    required super.messagingService,
    required super.errorHandler,
  });

  @override
  void onInit() {
    super.onInit();
    loadConversations();
  }

  @override
  void onClose() {
    _searchDebouncer?.cancel();
    super.onClose();
  }

  @override
  Future<void> loadConversations() async {
    try {
      startLoading();
      final conversationStream = messagingService.getConversations();
      conversationStream.listen((conversationList) {
        _allConversations.assignAll(conversationList);
        if (isSearching.value) {
          _performSearch(searchQuery.value);
        } else {
          conversations.assignAll(conversationList);
        }
      });
    } catch (e) {
      handleError(e);
    } finally {
      stopLoading();
    }
  }

  Future<void> createConversation(String userId) async {
    try {
      startLoading();
      final conversation = await messagingService.createConversation(userId);
      _allConversations.insert(0, conversation);
      if (!isSearching.value) {
        conversations.insert(0, conversation);
      }
      Get.toNamed('/chat', arguments: conversation.id);
    } catch (e) {
      handleError(e);
    } finally {
      stopLoading();
    }
  }

  Future<void> deleteConversation(String conversationId) async {
    try {
      startLoading();
      await messagingService.deleteConversation(conversationId);
      _allConversations.removeWhere((conv) => conv.id == conversationId);
      conversations.removeWhere((conv) => conv.id == conversationId);
      filteredConversations.removeWhere((conv) => conv.id == conversationId);
    } catch (e) {
      handleError(e);
    } finally {
      stopLoading();
    }
  }

  void searchConversations(String query) {
    searchQuery.value = query;

    if (query.isEmpty) {
      isSearching.value = false;
      conversations.assignAll(_allConversations);
      filteredConversations.clear();
      return;
    }

    isSearching.value = true;

    // Debouncing: 300ms bekle, sonra arama yap
    _searchDebouncer?.cancel();
    _searchDebouncer = Timer(const Duration(milliseconds: 300), () {
      _performSearch(query);
    });
  }

  void _performSearch(String query) {
    if (query.isEmpty) return;

    final searchTerm = query.toLowerCase().trim();

    // Local arama: participantName ve lastMessage'da ara
    final filteredResults = _allConversations.where((conversation) {
      // Katılımcı adında arama
      final nameMatch =
          conversation.participantName.toLowerCase().contains(searchTerm);

      // Son mesajda arama (varsa)
      final messageMatch =
          conversation.lastMessage?.toLowerCase().contains(searchTerm) ?? false;

      return nameMatch || messageMatch;
    }).toList();

    // Sonuçları relevance'a göre sırala
    filteredResults.sort((a, b) {
      // Önce adı tam eşleşenler
      final aNameExact = a.participantName.toLowerCase() == searchTerm;
      final bNameExact = b.participantName.toLowerCase() == searchTerm;

      if (aNameExact && !bNameExact) return -1;
      if (!aNameExact && bNameExact) return 1;

      // Sonra adı başlangıcında eşleşenler
      final aNameStarts =
          a.participantName.toLowerCase().startsWith(searchTerm);
      final bNameStarts =
          b.participantName.toLowerCase().startsWith(searchTerm);

      if (aNameStarts && !bNameStarts) return -1;
      if (!aNameStarts && bNameStarts) return 1;

      // Son olarak mesaj tarihi
      return b.lastMessageTime.compareTo(a.lastMessageTime);
    });

    filteredConversations.assignAll(filteredResults);
    conversations.assignAll(filteredResults);
  }

  void clearSearch() {
    searchQuery.value = '';
    isSearching.value = false;
    _searchDebouncer?.cancel();
    conversations.assignAll(_allConversations);
    filteredConversations.clear();
  }

  void selectConversation(ConversationModel conversation) {
    selectedConversation.value = conversation;
  }

  void clearSelectedConversation() {
    selectedConversation.value = null;
  }

  Future<void> refreshConversations() async {
    await loadConversations();
  }

  // Arama önerileri için getter
  List<String> get searchSuggestions {
    if (searchQuery.value.isEmpty) return [];

    final suggestions = _allConversations
        .map((conv) => conv.participantName)
        .where((name) =>
            name.toLowerCase().contains(searchQuery.value.toLowerCase()))
        .toSet()
        .take(5)
        .toList();

    return suggestions;
  }

  // Arama sonuçları sayısı
  int get searchResultsCount =>
      isSearching.value ? filteredConversations.length : 0;
}
