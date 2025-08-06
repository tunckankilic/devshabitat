import 'package:devshabitat/app/core/services/form_validation_service.dart'
    show FormValidationService;
import 'package:devshabitat/app/repositories/auth_repository.dart';
import 'package:devshabitat/app/services/storage_service.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/services/error_handler_service.dart';
import '../core/services/step_navigation_service.dart';
import '../controllers/auth_controller.dart';
import '../services/github_oauth_service.dart';
import '../services/github_service.dart';
import 'package:logger/logger.dart';
import '../core/mixins/controller_lifecycle_mixin.dart';

// Step configurations
final List<StepConfiguration> _registrationSteps = [
  StepConfiguration(
    id: 'basicInfo',
    title: 'Temel Bilgiler',
    description: 'Email, şifre ve isim bilgilerinizi girin',
    isRequired: true,
    canSkip: false,
    requiredFields: ['email', 'password', 'displayName', 'githubConnection'],
  ),
  StepConfiguration(
    id: 'personalInfo',
    title: 'Kişisel Bilgiler',
    description: 'Bio, konum ve fotoğraf bilgilerinizi girin',
    isRequired: false,
    canSkip: true,
    optionalFields: ['bio', 'location', 'photo'],
  ),
  StepConfiguration(
    id: 'professionalInfo',
    title: 'Profesyonel Bilgiler',
    description: 'İş deneyimi ve eğitim bilgilerinizi girin',
    isRequired: false,
    canSkip: true,
    optionalFields: ['title', 'company', 'experience', 'education'],
  ),
  StepConfiguration(
    id: 'skillsInfo',
    title: 'Yetenekler',
    description: 'Yetenekler, diller ve ilgi alanlarınızı girin',
    isRequired: false,
    canSkip: true,
    optionalFields: ['skills', 'languages', 'interests'],
  ),
];

