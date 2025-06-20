import 'package:get/get.dart';
import '../../models/conversation_model.dart';
import '../../services/messaging_service.dart';
import '../../core/services/error_handler_service.dart';
import 'message_base_controller.dart';

class MessageListController extends MessageBaseController {
  final RxList<ConversationModel> conversations = <ConversationModel>[].obs;
  final RxBool isSearching = false.obs;
  final RxString searchQuery = ''.obs;

  MessageListController({
    required MessagingService messagingService,
    required ErrorHandlerService errorHandler,
  }) : super(
          messagingService: messagingService,
          errorHandler: errorHandler,
        );

  @override
  void onInit() {
    super.onInit();
    loadConversations();
  }

  Future<void> loadConversations() async {
    try {
      startLoading();
      final conversationStream = messagingService.getConversations();
      conversationStream.listen((conversationList) {
        conversations.assignAll(conversationList);
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
      conversations.insert(0, conversation);
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
      conversations.removeWhere((conv) => conv.id == conversationId);
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
      loadConversations();
    } else {
      isSearching.value = true;
      // Arama işlemi burada yapılacak
    }
  }

  Future<void> refreshConversations() async {
    await loadConversations();
  }
}
