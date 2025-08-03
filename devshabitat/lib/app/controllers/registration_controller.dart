import 'package:devshabitat/app/repositories/auth_repository.dart';
import 'package:devshabitat/app/services/storage_service.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/services/error_handler_service.dart';
import '../controllers/auth_controller.dart';
import '../services/github_oauth_service.dart';
import '../services/github_service.dart';
import 'package:logger/logger.dart';

enum RegistrationStep {
  basicInfo, // Email, şifre ve isim (zorunlu)
  personalInfo, // Bio, konum, fotoğraf (opsiyonel)
  professionalInfo, // İş deneyimi, eğitim (opsiyonel)
  skillsInfo, // Yetenekler, diller (opsiyonel)
  completed,
}

class RegistrationController extends GetxController {
  final AuthRepository _authRepository;
  final ErrorHandlerService _errorHandler;
  final AuthController _authController;
  final Logger _logger = Get.find<Logger>();

  // Form keys
  final basicInfoFormKey = GlobalKey<FormState>();

  // Reactive state variables
  final _currentStep = RegistrationStep.basicInfo.obs;
  final _isLoading = false.obs;
  final _lastError = RxnString();
  final _isEmailValid = false.obs;
  final _isPasswordValid = false.obs;
  final _isDisplayNameValid = false.obs;

  // Password validation states
  final _hasMinLength = false.obs;
  final _hasUppercase = false.obs;
  final _hasLowercase = false.obs;
  final _hasNumber = false.obs;
  final _hasSpecialChar = false.obs;
  final _passwordsMatch = false.obs;
  final _passwordIsEmpty = true.obs;
  final _confirmPasswordIsEmpty = true.obs;

  // Basic Info Controllers (Zorunlu)
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final displayNameController = TextEditingController();

  // Personal Info Controllers (Opsiyonel)
  final bioController = TextEditingController();
  final locationController = TextEditingController();
  final photoUrlController = TextEditingController();
  final locationNameController = TextEditingController();

  // Professional Info Controllers (Opsiyonel)
  final titleController = TextEditingController();
  final companyController = TextEditingController();
  final yearsOfExperienceController = TextEditingController();

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

  // Sayfa indeksi (0: basic, 1: personal, 2: professional, 3: skills)
  final _currentPageIndex = 0.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  RegistrationStep get currentStep => _currentStep.value;
  String? get lastError => _lastError.value;
  bool get isEmailValid => _isEmailValid.value;
  bool get isPasswordValid => _isPasswordValid.value;
  bool get isDisplayNameValid => _isDisplayNameValid.value;

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

  int get currentPageIndex => _currentPageIndex.value;

  bool get canGoNext {
    switch (_currentPageIndex.value) {
      case 0: // Basic info - GitHub bağlantısı zorunlu
        return _isEmailValid.value &&
            _isDisplayNameValid.value &&
            allPasswordRequirementsMet &&
            _isGithubConnected.value;
      case 1: // Personal info - opsiyonel
      case 2: // Professional info - opsiyonel
      case 3: // Skills info - opsiyonel
        return true;
      default:
        return false;
    }
  }

  bool get isLastPage => _currentPageIndex.value == 3;
  bool get isFirstPage => _currentPageIndex.value == 0;

  void nextPage() {
    if (!canGoNext) return;

    if (isLastPage) {
      // Son sayfa - kayıt işlemini yap
      _performRegistration();
    } else {
      // Sadece sayfa değiştir, auth işlemi yapma
      _currentPageIndex.value++;
    }
  }

  void previousPage() {
    if (!isFirstPage) {
      _currentPageIndex.value--;
    }
  }

  void skipCurrentPage() {
    if (!isLastPage) {
      _currentPageIndex.value++;
    }
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

    // Email validation
    emailController.addListener(_validateEmail);

    // Display name validation
    displayNameController.addListener(_validateDisplayName);

    // Password validation
    passwordController.addListener(_validatePassword);
    confirmPasswordController.addListener(_validatePasswordConfirmation);
  }

  void _validateEmail() {
    final email = emailController.text;
    _isEmailValid.value = email.isNotEmpty && GetUtils.isEmail(email);
  }

  void _validateDisplayName() {
    final name = displayNameController.text;
    _isDisplayNameValid.value = name.isNotEmpty && name.length >= 3;
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
          _validateEmail();
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
      _validateEmail();
    }

    // Display name doldur (eğer boşsa)
    if (githubData['name'] != null &&
        githubData['name'].toString().isNotEmpty &&
        displayNameController.text.isEmpty) {
      displayNameController.text = githubData['name'];
      _validateDisplayName();
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
        locationController.text.isEmpty) {
      locationController.text = githubData['location'];
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
              locationController.text.isEmpty) {
            locationController.text = githubStats.location!;
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
        _validateEmail();
      }

      if (githubData['displayName'] != null &&
          displayNameController.text.isEmpty) {
        displayNameController.text = githubData['displayName'];
        _validateDisplayName();
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
  Future<void> _sendEmailVerification() async {
    try {
      final user = _authRepository.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();

        Get.snackbar(
          'Email Doğrulama',
          'Doğrulama emaili ${user.email} adresine gönderildi.',
          backgroundColor: Colors.blue.withOpacity(0.8),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
          icon: const Icon(Icons.email, color: Colors.white),
        );
      }
    } catch (e) {
      print('Email verification gönderilemedi: $e');
      // Email verification başarısız olsa bile registration devam etsin
    }
  }