class RegistrationController extends GetxController
    with ControllerLifecycleMixin {
  final AuthRepository _authRepository;
  final ErrorHandlerService _errorHandler;
  final AuthController _authController;
  final Logger _logger = Get.find<Logger>();

  // Form keys
  final basicInfoFormKey = GlobalKey<FormState>();

  // Reactive state variables
  final _isLoading = false.obs;
  final _lastError = RxnString();
  final _isEmailValid = false.obs;
  final _isPasswordValid = false.obs;
  final _isDisplayNameValid = false.obs;

  // Step navigation service
  late final StepNavigationService _stepNavigation;

  // Password validation states
  final _hasMinLength = false.obs;
  final _hasUppercase = false.obs;
  final _hasLowercase = false.obs;
  final _hasNumber = false.obs;
  final _hasSpecialChar = false.obs;
  final _passwordsMatch = false.obs;
  final _passwordIsEmpty = true.obs;
  final _confirmPasswordIsEmpty = true.obs;

  // Controllers
  late final TextEditingController emailController;
  late final TextEditingController passwordController;
  late final TextEditingController confirmPasswordController;
  late final TextEditingController displayNameController;
  late final TextEditingController bioController;
  late final TextEditingController locationTextController;
  late final TextEditingController photoUrlController;
  late final TextEditingController locationNameController;
  late final TextEditingController titleController;
  late final TextEditingController companyController;
  late final TextEditingController yearsOfExperienceController;

  // Location tracking
  GeoPoint? lastValidLocation;

  // Work Preferences
  final isAvailableForWork = true.obs;
  final isRemote = false.obs;
  final isFullTime = false.obs;
  final isPartTime = false.obs;
  final isFreelance = false.obs;
  final isInternship = false.obs;

  // Skills Info Controllers (Opsiyonel)
  final RxList<String> selectedSkills = <String>[].obs;
  final RxList<String> selectedLanguages = <String>[].obs;
  final RxList<String> selectedInterests = <String>[].obs;
  final RxMap<String, String> socialLinks = <String, String>{}.obs;
  final RxList<String> portfolioUrls = <String>[].obs;
  final RxList<Map<String, dynamic>> workExperience =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> education = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> projects = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> certificates =
      <Map<String, dynamic>>[].obs;

  // Location data
  final Rxn<GeoPoint> location = Rxn<GeoPoint>();

  // GitHub Integration (Zorunlu)
  final _isGithubConnected = false.obs;
  final _githubUsername = RxnString();
  final _githubToken = RxnString();
  final _githubUserData = Rxn<Map<String, dynamic>>();
  final _isGithubLoading = false.obs;

  // Geçici kullanıcı ID'si için
  final RxString _tempUserId = RxString('');

  // Getters
  bool get isLoading => _isLoading.value;
  String? get lastError => _lastError.value;
  bool get isEmailValid => _isEmailValid.value;
  bool get isPasswordValid => _isPasswordValid.value;
  bool get isDisplayNameValid => _isDisplayNameValid.value;

  // Step navigation getters
  int get currentStepIndex => _stepNavigation.currentStepIndex;
  StepConfiguration get currentStep => _stepNavigation.currentStep;
  bool get isFirstStep => _stepNavigation.isFirstStep;
  bool get isLastStep => _stepNavigation.isLastStep;
  bool get canGoNext => _stepNavigation.canMoveNext() && canMoveNext;
  bool get canGoPrevious => _stepNavigation.canMovePrevious();
  bool get canSkip => _stepNavigation.canSkipStep();
  bool get hasUnsavedChanges => _stepNavigation.hasUnsavedChanges;

  // Password validation getters
  bool get hasMinLength => _hasMinLength.value;

  // GitHub getters
  bool get isGithubConnected => _isGithubConnected.value;
  String? get githubUsername => _githubUsername.value;
  String? get githubToken => _githubToken.value;
  Map<String, dynamic>? get githubUserData => _githubUserData.value;
  bool get isGithubLoading => _isGithubLoading.value;
  bool get hasUppercase => _hasUppercase.value;
  bool get hasLowercase => _hasLowercase.value;
  bool get hasNumber => _hasNumber.value;
  bool get hasSpecialChar => _hasSpecialChar.value;
  bool get passwordsMatch => _passwordsMatch.value;
  bool get passwordIsEmpty => _passwordIsEmpty.value;
  bool get confirmPasswordIsEmpty => _confirmPasswordIsEmpty.value;

  bool get allPasswordRequirementsMet =>
      hasMinLength &&
      hasUppercase &&
      hasLowercase &&
      hasNumber &&
      hasSpecialChar &&
      passwordsMatch;

  bool get canMoveNext {
    // Basic info - GitHub bağlantısı zorunlu
    if (currentStep.id == 'basicInfo') {
      return _isEmailValid.value &&
          _isDisplayNameValid.value &&
          allPasswordRequirementsMet &&
          _isGithubConnected.value;
    }

    // Diğer adımlar opsiyonel
    return true;
  }

  // Duplicate getters removed

  Future<void> nextPage() async {
    if (!canGoNext) return;

    if (isLastStep) {
      // Son sayfa - kayıt işlemini yap
      await _performRegistration();
    } else {
      // Geçerli adımı tamamlandı olarak işaretle
      _stepNavigation.markStepAsCompleted(currentStep.id);

      // Sonraki adıma geç
      await _stepNavigation.moveNext();
    }
  }

  Future<void> previousPage() async {
    if (!canGoPrevious) return;

    // Değişiklikler varsa kullanıcıya sor
    if (hasUnsavedChanges) {
      final result = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Kaydedilmemiş Değişiklikler'),
          content: const Text(
            'Kaydedilmemiş değişiklikleriniz var. Devam etmek istiyor musunuz?',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Devam Et'),
            ),
          ],
        ),
      );

      if (result != true) return;
    }

    // Önceki adıma dön
    await _stepNavigation.movePrevious();
  }

  Future<void> skipStep() async {
    if (!canSkip) return;

    // Adımı atla
    await _stepNavigation.skipStep();
  }

  Future<bool> handleBackButton() async {
    // Navigation history'de geri dönülebilecek adım varsa
    if (_stepNavigation.canGoBack()) {
      return _stepNavigation.goBack();
    }

    // Yoksa ilk sayfadaysa uygulamadan çık
    if (isFirstStep) {
      final result = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Kayıt İşleminden Çık'),
          content: const Text(
            'Kayıt işleminden çıkmak istediğinize emin misiniz?',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Çık'),
            ),
          ],
        ),
      );

      if (result == true) {
        Get.back();
        return true;
      }
    }

    return false;
  }

  RegistrationController({
    required AuthRepository authRepository,
    required ErrorHandlerService errorHandler,
    required AuthController authController,
  }) : _authRepository = authRepository,
       _errorHandler = errorHandler,
       _authController = authController;

  @override
  void onInit() {
    super.onInit();

    // Step navigation service'i başlat
    _stepNavigation = Get.put(StepNavigationService(_registrationSteps));

    // Controller'ları factory method ile oluştur
    emailController = createController();
    passwordController = createController();
    confirmPasswordController = createController();
    displayNameController = createController();
    bioController = createController();
    locationTextController = createController();
    photoUrlController = createController();
    locationNameController = createController();
    titleController = createController();
    companyController = createController();
    yearsOfExperienceController = createController();

    // Workers'ları factory method ile oluştur
    createWorker(ever(_isEmailValid, (_) => _validateForm()));
    createWorker(ever(_isPasswordValid, (_) => _validateForm()));
    createWorker(ever(_isDisplayNameValid, (_) => _validateForm()));

    // Listener'ları ekle
    emailController.addListener(() {
      validateEmail();
      _stepNavigation.setUnsavedChanges(true);
    });
    displayNameController.addListener(() {
      validateDisplayName();
      _stepNavigation.setUnsavedChanges(true);
    });
    passwordController.addListener(() {
      validatePassword();
      _stepNavigation.setUnsavedChanges(true);
    });
    confirmPasswordController.addListener(() {
      validatePasswordConfirmation();
      _stepNavigation.setUnsavedChanges(true);
    });

    // Form değişikliklerini takip et
    bioController.addListener(() => _stepNavigation.setUnsavedChanges(true));
    locationTextController.addListener(
      () => _stepNavigation.setUnsavedChanges(true),
    );
    photoUrlController.addListener(
      () => _stepNavigation.setUnsavedChanges(true),
    );
    locationNameController.addListener(
      () => _stepNavigation.setUnsavedChanges(true),
    );
    titleController.addListener(() => _stepNavigation.setUnsavedChanges(true));
    companyController.addListener(
      () => _stepNavigation.setUnsavedChanges(true),
    );
    yearsOfExperienceController.addListener(
      () => _stepNavigation.setUnsavedChanges(true),
    );
  }

  void _validateForm() {
    if (basicInfoFormKey.currentState?.validate() ?? false) {
      // Form geçerli, adımı tamamlandı olarak işaretle
      _stepNavigation.markStepAsCompleted(currentStep.id);
      _stepNavigation.setUnsavedChanges(false);
    } else {
      // Form geçersiz, adımı hata durumuna al
      _stepNavigation.markStepAsError(currentStep.id);
    }
  }

  @override
  void onClose() {
    // Step navigation service'i temizle
    _stepNavigation.reset();
    Get.delete<StepNavigationService>();

    // Form controller'larını temizle
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    displayNameController.dispose();
    bioController.dispose();
    locationTextController.dispose();
    photoUrlController.dispose();
    locationNameController.dispose();
    titleController.dispose();
    companyController.dispose();
    yearsOfExperienceController.dispose();

    super.onClose();
  }

  final _formValidation = Get.find<FormValidationService>();

  void validateEmail() {
    final email = emailController.text;
    _formValidation.validateFieldWithDebounce('email', email, (value) async {
      if (value.isEmpty) {
        _isEmailValid.value = false;
        return 'Email adresi gereklidir';
      }
      if (!GetUtils.isEmail(value)) {
        _isEmailValid.value = false;
        return 'Geçerli bir email adresi giriniz';
      }
      _isEmailValid.value = true;
      return null;
    });
  }

  void validateDisplayName() {
    final name = displayNameController.text;
    _formValidation.validateFieldWithDebounce('displayName', name, (
      value,
    ) async {
      if (value.isEmpty) {
        _isDisplayNameValid.value = false;
        return 'İsim gereklidir';
      }
      if (value.length < 3) {
        _isDisplayNameValid.value = false;
        return 'İsim en az 3 karakter olmalıdır';
      }
      _isDisplayNameValid.value = true;
      return null;
    });
  }

  // GitHub verilerini çek
  Future<void> importGithubData() async {
    try {
      _isGithubLoading.value = true;

      final githubOAuthService = Get.find<GitHubOAuthService>();

      // GitHub OAuth ile token al
      final accessToken = await githubOAuthService.getGithubAccessToken();
      if (accessToken == null) {
        Get.snackbar(
          'Bilgi',
          'GitHub verilerini almak için yetkilendirme iptal edildi',
          backgroundColor: Colors.orange.withOpacity(0.8),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
        return;
      }

      // GitHub kullanıcı bilgilerini çek
      final userInfo = await githubOAuthService.getUserInfo(accessToken);
      if (userInfo != null) {
        // Form alanlarını doldur
        _populateFormFromGithubData(userInfo);

        // GitHub verilerini sakla
        _githubUsername.value = userInfo['login'];
        _githubToken.value = accessToken;
        _githubUserData.value = userInfo;
        _isGithubConnected.value = true;

        // Repository bilgilerini çek
        final repos = await githubOAuthService.getUserRepositories(accessToken);
        if (repos != null) {
          _githubUserData.value = {
            ..._githubUserData.value ?? {},
            'repositories': repos,
          };
        }

        // Email bilgilerini çek
        final emails = await githubOAuthService.getUserEmails(accessToken);
        if (emails != null &&
            emails.isNotEmpty &&
            emailController.text.isEmpty) {
          emailController.text = emails.first;
          validateEmail();
        }

        Get.snackbar(
          'Başarılı!',
          'GitHub verileriniz form alanlarına aktarıldı',
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
          icon: const Icon(Icons.check_circle, color: Colors.white),
        );
      }
    } catch (e) {
      _lastError.value = e.toString();
      Get.snackbar(
        'Hata',
        'GitHub verileri alınırken bir hata oluştu: $e',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
        icon: const Icon(Icons.error, color: Colors.white),
      );
    } finally {
      _isGithubLoading.value = false;
    }
  }

  // GitHub verilerini form alanlarına aktar
  void _populateFormFromGithubData(Map<String, dynamic> githubData) {
    // Email doldur (eğer boşsa)
    if (githubData['email'] != null &&
        githubData['email'].toString().isNotEmpty &&
        emailController.text.isEmpty) {
      emailController.text = githubData['email'];
      validateEmail();
    }

    // Display name doldur (eğer boşsa)
    if (githubData['name'] != null &&
        githubData['name'].toString().isNotEmpty &&
        displayNameController.text.isEmpty) {
      displayNameController.text = githubData['name'];
      validateDisplayName();
    }

    // Bio doldur (eğer boşsa)
    if (githubData['bio'] != null &&
        githubData['bio'].toString().isNotEmpty &&
        bioController.text.isEmpty) {
      bioController.text = githubData['bio'];
    }

    // Location doldur (eğer boşsa)
    if (githubData['location'] != null &&
        githubData['location'].toString().isNotEmpty &&
        locationTextController.text.isEmpty) {
      locationTextController.text = githubData['location'];
    }

    // Company doldur (eğer boşsa)
    if (githubData['company'] != null &&
        githubData['company'].toString().isNotEmpty &&
        companyController.text.isEmpty) {
      companyController.text = githubData['company'];
    }
  }

  // GitHub verilerini çek ve form alanlarını doldur
  Future<void> _fetchAndPopulateGithubData() async {
    try {
      if (_githubUsername.value != null && _githubUsername.value!.isNotEmpty) {
        final githubService = Get.find<GithubService>();

        // GitHub stats'ları çek
        final githubStats = await githubService.getGithubStats(
          _githubUsername.value!,
        );

        if (githubStats != null) {
          // Bio bilgisini GitHub'dan al
          if (githubStats.bio != null &&
              githubStats.bio!.isNotEmpty &&
              bioController.text.isEmpty) {
            bioController.text = githubStats.bio!;
          }

          // Location bilgisini GitHub'dan al
          if (githubStats.location != null &&
              githubStats.location!.isNotEmpty &&
              locationTextController.text.isEmpty) {
            locationTextController.text = githubStats.location!;
          }

          // Company bilgisini GitHub'dan al
          if (githubStats.company != null &&
              githubStats.company!.isNotEmpty &&
              companyController.text.isEmpty) {
            companyController.text = githubStats.company!;
          }

          // Tech stack'i skills olarak ekle
          final techStack = await githubService.getTechStack(
            _githubUsername.value!,
          );
          if (techStack.isNotEmpty) {
            for (final tech in techStack.take(10)) {
              // İlk 10 teknolojiyi al
              if (!selectedSkills.contains(tech)) {
                selectedSkills.add(tech);
              }
            }
          }

          // GitHub verilerini güncelle
          _githubUserData.value = {
            ..._githubUserData.value ?? {},
            'stats': githubStats.toJson(),
            'techStack': techStack,
            'lastSync': DateTime.now().toIso8601String(),
          };
        }
      }
    } catch (e) {
      _logger.e('GitHub verilerini çekerken hata: $e');
    }
  }

  // Düzenli GitHub veri güncellemesi için metod
  Future<void> updateGithubData() async {
    try {
      if (_githubUsername.value != null && _githubUsername.value!.isNotEmpty) {
        await _fetchAndPopulateGithubData();

        Get.snackbar(
          'Güncelleme Başarılı',
          'GitHub verileriniz güncellendi',
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
          icon: const Icon(Icons.refresh, color: Colors.white),
        );
      }
    } catch (e) {
      _logger.e('GitHub veri güncelleme hatası: $e');
      Get.snackbar(
        'Güncelleme Hatası',
        'GitHub verileri güncellenirken bir hata oluştu',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.error, color: Colors.white),
      );
    }
  }

  // GitHub bilgilerini form alanlarına aktar
  void setGithubUserData(Map<String, dynamic> githubData) {
    try {
      // Email ve isim bilgilerini aktar (eğer boşsa)
      if (githubData['email'] != null && emailController.text.isEmpty) {
        emailController.text = githubData['email'];
        validateEmail();
      }

      if (githubData['displayName'] != null &&
          displayNameController.text.isEmpty) {
        displayNameController.text = githubData['displayName'];
        validateDisplayName();
      }

      // GitHub kullanıcı adını kaydet
      _githubUsername.value = githubData['githubUsername'];

      // GitHub token'ı kaydet
      _githubToken.value = githubData['githubToken'];

      // GitHub kullanıcı verilerini sakla
      _githubUserData.value = githubData['githubUserData'];

      // GitHub bağlantısını başarılı olarak işaretle
      _isGithubConnected.value = githubData['isGithubConnected'] ?? true;

      // GitHub yükleme durumunu güncelle
      _isGithubLoading.value = false;

      // Kullanıcıya bilgilendirme mesajı göster
      Get.snackbar(
        'GitHub Bağlantısı Başarılı',
        'GitHub hesabınız bağlandı! Şimdi diğer bilgilerinizi doldurun ve devam edin.',
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );
    } catch (e) {
      _lastError.value = e.toString();
      _isGithubConnected.value = false;
      _isGithubLoading.value = false;

      Get.snackbar(
        'Hata',
        'GitHub bilgileri aktarılırken bir hata oluştu: $e',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
        icon: const Icon(Icons.error, color: Colors.white),
      );
    }
  }

  // GitHub bağlantısını kaldır
  void disconnectGithub() {
    _isGithubConnected.value = false;
    _githubUsername.value = null;
    _githubToken.value = null;
    _githubUserData.value = null;

    Get.snackbar(
      'Bilgi',
      'GitHub bağlantısı kaldırıldı',
      backgroundColor: Colors.orange.withOpacity(0.8),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  // Email verification gönder

  void validatePassword() {
    final password = passwordController.text;
    _formValidation.validateFieldWithDebounce('password', password, (
      value,
    ) async {
      _passwordIsEmpty.value = value.isEmpty;
      _hasMinLength.value = value.length >= 8;
      _hasUppercase.value = value.contains(RegExp(r'[A-Z]'));
      _hasLowercase.value = value.contains(RegExp(r'[a-z]'));
      _hasNumber.value = value.contains(RegExp(r'[0-9]'));
      _hasSpecialChar.value = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

      if (value.isEmpty) {
        _isPasswordValid.value = false;
        return 'Şifre gereklidir';
      }

      final errors = <String>[];
      if (!_hasMinLength.value) errors.add('En az 8 karakter');
      if (!_hasUppercase.value) errors.add('En az bir büyük harf');
      if (!_hasLowercase.value) errors.add('En az bir küçük harf');
      if (!_hasNumber.value) errors.add('En az bir rakam');
      if (!_hasSpecialChar.value) errors.add('En az bir özel karakter');

      if (errors.isNotEmpty) {
        _isPasswordValid.value = false;
        return 'Şifre gereksinimleri:\n${errors.map((e) => '• $e').join('\n')}';
      }

      _isPasswordValid.value = true;
      return null;
    });

    // Şifre değiştiğinde onay şifresini de kontrol et
    validatePasswordConfirmation();
  }

  void validatePasswordConfirmation() {
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    _formValidation.validateFieldWithDebounce(
      'confirmPassword',
      confirmPassword,
      (value) async {
        _confirmPasswordIsEmpty.value = value.isEmpty;

        if (value.isEmpty) {
          _passwordsMatch.value = false;
          return 'Şifre onayı gereklidir';
        }

        if (value != password) {
          _passwordsMatch.value = false;
          return 'Şifreler eşleşmiyor';
        }

        _passwordsMatch.value = true;
        return null;
      },
    );
  }

  Future<void> proceedToNextStep() async {
    if (!canGoNext) return;

    if (isLastStep) {
      // Son adım - gerçek kayıt işlemini yap
      await _performRegistration();
    } else {
      // Geçerli adımı tamamlandı olarak işaretle
      _stepNavigation.markStepAsCompleted(currentStep.id);

      // Sonraki adıma geç
      await _stepNavigation.moveNext();
    }
  }

  Future<void> updateProfilePhoto(String photoUrl) async {
    try {
      // Eğer kayıt aşamasındaysak sadece controller'ı güncelle
      if (currentStep.id == 'personalInfo') {
        photoUrlController.text = photoUrl;
        return;
      }

      // Normal profil güncellemesi
      final currentUser = _authController.currentUser;
      if (currentUser == null) {
        throw Exception(
          'Kullanıcı oturumu bulunamadı. Lütfen tekrar giriş yapın.',
        );
      }

      await _authRepository.updateUserProfile({'photoURL': photoUrl});

      // AuthController'daki profil bilgilerini güncelle
      await _authController.refreshUserProfile();
    } catch (e) {
      _errorHandler.handleError(e, ErrorHandlerService.AUTH_ERROR);
      throw Exception('Profil fotoğrafı güncellenirken bir hata oluştu');
    }
  }

  Future<void> goBack() async {
    if (isFirstStep) {
      Get.back();
    } else {
      await previousPage();
    }
  }

  Future<void> skipCurrentStep() async {
    await skipStep();
  }

  String? getCurrentUserId() {
    // Eğer kayıt aşamasındaysak ve geçici ID varsa onu kullan
    if (currentStep.id == 'personalInfo' && _tempUserId.isNotEmpty) {
      return _tempUserId.value;
    }

    // Değilse normal oturum kontrolü yap
    final currentUser = _authController.currentUser;
    if (currentUser == null) {
      // Sadece kayıt aşamasında değilsek login'e yönlendir
      if (currentStep.id != 'personalInfo') {
        Get.offAllNamed('/login');
      }
      return null;
    }
    return currentUser.uid;
  }

  // Tüm kayıt işlemini son sayfada yap
  Future<void> _performRegistration() async {
    try {
      _isLoading.value = true;

      // GitHub bağlantısı artık opsiyonel
      if (_isGithubConnected.value && _githubUsername.value != null) {
        // GitHub verilerini ekle
        await _fetchAndPopulateGithubData();
      }

      // 1. Firebase Authentication'da kullanıcı oluştur
      final userCredential = await _authRepository
          .createUserWithEmailAndPassword(
            emailController.text,
            passwordController.text,
            displayNameController.text,
          );

      if (userCredential.user == null) {
        throw Exception('Kullanıcı oluşturulamadı');
      }

      // 2. Kullanıcı profilini güncelle
      await _updateUserProfile(userCredential.user!.uid);

      // 3. Başarı mesajı göster
      Get.snackbar(
        'Başarılı!',
        'Kayıt işleminiz tamamlandı',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      // 4. Auth controller'ların hazır olduğundan emin ol
      await Future.delayed(const Duration(seconds: 2));

      // 5. Step navigation service'i temizle
      _stepNavigation.reset();

      // 6. Ana sayfaya yönlendir
      Get.offAllNamed('/home');
    } catch (e) {
      _errorHandler.handleError(e, ErrorHandlerService.AUTH_ERROR);
      _stepNavigation.markStepAsError(currentStep.id);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _updateUserProfile(String userId) async {
    final updates = <String, dynamic>{};

    // Eğer fotoğraf seçildiyse önce yükle
    if (photoUrlController.text.isNotEmpty &&
        !photoUrlController.text.startsWith('http')) {
      try {
        final uploadedUrl = await Get.find<StorageService>().uploadProfileImage(
          userId,
          photoUrlController.text,
        );
        if (uploadedUrl != null) {
          updates['photoUrl'] = uploadedUrl;
        }
      } catch (e) {
        print('Fotoğraf yükleme hatası: $e');
      }
    }

    // Diğer bilgiler...
    if (bioController.text.isNotEmpty) updates['bio'] = bioController.text;
    if (locationTextController.text.isNotEmpty) {
      updates['location'] = locationTextController.text;
    }
    if (locationNameController.text.isNotEmpty) {
      updates['locationName'] = locationNameController.text;
    }
    if (titleController.text.isNotEmpty) {
      updates['title'] = titleController.text;
    }
    if (companyController.text.isNotEmpty) {
      updates['company'] = companyController.text;
    }
    if (yearsOfExperienceController.text.isNotEmpty) {
      updates['yearsOfExperience'] =
          int.tryParse(yearsOfExperienceController.text) ?? 0;
    }
    updates['isAvailableForWork'] = isAvailableForWork.value;
    updates['isRemote'] = isRemote.value;
    updates['isFullTime'] = isFullTime.value;
    updates['isPartTime'] = isPartTime.value;
    updates['isFreelance'] = isFreelance.value;
    updates['isInternship'] = isInternship.value;
    updates['workExperience'] = workExperience;
    updates['education'] = education;
    updates['projects'] = projects;
    updates['certificates'] = certificates;
    updates['skills'] = selectedSkills;
    updates['languages'] = selectedLanguages;
    updates['interests'] = selectedInterests;
    updates['socialLinks'] = socialLinks;
    updates['portfolioUrls'] = portfolioUrls;

    if (location.value != null) updates['location'] = location.value;

    if (updates.isNotEmpty) {
      await _authRepository.updateUserProfile(updates);
    }
  }
}
