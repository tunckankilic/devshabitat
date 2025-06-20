import 'package:get/get.dart';
import '../../models/message_model.dart';
import '../../services/messaging_service.dart';
import '../../core/services/error_handler_service.dart';
import 'message_base_controller.dart';

class MessageSearchController extends MessageBaseController {
  final RxList<MessageModel> searchResults = <MessageModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxBool isAdvancedSearch = false.obs;
  final RxString selectedConversation = ''.obs;
  final RxString selectedDate = ''.obs;
  final RxString selectedType = ''.obs;

  MessageSearchController({
    required MessagingService messagingService,
    required ErrorHandlerService errorHandler,
  }) : super(
          messagingService: messagingService,
          errorHandler: errorHandler,
        );

  Future<void> searchMessages() async {
    if (searchQuery.value.isEmpty) return;

    try {
      startLoading();
      final results = await messagingService.searchMessages(
        query: searchQuery.value,
        conversationId: selectedConversation.value.isNotEmpty
            ? selectedConversation.value
            : null,
        date: selectedDate.value.isNotEmpty
            ? DateTime.parse(selectedDate.value)
            : null,
        type: selectedType.value.isNotEmpty ? selectedType.value : null,
      );
      searchResults.assignAll(results);
    } catch (e) {
      handleError(e);
    } finally {
      stopLoading();
    }
  }

  void toggleAdvancedSearch() {
    isAdvancedSearch.toggle();
    if (!isAdvancedSearch.value) {
      // Gelişmiş arama kapatıldığında filtreleri temizle
      selectedConversation.value = '';
      selectedDate.value = '';
      selectedType.value = '';
    }
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
    if (query.length >= 3) {
      searchMessages();
    } else if (query.isEmpty) {
      searchResults.clear();
    }
  }

  void setConversationFilter(String? conversationId) {
    selectedConversation.value = conversationId ?? '';
    if (searchQuery.value.isNotEmpty) {
      searchMessages();
    }
  }

  void setDateFilter(String date) {
    selectedDate.value = date;
    if (searchQuery.value.isNotEmpty) {
      searchMessages();
    }
  }

  void setTypeFilter(String? type) {
    selectedType.value = type ?? '';
    if (searchQuery.value.isNotEmpty) {
      searchMessages();
    }
  }

  void clearFilters() {
    selectedConversation.value = '';
    selectedDate.value = '';
    selectedType.value = '';
    if (searchQuery.value.isNotEmpty) {
      searchMessages();
    }
  }

  void clearSearch() {
    searchQuery.value = '';
    searchResults.clear();
    clearFilters();
  }
}