  void _validatePassword() {
    final password = passwordController.text;

    _passwordIsEmpty.value = password.isEmpty;
    _hasMinLength.value = password.length >= 8;
    _hasUppercase.value = password.contains(RegExp(r'[A-Z]'));
    _hasLowercase.value = password.contains(RegExp(r'[a-z]'));
    _hasNumber.value = password.contains(RegExp(r'[0-9]'));
    _hasSpecialChar.value = password.contains(
      RegExp(r'[!@#$%^&*(),.?":{}|<>]'),
    );

    _isPasswordValid.value = allPasswordRequirementsMet;

    // Also validate password confirmation when password changes
    _validatePasswordConfirmation();
  }

  void _validatePasswordConfirmation() {
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    _confirmPasswordIsEmpty.value = confirmPassword.isEmpty;
    _passwordsMatch.value =
        confirmPassword.isNotEmpty && password == confirmPassword;
  }

  Future<void> proceedToNextStep() async {
    if (!canGoNext) return;

    switch (_currentStep.value) {
      case RegistrationStep.basicInfo:
        // Sadece validasyon yap, kayıt etme
        if (_validateBasicInfo()) {
          // Kullanıcıyı oluştur ve geçici ID'yi kaydet
          final userCredential = await _authRepository
              .createUserWithEmailAndPassword(
                emailController.text,
                passwordController.text,
                displayNameController.text,
              );

          if (userCredential.user != null) {
            _tempUserId.value = userCredential.user!.uid;
            _currentStep.value = RegistrationStep.personalInfo;
          }
        }
        break;
      case RegistrationStep.personalInfo:
        // Opsiyonel adım, direkt geç
        _currentStep.value = RegistrationStep.professionalInfo;
        break;
      case RegistrationStep.professionalInfo:
        // Opsiyonel adım, direkt geç
        _currentStep.value = RegistrationStep.skillsInfo;
        break;
      case RegistrationStep.skillsInfo:
        // Son adım - gerçek kayıt işlemini yap
        if (await _completeRegistration()) {
          _currentStep.value = RegistrationStep.completed;
          // Email verification gönder
          await _sendEmailVerification();
          // Biraz bekle ki state güncellensin, sonra email verification sayfasına yönlendir
          await Future.delayed(Duration(milliseconds: 200));
          Get.offAllNamed('/email-verification');
        }
        break;
      case RegistrationStep.completed:
        break;
    }
  }

  bool _validateBasicInfo() {
    // Form validasyonunu kontrol et
    if (basicInfoFormKey.currentState?.validate() ?? false) {
      return allPasswordRequirementsMet;
    }
    return false;
  }

