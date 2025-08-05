import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/chat_controller.dart';
import '../../controllers/responsive_controller.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/responsive/responsive_wrapper.dart';

class NewChatView extends GetView<ChatController> {
  const NewChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveWrapper(
      mobile: _buildMobileLayout(),
      tablet: _buildTabletLayout(),
      desktop: _buildDesktopLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Sohbet'),
        backgroundColor: Get.theme.colorScheme.surface,
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildTabletLayout() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Sohbet'),
        backgroundColor: Get.theme.colorScheme.surface,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Sohbet'),
        backgroundColor: Get.theme.colorScheme.surface,
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        _buildSearchSection(),
        const SizedBox(height: 16),
        Expanded(child: _buildUserList()),
      ],
    );
  }

  Widget _buildSearchSection() {
    final responsive = Get.find<ResponsiveController>();
    
    return Container(
      padding: EdgeInsets.all(responsive.isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Get.theme.colorScheme.outline.withOpacity(0.1),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kullanıcı Ara',
            style: Get.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          SearchBar(
            controller: controller.searchController,
            hintText: 'Kullanıcı adı veya isim ara...',
            leading: const Icon(Icons.search),
            onChanged: (value) {
              controller.searchUsers(value);
            },
            trailing: [
              Obx(() {
                if (controller.searchQuery.value.isEmpty) return const SizedBox();
                return IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: controller.clearSearch,
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserList() {
    return Obx(() {
      if (controller.isSearching.value) {
        return const Center(child: LoadingWidget());
      }

      if (controller.searchQuery.value.isEmpty) {
        return _buildEmptyState();
      }

      if (!controller.hasSearchResults) {
        return _buildNoResultsState();
      }

      return _buildSearchResults();
    });
  }

  Widget _buildEmptyState() {
    final responsive = Get.find<ResponsiveController>();
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: responsive.isMobile ? 64 : 80,
            color: Get.theme.colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Yeni Sohbet Başlat',
            style: Get.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sohbet etmek istediğiniz kişiyi arayın',
            style: Get.textTheme.bodyMedium?.copyWith(
              color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Get.theme.colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Kullanıcı Bulunamadı',
            style: Get.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '"${controller.searchQuery.value}" için sonuç bulunamadı',
            style: Get.textTheme.bodyMedium?.copyWith(
              color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    final responsive = Get.find<ResponsiveController>();
    
    return ListView.builder(
      padding: EdgeInsets.all(responsive.isMobile ? 16 : 24),
      itemCount: controller.searchResults.length,
      itemBuilder: (context, index) {
        final user = controller.searchResults[index];
        return _buildUserTile(user);
      },
    );
  }

  Widget _buildUserTile(Map<String, dynamic> user) {
    final responsive = Get.find<ResponsiveController>();
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Get.theme.colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(responsive.isMobile ? 12 : 16),
        leading: CircleAvatar(
          radius: responsive.isMobile ? 20 : 24,
          backgroundImage: user['photoURL'] != null
              ? NetworkImage(user['photoURL'])
              : null,
          child: user['photoURL'] == null
              ? Icon(
                  Icons.person,
                  size: responsive.isMobile ? 20 : 24,
                )
              : null,
        ),
        title: Text(
          user['displayName'] ?? 'Anonim Kullanıcı',
          style: Get.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: user['username'] != null
            ? Text(
                '@${user['username']}',
                style: Get.textTheme.bodySmall?.copyWith(
                  color: Get.theme.colorScheme.primary,
                ),
              )
            : null,
        trailing: FilledButton(
          onPressed: () => _startChat(user['id']),
          child: const Text('Sohbet Et'),
        ),
        onTap: () => _startChat(user['id']),
      ),
    );
  }

  void _startChat(String userId) {
    Get.dialog(
      AlertDialog(
        title: const Text('Yeni Sohbet'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Bu kullanıcıyla sohbet başlatmak istiyor musunuz?'),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                hintText: 'İlk mesajınızı yazın (isteğe bağlı)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: (value) {
                // İlk mesaj değişkeni
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () {
              Get.back();
              controller.startNewChat(userId, null);
            },
            child: const Text('Başlat'),
          ),
        ],
      ),
    );
  }
}