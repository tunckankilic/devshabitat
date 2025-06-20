import 'package:devshabitat/app/repositories/auth_repository.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../core/services/error_handler_service.dart';
import '../models/user_model.dart';

enum RegistrationStep {
  basicInfo, // Email, şifre ve isim (zorunlu)
  personalInfo, // Bio, konum, fotoğraf (opsiyonel)
  professionalInfo, // İş deneyimi, eğitim (opsiyonel)
  skillsInfo, // Yetenekler, diller (opsiyonel)
  completed
}

class RegistrationController extends GetxController {
  final AuthRepository _authRepository;
  final ErrorHandlerService _errorHandler;

  // Form keys
  final basicInfoFormKey = GlobalKey<FormState>();

  // Reactive state variables
  final _currentStep = RegistrationStep.basicInfo.obs;
  final _isLoading = false.obs;
  final _lastError = RxnString();
  final _isEmailValid = false.obs;
  final _isPasswordValid = false.obs;
  final _isDisplayNameValid = false.obs;

  // Basic Info Controllers (Zorunlu)
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final displayNameController = TextEditingController();

  // Personal Info Controllers (Opsiyonel)
  final bioController = TextEditingController();
  final locationController = TextEditingController();
  final photoUrlController = TextEditingController();

  // Professional Info Controllers (Opsiyonel)
  final titleController = TextEditingController();
  final companyController = TextEditingController();
  final yearsOfExperienceController = TextEditingController();

  // Skills Info Controllers (Opsiyonel)
  final RxList<String> selectedSkills = <String>[].obs;
  final RxList<String> selectedLanguages = <String>[].obs;
  final RxList<String> selectedFrameworks = <String>[].obs;

  // Getters
  bool get isLoading => _isLoading.value;
  RegistrationStep get currentStep => _currentStep.value;
  String? get lastError => _lastError.value;
  bool get isEmailValid => _isEmailValid.value;
  bool get isPasswordValid => _isPasswordValid.value;
  bool get isDisplayNameValid => _isDisplayNameValid.value;
  bool get canProceedToNextStep {
    switch (_currentStep.value) {
      case RegistrationStep.basicInfo:
        return _isEmailValid.value &&
            _isPasswordValid.value &&
            _isDisplayNameValid.value &&
            passwordController.text == confirmPasswordController.text;
      case RegistrationStep.personalInfo:
      case RegistrationStep.professionalInfo:
      case RegistrationStep.skillsInfo:
        return true; // Opsiyonel adımlar
      case RegistrationStep.completed:
        return true;
    }
  }

  RegistrationController({
    required AuthRepository authRepository,
    required ErrorHandlerService errorHandler,
  })  : _authRepository = authRepository,
        _errorHandler = errorHandler;

  @override
  void onInit() {
    super.onInit();
    _setupValidationListeners();
  }

  void _setupValidationListeners() {
    emailController.addListener(() {
      _validateEmail(emailController.text);
    });

    passwordController.addListener(() {
      _validatePassword(passwordController.text);
    });

    displayNameController.addListener(() {
      _validateDisplayName(displayNameController.text);
    });
  }

  void _validateEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    _isEmailValid.value = emailRegex.hasMatch(email);
  }

  void _validatePassword(String password) {
    _isPasswordValid.value = password.length >= 8 &&
        password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[a-z]')) &&
        password.contains(RegExp(r'[0-9]'));
  }

  void _validateDisplayName(String displayName) {
    _isDisplayNameValid.value = displayName.length >= 3 &&
        displayName.length <= 50 &&
        RegExp(r'^[a-zA-ZğüşıöçĞÜŞİÖÇ\s]+$').hasMatch(displayName);
  }

  Future<void> proceedToNextStep() async {
    if (!canProceedToNextStep) return;

    switch (_currentStep.value) {
      case RegistrationStep.basicInfo:
        if (await _registerBasicInfo()) {
          _currentStep.value = RegistrationStep.personalInfo;
        }
        break;
      case RegistrationStep.personalInfo:
        if (await _updatePersonalInfo()) {
          _currentStep.value = RegistrationStep.professionalInfo;
        }
        break;
      case RegistrationStep.professionalInfo:
        if (await _updateProfessionalInfo()) {
          _currentStep.value = RegistrationStep.skillsInfo;
        }
        break;
      case RegistrationStep.skillsInfo:
        if (await _updateSkillsInfo()) {
          _currentStep.value = RegistrationStep.completed;
          Get.offAllNamed(
              '/home'); // Kayıt tamamlandığında ana sayfaya yönlendir
        }
        break;
      case RegistrationStep.completed:
        break;
    }
  }

  Future<bool> _registerBasicInfo() async {
    try {
      _isLoading.value = true;
      final userCredential =
          await _authRepository.createUserWithEmailAndPassword(
        emailController.text,
        passwordController.text,
        displayNameController.text,
      );

      if (userCredential.user != null) {
        return true;
      }
      return false;
    } catch (e) {
      _errorHandler.handleError(e);
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> _updatePersonalInfo() async {
    try {
      _isLoading.value = true;
      final user = _authRepository.currentUser;
      if (user == null) return false;

      await _authRepository.updateUserProfile({
        'bio': bioController.text,
        'location': locationController.text,
        'photoURL': photoUrlController.text,
      });

      return true;
    } catch (e) {
      _errorHandler.handleError(e);
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> _updateProfessionalInfo() async {
    try {
      _isLoading.value = true;
      final user = _authRepository.currentUser;
      if (user == null) return false;

      await _authRepository.updateUserProfile({
        'title': titleController.text,
        'company': companyController.text,
        'yearsOfExperience':
            int.tryParse(yearsOfExperienceController.text) ?? 0,
      });

      return true;
    } catch (e) {
      _errorHandler.handleError(e);
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> _updateSkillsInfo() async {
    try {
      _isLoading.value = true;
      final user = _authRepository.currentUser;
      if (user == null) return false;

      await _authRepository.updateUserProfile({
        'skills': selectedSkills,
        'languages': selectedLanguages,
        'frameworks': selectedFrameworks,
      });

      return true;
    } catch (e) {
      _errorHandler.handleError(e);
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  void goBack() {
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

  void skipCurrentStep() {
    switch (_currentStep.value) {
      case RegistrationStep.personalInfo:
        _currentStep.value = RegistrationStep.professionalInfo;
        break;
      case RegistrationStep.professionalInfo:
        _currentStep.value = RegistrationStep.skillsInfo;
        break;
      case RegistrationStep.skillsInfo:
        _currentStep.value = RegistrationStep.completed;
        Get.offAllNamed('/home');
        break;
      default:
        break;
    }
  }

  String? getCurrentUserId() {
    return _authRepository.currentUser?.uid;
  }

  @override
  void onClose() {
    // Basic Info Controllers
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    displayNameController.dispose();

    // Personal Info Controllers
    bioController.dispose();
    locationController.dispose();
    photoUrlController.dispose();

    // Professional Info Controllers
    titleController.dispose();
    companyController.dispose();
    yearsOfExperienceController.dispose();

    super.onClose();
  }
}
