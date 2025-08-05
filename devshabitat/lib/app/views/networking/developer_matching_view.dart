import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:devshabitat/app/controllers/developer_matching_controller.dart';
import 'package:devshabitat/app/models/user_profile_model.dart';
import 'package:devshabitat/app/widgets/common/loading_widget.dart';
import 'package:devshabitat/app/widgets/common/error_widget.dart';
import 'package:devshabitat/app/widgets/matching/content_portfolio_widget.dart';

class DeveloperMatchingView extends StatefulWidget {
  const DeveloperMatchingView({super.key});

  @override
  State<DeveloperMatchingView> createState() => _DeveloperMatchingViewState();
}

class _DeveloperMatchingViewState extends State<DeveloperMatchingView>
    with TickerProviderStateMixin {
  final DeveloperMatchingController _controller = Get.find();
  late final AnimationController _animationController;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadInitialData();
  }

  void _initializeControllers() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _tabController = TabController(length: 3, vsync: this);
  }

  Future<void> _loadInitialData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _controller.findSimilarDevelopers();
      final username = await _controller.getCurrentUsername();
      if (username != null) {
        final currentUser = await _controller.getUserProfile(username);
        if (currentUser != null) {
          await Future.wait([
            _controller.loadDeveloperContent(currentUser.id),
            _controller.findSimilarContentCreators(currentUser.id),
          ]);
        }
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: _buildAppBar(), body: Obx(() => _buildBody()));
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Geliştirici Eşleştirme'),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: _showPreferencesDialog,
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _controller.refresh,
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'Eşleşmeler'),
          Tab(text: 'İçerik'),
          Tab(text: 'Öneriler'),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_controller.isLoading.value) {
      return const Center(child: LoadingWidget());
    }

    if (_controller.error.isNotEmpty) {
      return CustomErrorWidget(
        message: _controller.error.value,
        onRetry: _controller.findSimilarDevelopers,
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildMatchingTab(),
        _buildContentTab(),
        _buildSuggestionsTab(),
      ],
    );
  }

  Widget _buildMatchingTab() {
    if (_controller.similarDevelopers.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        _buildStatsCard(),
        Expanded(child: _buildSwipeCards()),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildContentTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildContentFilters(),
        const SizedBox(height: 16),
        _buildContentCreatorsList(),
      ],
    );
  }

  Widget _buildContentFilters() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('İçerik Filtreleri', style: Get.textTheme.titleLarge),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilterChip(
                  label: const Text('Blog Yazarları'),
                  selected: true,
                  onSelected: (bool value) {},
                ),
                FilterChip(
                  label: const Text('Açık Kaynak Katkıcıları'),
                  selected: true,
                  onSelected: (bool value) {},
                ),
                FilterChip(
                  label: const Text('Teknik Yazarlar'),
                  selected: false,
                  onSelected: (bool value) {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentCreatorsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _controller.similarDevelopers.length,
      itemBuilder: (context, index) {
        final developer = _controller.similarDevelopers[index];
        return _buildContentCreatorCard(developer);
      },
    );
  }

  Widget _buildContentCreatorCard(UserProfile developer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: developer.photoUrl != null
                  ? NetworkImage(developer.photoUrl!)
                  : null,
              child: developer.photoUrl == null
                  ? const Icon(Icons.person)
                  : null,
            ),
            title: Text(developer.fullName),
            subtitle: Text(developer.title ?? ''),
            trailing: IconButton(
              icon: const Icon(Icons.message),
              onPressed: () => _showMessageDialog(),
            ),
          ),
          ContentPortfolioWidget(
            developer: developer,
            blogs: _controller.developerBlogs,
            repositories: _controller.developerRepositories,
            onBlogTap: (blogId) => Get.toNamed('/blog/$blogId'),
            onRepoTap: (repoName) {},
            onViewAllContent: () =>
                Get.toNamed('/developer/${developer.id}/content'),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildCollaborationSuggestions(),
        const SizedBox(height: 16),
        _buildProjectSuggestions(),
      ],
    );
  }

  Widget _buildCollaborationSuggestions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('İşbirliği Önerileri', style: Get.textTheme.titleLarge),
            const SizedBox(height: 16),
            Obx(() {
              return Column(
                children: _controller.contentCollaborations
                    .map(
                      (collab) => ListTile(
                        title: Text(collab['title'] ?? ''),
                        subtitle: Text(collab['description'] ?? ''),
                        trailing: ElevatedButton(
                          onPressed: () {},
                          child: const Text('İletişime Geç'),
                        ),
                      ),
                    )
                    .toList(),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectSuggestions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Proje Önerileri', style: Get.textTheme.titleLarge),
            const SizedBox(height: 16),
            Obx(() {
              return Column(
                children: _controller.projectSuggestions
                    .map(
                      (project) => ListTile(
                        title: Text(project['name'] ?? ''),
                        subtitle: Text(project['description'] ?? ''),
                        trailing: ElevatedButton(
                          onPressed: () {},
                          child: const Text('Detaylar'),
                        ),
                      ),
                    )
                    .toList(),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Eşleşme', '${_controller.similarDevelopers.length}'),
          _buildStatItem('Skor', '85%'),
          _buildStatItem('Mesafe', '< 10km'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Get.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Get.theme.colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: Get.textTheme.bodySmall?.copyWith(
            color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildSwipeCards() {
    return PageView.builder(
      itemCount: _controller.similarDevelopers.length,
      itemBuilder: (context, index) {
        final developer = _controller.similarDevelopers[index];
        return GestureDetector(
          onPanUpdate: (details) => _handlePanUpdate(details),
          child: _buildDeveloperCard(developer),
        );
      },
    );
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (details.delta.dx > 10) {
      _handleSwipe(true);
    } else if (details.delta.dx < -10) {
      _handleSwipe(false);
    }
  }

  Widget _buildDeveloperCard(UserProfile developer) {
    return FutureBuilder<double>(
      future: _controller.calculateMatchScore(developer),
      builder: (context, snapshot) {
        final matchScore = snapshot.data ?? 0.0;
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: Tween<double>(begin: 1.0, end: 0.8)
                  .animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: Curves.easeInOut,
                    ),
                  )
                  .value,
              child: Transform.translate(
                offset:
                    Tween<Offset>(begin: Offset.zero, end: const Offset(1.5, 0))
                        .animate(
                          CurvedAnimation(
                            parent: _animationController,
                            curve: Curves.easeInOut,
                          ),
                        )
                        .value,
                child: Container(
                  margin: const EdgeInsets.all(16),
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _buildProfileImage(developer),
                        _buildProfileInfo(developer, matchScore),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProfileImage(UserProfile developer) {
    return Expanded(
      flex: 3,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          image: developer.photoUrl != null
              ? DecorationImage(
                  image: NetworkImage(developer.photoUrl!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: developer.photoUrl == null
            ? Container(
                color: Get.theme.colorScheme.primaryContainer,
                child: Icon(
                  Icons.person,
                  size: 80,
                  color: Get.theme.colorScheme.onPrimaryContainer,
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildProfileInfo(UserProfile developer, double matchScore) {
    return Expanded(
      flex: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(developer, matchScore),
            if (developer.title != null) _buildTitle(developer.title!),
            if (developer.company != null) _buildCompany(developer.company!),
            const SizedBox(height: 8),
            _buildPortfolio(developer),
            if (developer.skills.isNotEmpty) _buildSkills(developer.skills),
            const SizedBox(height: 8),
            if (developer.locationName != null)
              _buildLocation(developer.locationName!),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(UserProfile developer, double matchScore) {
    return Row(
      children: [
        Expanded(
          child: Text(
            developer.fullName,
            style: Get.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getMatchScoreColor(matchScore),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${(matchScore * 100).toInt()}%',
            style: Get.textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        title,
        style: Get.textTheme.bodyMedium?.copyWith(
          color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
        ),
      ),
    );
  }

  Widget _buildCompany(String company) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Text(
        company,
        style: Get.textTheme.bodySmall?.copyWith(
          color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
    );
  }

  Widget _buildPortfolio(UserProfile developer) {
    return Obx(() {
      if (_controller.isLoadingContent.value) {
        return const Center(child: LoadingWidget());
      }

      return ContentPortfolioWidget(
        developer: developer,
        blogs: _controller.developerBlogs,
        repositories: _controller.developerRepositories,
        onBlogTap: (blogId) => Get.toNamed('/blog/$blogId'),
        onRepoTap: (repoName) {},
        onViewAllContent: () =>
            Get.toNamed('/developer/${developer.id}/content'),
      );
    });
  }

  Widget _buildSkills(List<String> skills) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Yetenekler',
          style: Get.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: skills
              .take(5)
              .map((skill) => _buildSkillChip(skill))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildSkillChip(String skill) {
    return Chip(
      label: Text(skill),
      backgroundColor: Get.theme.colorScheme.primaryContainer,
      labelStyle: Get.textTheme.bodySmall?.copyWith(
        color: Get.theme.colorScheme.onPrimaryContainer,
      ),
    );
  }

  Widget _buildLocation(String location) {
    return Row(
      children: [
        Icon(
          Icons.location_on,
          size: 16,
          color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        const SizedBox(width: 4),
        Text(
          location,
          style: Get.textTheme.bodySmall?.copyWith(
            color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            icon: Icons.close,
            color: Colors.red,
            onPressed: () => _handleSwipe(false),
          ),
          _buildActionButton(
            icon: Icons.favorite,
            color: Colors.green,
            onPressed: () => _handleSwipe(true),
          ),
          _buildActionButton(
            icon: Icons.message,
            color: Colors.blue,
            onPressed: _showMessageDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
        iconSize: 28,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: Get.theme.colorScheme.onSurface.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Henüz eşleşme bulunamadı',
            style: Get.textTheme.headlineSmall?.copyWith(
              color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Daha fazla geliştirici bulmak için ayarlarınızı güncelleyin',
            style: Get.textTheme.bodyMedium?.copyWith(
              color: Get.theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _showPreferencesDialog,
            child: const Text('Ayarları Güncelle'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSwipe(bool isLike) async {
    if (_controller.similarDevelopers.isEmpty) return;

    final currentDeveloper = _controller.similarDevelopers.first;
    await _animationController.forward();

    if (isLike) {
      await _controller.sendCollaborationRequest(currentDeveloper.id);
      if (mounted) {
        _showMatchDialog(currentDeveloper);
      }
    } else {
      _showDislikeSnackbar(currentDeveloper);
    }

    _controller.similarDevelopers.removeAt(0);
    _animationController.reset();
  }

  void _showDislikeSnackbar(UserProfile developer) {
    Get.snackbar(
      'Geçti',
      '${developer.fullName} geçildi',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.grey,
      colorText: Colors.white,
      duration: const Duration(seconds: 1),
    );
  }

  void _showMatchDialog(UserProfile developer) {
    Get.dialog(
      AlertDialog(
        title: const Text('Eşleşme!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: developer.photoUrl != null
                  ? NetworkImage(developer.photoUrl!)
                  : null,
              child: developer.photoUrl == null
                  ? const Icon(Icons.person, size: 40)
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              '${developer.fullName} ile eşleştiniz!',
              style: Get.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'İşbirliği talebi gönderildi. Yanıt bekleniyor...',
              style: Get.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Tamam')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _showMessageDialog();
            },
            child: const Text('Mesaj Gönder'),
          ),
        ],
      ),
    );
  }

  void _showMessageDialog() {
    if (_controller.similarDevelopers.isEmpty) return;

    final developer = _controller.similarDevelopers.first;
    Get.dialog(
      AlertDialog(
        title: Text('${developer.fullName} ile Mesajlaş'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'Mesajınızı yazın...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('İptal')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Başarılı',
                'Mesaj gönderildi',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text('Gönder'),
          ),
        ],
      ),
    );
  }

  void _showPreferencesDialog() {
    final contentPreferences = [
      'Blog Yazıları',
      'GitHub Projeleri',
      'Açık Kaynak Katkıları',
      'Teknik Makaleler',
    ];

    Get.dialog(
      AlertDialog(
        title: const Text('Eşleştirme Ayarları'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSliderPreference(
                'Maksimum Mesafe',
                '${_controller.maxDistance.value} km',
                _controller.maxDistance.value.toDouble(),
                10.0,
                100.0,
                (value) => _controller.maxDistance.value = value.toInt(),
              ),
              const SizedBox(height: 16),
              _buildSliderPreference(
                'Minimum Deneyim',
                '${_controller.minExperienceYears.value} yıl',
                _controller.minExperienceYears.value.toDouble(),
                0.0,
                20.0,
                (value) => _controller.minExperienceYears.value = value.toInt(),
              ),
              const SizedBox(height: 16),
              _buildWorkTypePreferences(),
              const SizedBox(height: 16),
              _buildContentPreferences(contentPreferences),
              const SizedBox(height: 16),
              _buildTechnologyPreferences(),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('İptal')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _controller.refresh();
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderPreference(
    String label,
    String value,
    double currentValue,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(
              value,
              style: Get.textTheme.bodyMedium?.copyWith(
                color: Get.theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Slider(
          value: currentValue,
          min: min,
          max: max,
          divisions: ((max - min) / 5).round(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildWorkTypePreferences() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Çalışma Türü',
          style: Get.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Obx(
          () => Column(
            children: [
              _buildWorkTypeCheckbox('Remote', _controller.preferRemote),
              _buildWorkTypeCheckbox('Full-time', _controller.preferFullTime),
              _buildWorkTypeCheckbox('Part-time', _controller.preferPartTime),
              _buildWorkTypeCheckbox('Freelance', _controller.preferFreelance),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWorkTypeCheckbox(String title, RxBool value) {
    return CheckboxListTile(
      title: Text(title),
      value: value.value,
      onChanged: (newValue) => value.value = newValue ?? false,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildContentPreferences(List<String> preferences) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'İçerik Tercihleri',
          style: Get.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Column(
          children: preferences
              .map(
                (pref) => CheckboxListTile(
                  title: Text(pref),
                  value: true,
                  onChanged: (value) {
                    // İçerik tercihlerini güncelle
                  },
                  contentPadding: EdgeInsets.zero,
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildTechnologyPreferences() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tercih Edilen Teknolojiler',
          style: Get.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: const InputDecoration(
            hintText: 'Flutter, Dart, Firebase (virgülle ayırın)',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            final technologies = value
                .split(',')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList();
            _controller.preferredTechnologies.value = technologies;
          },
        ),
      ],
    );
  }

  Color _getMatchScoreColor(double score) {
    if (score >= 0.8) return Colors.green;
    if (score >= 0.6) return Colors.orange;
    return Colors.red;
  }
}