  Future<bool> _completeRegistration() async {
    try {
      _isLoading.value = true;

      // GitHub bağlantısı kontrolü
      if (!_isGithubConnected.value || _githubUsername.value == null) {
        Get.snackbar(
          'Hata',
          'Devam etmek için GitHub hesabınızı bağlamanız gerekmektedir.',
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
          icon: const Icon(Icons.error, color: Colors.white),
        );
        return false;
      }

      // 1. Önce kullanıcıyı kaydet
      final userCredential = await _authRepository
          .createUserWithEmailAndPassword(
            emailController.text,
            passwordController.text,
            displayNameController.text,
          );

      if (userCredential.user == null) {
        throw Exception('Kullanıcı oluşturulamadı');
      }

      // Geçici ID'yi kaydet
      _tempUserId.value = userCredential.user!.uid;

      // 2. Tüm ek bilgileri güncelle
      final updates = <String, dynamic>{
        // Personal Info
        'bio': bioController.text,
        'locationName': locationNameController.text,
        'photoUrl': photoUrlController.text,
        if (location.value != null) 'location': location.value,

        // Professional Info
        'title': titleController.text,
        'company': companyController.text,
        'yearsOfExperience':
            int.tryParse(yearsOfExperienceController.text) ?? 0,
        'isAvailableForWork': isAvailableForWork.value,
        'isRemote': isRemote.value,
        'isFullTime': isFullTime.value,
        'isPartTime': isPartTime.value,
        'isFreelance': isFreelance.value,
        'isInternship': isInternship.value,
        'workExperience': workExperience,
        'education': education,
        'projects': projects,
        'certificates': certificates,

        // Skills Info
        'skills': selectedSkills,
        'languages': selectedLanguages,
        'interests': selectedInterests,
        'socialLinks': socialLinks,
        'portfolioUrls': portfolioUrls,

        // GitHub Info (Zorunlu)
        'githubUsername': _githubUsername.value,
        'githubToken': _githubToken.value,
        'githubUserData': _githubUserData.value,
      };

      // Sadece dolu olan alanları güncelle
      final filteredUpdates = <String, dynamic>{};
      updates.forEach((key, value) {
        if (value != null &&
            value != '' &&
            value != 0 &&
            (value is! List || (value).isNotEmpty) &&
            (value is! Map || (value).isNotEmpty)) {
          filteredUpdates[key] = value;
        }
      });

      if (filteredUpdates.isNotEmpty) {
        await _authRepository.updateUserProfile(filteredUpdates);
      }

      return true;
    } catch (e) {
      _errorHandler.handleError(e, ErrorHandlerService.AUTH_ERROR);
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> updateProfilePhoto(String photoUrl) async {
    try {
      // Eğer kayıt aşamasındaysak sadece controller'ı güncelle
      if (_currentStep.value == RegistrationStep.personalInfo) {
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

  void goBack() {
    if (_currentStep.value == RegistrationStep.basicInfo) {
      Get.back();
    } else {
      switch (_currentStep.value) {
        case RegistrationStep.personalInfo:
          _currentStep.value = RegistrationStep.basicInfo;
          break;
        case RegistrationStep.professionalInfo:
          _currentStep.value = RegistrationStep.personalInfo;
          break;
        case RegistrationStep.skillsInfo:
          _currentStep.value = RegistrationStep.professionalInfo;
          break;
        default:
          break;
      }
    }
  }

  void skipCurrentStep() {
    proceedToNextStep();
  }

  String? getCurrentUserId() {
    // Eğer kayıt aşamasındaysak ve geçici ID varsa onu kullan
    if (_currentStep.value == RegistrationStep.personalInfo &&
        _tempUserId.isNotEmpty) {
      return _tempUserId.value;
    }

    // Değilse normal oturum kontrolü yap
    final currentUser = _authController.currentUser;
    if (currentUser == null) {
      // Sadece kayıt aşamasında değilsek login'e yönlendir
      if (_currentStep.value != RegistrationStep.personalInfo) {
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

      // GitHub bağlantısı kontrolü
      if (!_isGithubConnected.value || _githubUsername.value == null) {
        Get.snackbar(
          'Hata',
          'Devam etmek için GitHub hesabınızı bağlamanız gerekmektedir.',
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
          icon: const Icon(Icons.error, color: Colors.white),
        );
        return;
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
        duration: Duration(seconds: 2),
      );

      // 4. Auth controller'ların hazır olduğundan emin ol
      await Future.delayed(Duration(seconds: 2));

      // 5. Ana sayfaya yönlendir
      Get.offAllNamed('/home');
    } catch (e) {
      _errorHandler.handleError(e, ErrorHandlerService.AUTH_ERROR);
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
    if (locationController.text.isNotEmpty) {
      updates['location'] = locationController.text;
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

  // Google ile kayıt
  Future<void> signUpWithGoogle() async {
    try {
      _isLoading.value = true;

      // Google ile giriş yap
      final userCredential = await _authRepository.signInWithGoogle();
      if (userCredential.user == null) {
        throw Exception('Google ile giriş başarısız oldu');
      }

      // Otomatik form doldurma
      emailController.text = userCredential.user!.email ?? '';
      displayNameController.text = userCredential.user!.displayName ?? '';
      photoUrlController.text = userCredential.user!.photoURL ?? '';

      // Email ve display name validasyonlarını çalıştır
      _validateEmail();
      _validateDisplayName();

      // GitHub bağlantısı kontrolü
      if (!_isGithubConnected.value) {
        Get.snackbar(
          'GitHub Bağlantısı Gerekli',
          'Lütfen devam etmek için GitHub hesabınızı bağlayın.',
          backgroundColor: Colors.orange.withOpacity(0.8),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
          icon: const Icon(Icons.warning, color: Colors.white),
        );
      }
    } catch (e) {
      _errorHandler.handleError(e, ErrorHandlerService.AUTH_ERROR);
    } finally {
      _isLoading.value = false;
    }
  }

  // Apple ile kayıt
  Future<void> signUpWithApple() async {
    try {
      _isLoading.value = true;

      // Apple ile giriş yap
      final userCredential = await _authRepository.signInWithApple();
      if (userCredential.user == null) {
        throw Exception('Apple ile giriş başarısız oldu');
      }

      // Otomatik form doldurma
      emailController.text = userCredential.user!.email ?? '';
      displayNameController.text = userCredential.user!.displayName ?? '';

      // Email ve display name validasyonlarını çalıştır
      _validateEmail();
      _validateDisplayName();

      // GitHub bağlantısı kontrolü
      if (!_isGithubConnected.value) {
        Get.snackbar(
          'GitHub Bağlantısı Gerekli',
          'Lütfen devam etmek için GitHub hesabınızı bağlayın.',
          backgroundColor: Colors.orange.withOpacity(0.8),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
          icon: const Icon(Icons.warning, color: Colors.white),
        );
      }
    } catch (e) {
      _errorHandler.handleError(e, ErrorHandlerService.AUTH_ERROR);
    } finally {
      _isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    displayNameController.dispose();
    bioController.dispose();
    locationController.dispose();
    photoUrlController.dispose();
    locationNameController.dispose();
    titleController.dispose();
    companyController.dispose();
    yearsOfExperienceController.dispose();
    super.onClose();
  }
}
