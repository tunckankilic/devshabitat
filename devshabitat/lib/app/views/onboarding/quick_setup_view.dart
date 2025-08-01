import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/enhanced_user_model.dart';
import '../../models/profile_completion_model.dart';
import '../../core/theme/dev_habitat_colors.dart';
import '../../services/user_service.dart';

/// Quick setup view for contextual onboarding
class QuickSetupView extends StatefulWidget {
  final EnhancedUserModel user;
  final String? targetFeature;
  final List<ProfileField>? focusFields;

  const QuickSetupView({
    super.key,
    required this.user,
    this.targetFeature,
    this.focusFields,
  });

  @override
  State<QuickSetupView> createState() => _QuickSetupViewState();
}

class _QuickSetupViewState extends State<QuickSetupView>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Controllers for form fields
  final _bioController = TextEditingController();
  final _skillsController = TextEditingController();
  final _githubController = TextEditingController();
  final _locationController = TextEditingController();

  // State variables
  final _selectedSkills = <String>[].obs;
  final _isLoading = false.obs;

  // Predefined skill options
  final List<String> _skillOptions = [
    'Flutter',
    'Dart',
    'JavaScript',
    'TypeScript',
    'React',
    'Angular',
    'Vue.js',
    'Node.js',
    'Python',
    'Java',
    'Kotlin',
    'Swift',
    'React Native',
    'Android',
    'iOS',
    'Web Development',
    'Mobile Development',
    'Backend Development',
    'DevOps',
    'UI/UX Design',
    'Machine Learning',
    'Data Science',
    'Cybersecurity',
    'Cloud Computing',
    'Blockchain',
  ];

  List<ProfileField> get relevantFields {
    if (widget.focusFields != null) {
      return widget.focusFields!;
    }

    // Return most important fields based on target feature
    switch (widget.targetFeature) {
      case 'messaging':
      case 'networking':
        return [
          const ProfileField(name: 'bio', displayName: 'Hakkında', weight: 10),
          const ProfileField(
              name: 'skills', displayName: 'Yetenekler', weight: 15),
        ];
      case 'project_sharing':
      case 'portfolio_showcase':
        return [
          const ProfileField(name: 'bio', displayName: 'Hakkında', weight: 10),
          const ProfileField(
              name: 'skills', displayName: 'Yetenekler', weight: 15),
          const ProfileField(
              name: 'githubUsername',
              displayName: 'GitHub Profili',
              weight: 10),
        ];
      default:
        return [
          const ProfileField(name: 'bio', displayName: 'Hakkında', weight: 10),
          const ProfileField(
              name: 'skills', displayName: 'Yetenekler', weight: 15),
          const ProfileField(
              name: 'location', displayName: 'Konum', weight: 10),
        ];
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _prefillFromUser();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _animationController.forward();
  }

  void _prefillFromUser() {
    _bioController.text = widget.user.bio ?? '';
    _githubController.text = widget.user.githubUsername ?? '';

    if (widget.user.skills != null) {
      _selectedSkills.addAll(widget.user.skills!);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _bioController.dispose();
    _skillsController.dispose();
    _githubController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: _buildBody(),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => Get.back(result: false),
      ),
      title: Text(
        'Hızlı Kurulum',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      centerTitle: true,
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: Text(
            'Atla',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 32),
            _buildProgressIndicator(),
            const SizedBox(height: 32),
            _buildFormFields(),
            const SizedBox(height: 32),
            _buildActionButtons(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final featureName = _getFeatureDisplayName(widget.targetFeature);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                DevHabitatColors.primary.withOpacity(0.1),
                DevHabitatColors.primary.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: DevHabitatColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getFeatureIcon(widget.targetFeature),
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.targetFeature != null
                              ? '$featureName için'
                              : 'Profil Tamamlama',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: DevHabitatColors.primary,
                                  ),
                        ),
                        Text(
                          'Sadece ${relevantFields.length} alan',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Bu özelliği kullanabilmek için gerekli alanları doldurman yeterli. İstediğin zaman profil sayfasından detaylarını güncelleyebilirsin.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    final completedFields = _getCompletedFieldsCount();
    final totalFields = relevantFields.length;
    final progress = totalFields > 0 ? completedFields / totalFields : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'İlerleme',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                '$completedFields/$totalFields',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: DevHabitatColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor:
                Theme.of(context).colorScheme.outline.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              progress >= 1.0
                  ? DevHabitatColors.success
                  : DevHabitatColors.primary,
            ),
            minHeight: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: relevantFields.map((field) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: _buildFieldWidget(field),
        );
      }).toList(),
    );
  }

  Widget _buildFieldWidget(ProfileField field) {
    switch (field.name) {
      case 'bio':
        return _buildBioField();
      case 'skills':
        return _buildSkillsField();
      case 'githubUsername':
        return _buildGitHubField();
      case 'location':
        return _buildLocationField();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBioField() {
    return TextFormField(
      controller: _bioController,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: 'Hakkında',
        hintText: 'Kendini kısaca tanıt...',
        prefixIcon: const Icon(Icons.info_outline),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Theme.of(context).cardColor,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Lütfen kendini kısaca tanıt';
        }
        if (value.trim().length < 20) {
          return 'En az 20 karakter yazman gerekiyor';
        }
        return null;
      },
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildSkillsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Yeteneklerin (En az 3 tane seç)',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _skillOptions.map((skill) {
            final isSelected = _selectedSkills.contains(skill);
            return FilterChip(
              label: Text(skill),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedSkills.add(skill);
                  } else {
                    _selectedSkills.remove(skill);
                  }
                });
              },
              selectedColor: DevHabitatColors.primary.withOpacity(0.2),
              checkmarkColor: DevHabitatColors.primary,
            );
          }).toList(),
        ),
        if (_selectedSkills.length < 3) ...[
          const SizedBox(height: 8),
          Text(
            'En az 3 yetenek seçmelisin',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
          ),
        ],
      ],
    );
  }

  Widget _buildGitHubField() {
    return TextFormField(
      controller: _githubController,
      decoration: InputDecoration(
        labelText: 'GitHub Kullanıcı Adı',
        hintText: 'github.com/username',
        prefixIcon: const Icon(Icons.code),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Theme.of(context).cardColor,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'GitHub kullanıcı adını gir';
        }
        return null;
      },
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildLocationField() {
    return TextFormField(
      controller: _locationController,
      decoration: InputDecoration(
        labelText: 'Konum',
        hintText: 'Şehir, Ülke',
        prefixIcon: const Icon(Icons.location_on_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Theme.of(context).cardColor,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Konumunu belirt';
        }
        return null;
      },
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildActionButtons() {
    final isComplete = _isFormComplete();

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: Obx(() => ElevatedButton(
                onPressed: isComplete && !_isLoading.value ? _handleSave : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: DevHabitatColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isLoading.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            widget.targetFeature != null
                                ? '${_getFeatureDisplayName(widget.targetFeature)} Başlat'
                                : 'Kurulumu Tamamla',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
              )),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => Get.back(result: false),
          child: Text(
            'Sonra Yaparım',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  int _getCompletedFieldsCount() {
    int count = 0;
    for (final field in relevantFields) {
      if (_isFieldCompleted(field.name)) {
        count++;
      }
    }
    return count;
  }

  bool _isFieldCompleted(String fieldName) {
    switch (fieldName) {
      case 'bio':
        return _bioController.text.trim().length >= 20;
      case 'skills':
        return _selectedSkills.length >= 3;
      case 'githubUsername':
        return _githubController.text.trim().isNotEmpty;
      case 'location':
        return _locationController.text.trim().isNotEmpty;
      default:
        return false;
    }
  }

  bool _isFormComplete() {
    for (final field in relevantFields) {
      if (!_isFieldCompleted(field.name)) {
        return false;
      }
    }
    return true;
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate() || !_isFormComplete()) {
      return;
    }

    _isLoading.value = true;

    try {
      final userService = Get.find<UserService>();

      // Update user data
      final updatedUser = widget.user.copyWith(
        bio: _bioController.text.trim().isNotEmpty
            ? _bioController.text.trim()
            : widget.user.bio,
        skills: _selectedSkills.isNotEmpty
            ? _selectedSkills.toList()
            : widget.user.skills,
        githubUsername: _githubController.text.trim().isNotEmpty
            ? _githubController.text.trim()
            : widget.user.githubUsername,
      );

      // Save to Firebase
      await userService.updateUser(updatedUser);

      // Show success message
      Get.snackbar(
        'Başarılı!',
        'Profil bilgilerin güncellendi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: DevHabitatColors.success,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      // Return success
      Get.back(result: true);
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Profil güncellenirken bir hata oluştu: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  String _getFeatureDisplayName(String? feature) {
    switch (feature) {
      case 'community_join':
        return 'Topluluk';
      case 'project_sharing':
        return 'Proje Paylaşımı';
      case 'video_calling':
        return 'Video Görüşme';
      case 'messaging':
        return 'Mesajlaşma';
      case 'networking':
        return 'Ağ Oluşturma';
      case 'portfolio_showcase':
        return 'Portföy';
      default:
        return 'Özellik';
    }
  }

  IconData _getFeatureIcon(String? feature) {
    switch (feature) {
      case 'community_join':
        return Icons.groups;
      case 'project_sharing':
        return Icons.share;
      case 'video_calling':
        return Icons.video_call;
      case 'messaging':
        return Icons.message;
      case 'networking':
        return Icons.connect_without_contact;
      case 'portfolio_showcase':
        return Icons.work;
      default:
        return Icons.settings;
    }
  }
}
