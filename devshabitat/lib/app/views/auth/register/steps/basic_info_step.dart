import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:flutter/material.dart' hide FormFieldState;
import 'package:get/get.dart';
import '../../../../controllers/registration_controller.dart';
import '../../../../controllers/responsive_controller.dart';
import '../../../../core/services/form_validation_service.dart';
import '../../../../widgets/common/enhanced_form_field.dart';
import '../../../../widgets/common/password_requirements_widget.dart';

class BasicInfoStep extends GetView<RegistrationController> {
  final _responsiveController = Get.find<ResponsiveController>();
  final _formValidation = Get.find<FormValidationService>();

  BasicInfoStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.basicInfoFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Email field with EnhancedFormField
          EnhancedFormField(
            fieldId: 'email',
            controller: controller.emailController,
            labelText: AppStrings.email,
            hintText: AppStrings.emailHint,
            semanticLabel: 'E-posta adresi giriş alanı',
            semanticHint: 'Lütfen geçerli bir e-posta adresi girin',
            prefixIcon: Icon(
              Icons.email,
              size: _responsiveController.responsiveValue(
                mobile: 24.0,
                tablet: 32.0,
              ),
              semanticLabel: 'E-posta simgesi',
            ),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            onChanged: (value) => controller.validateEmail(),
            decoration: InputDecoration(
              contentPadding: _responsiveController.responsivePadding(
                horizontal: 16.0,
                vertical: 16.0,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  _responsiveController.responsiveValue(
                    mobile: 8.0,
                    tablet: 12.0,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(
            height: _responsiveController.responsiveValue(
              mobile: 16.0,
              tablet: 24.0,
            ),
          ),

          // Display Name field with EnhancedFormField
          EnhancedFormField(
            fieldId: 'displayName',
            controller: controller.displayNameController,
            labelText: AppStrings.displayName,
            hintText: AppStrings.displayNameHint,
            semanticLabel: 'Görünen ad giriş alanı',
            semanticHint: 'Diğer kullanıcılara görünecek adınızı girin',
            prefixIcon: Icon(
              Icons.person,
              size: _responsiveController.responsiveValue(
                mobile: 24.0,
                tablet: 32.0,
              ),
              semanticLabel: 'Kullanıcı simgesi',
            ),
            textInputAction: TextInputAction.next,
            onChanged: (value) => controller.validateDisplayName(),
            decoration: InputDecoration(
              contentPadding: _responsiveController.responsivePadding(
                horizontal: 16.0,
                vertical: 16.0,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  _responsiveController.responsiveValue(
                    mobile: 8.0,
                    tablet: 12.0,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(
            height: _responsiveController.responsiveValue(
              mobile: 16.0,
              tablet: 24.0,
            ),
          ),

          // Password field with EnhancedFormField
          EnhancedFormField(
            fieldId: 'password',
            controller: controller.passwordController,
            labelText: AppStrings.password,
            hintText:
                "En az 8 karakter, büyük/küçük harf, sayı ve özel karakter",
            semanticLabel: 'Şifre giriş alanı',
            semanticHint:
                'Güvenli bir şifre oluşturun. En az 8 karakter, büyük/küçük harf, sayı ve özel karakter içermelidir',
            prefixIcon: Icon(
              Icons.lock,
              size: _responsiveController.responsiveValue(
                mobile: 24.0,
                tablet: 32.0,
              ),
              semanticLabel: 'Şifre simgesi',
            ),
            obscureText: true,
            textInputAction: TextInputAction.next,
            onChanged: (value) => controller.validatePassword(),
            decoration: InputDecoration(
              contentPadding: _responsiveController.responsivePadding(
                horizontal: 16.0,
                vertical: 16.0,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  _responsiveController.responsiveValue(
                    mobile: 8.0,
                    tablet: 12.0,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(
            height: _responsiveController.responsiveValue(
              mobile: 12.0,
              tablet: 16.0,
            ),
          ),

          // Password Requirements Checklist
          Obx(() => _buildPasswordChecklist()),

          SizedBox(
            height: _responsiveController.responsiveValue(
              mobile: 16.0,
              tablet: 24.0,
            ),
          ),

          // Confirm Password field with EnhancedFormField
          EnhancedFormField(
            fieldId: 'confirmPassword',
            controller: controller.confirmPasswordController,
            labelText: AppStrings.confirmPassword,
            hintText: "Şifrenizi tekrar girin",
            semanticLabel: 'Şifre doğrulama giriş alanı',
            semanticHint: 'Güvenlik için şifrenizi tekrar girin',
            prefixIcon: Icon(
              Icons.lock_outline,
              size: _responsiveController.responsiveValue(
                mobile: 24.0,
                tablet: 32.0,
              ),
              semanticLabel: 'Şifre doğrulama simgesi',
            ),
            obscureText: true,
            textInputAction: TextInputAction.done,
            onChanged: (value) => controller.validatePasswordConfirmation(),
            decoration: InputDecoration(
              contentPadding: _responsiveController.responsivePadding(
                horizontal: 16.0,
                vertical: 16.0,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  _responsiveController.responsiveValue(
                    mobile: 8.0,
                    tablet: 12.0,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(
            height: _responsiveController.responsiveValue(
              mobile: 16.0,
              tablet: 24.0,
            ),
          ),

          // Password Match Status
          Obx(
            () => !controller.confirmPasswordIsEmpty
                ? _buildPasswordMatchStatus()
                : SizedBox.shrink(),
          ),

          SizedBox(
            height: _responsiveController.responsiveValue(
              mobile: 24.0,
              tablet: 32.0,
            ),
          ),

          // GitHub Veri İçe Aktarma Bölümü (İsteğe Bağlı)
          Semantics(
            label: 'GitHub veri içe aktarma bölümü',
            hint:
                'GitHub hesabınızdan bilgileri otomatik olarak doldurabilirsiniz',
            child: _buildGithubImportSection(context),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordChecklist() {
    return Obx(() {
      final focusedField = _formValidation.getFieldState('password');
      final isVisible =
          focusedField == FormFieldState.touched || !controller.passwordIsEmpty;

      return PasswordRequirementsWidget(
        hasMinLength: controller.hasMinLength,
        hasUppercase: controller.hasUppercase,
        hasLowercase: controller.hasLowercase,
        hasNumber: controller.hasNumber,
        hasSpecialChar: controller.hasSpecialChar,
        passwordsMatch: controller.passwordsMatch,
        isVisible: isVisible,
      );
    });
  }

  Widget _buildPasswordMatchStatus() {
    return Obx(() {
      final focusedField = _formValidation.getFieldState('confirmPassword');
      final error = _formValidation.getFieldError('confirmPassword');
      final isVisible =
          focusedField == FormFieldState.touched ||
          !controller.confirmPasswordIsEmpty;

      if (!isVisible) return const SizedBox.shrink();

      return Container(
        padding: _responsiveController.responsivePadding(
          horizontal: 16.0,
          vertical: 12.0,
        ),
        decoration: BoxDecoration(
          color: error == null ? Colors.green[50] : Colors.red[50],
          borderRadius: BorderRadius.circular(
            _responsiveController.responsiveValue(mobile: 8.0, tablet: 12.0),
          ),
          border: Border.all(
            color: error == null ? Colors.green[300]! : Colors.red[300]!,
          ),
        ),
        child: Row(
          children: [
            Icon(
              error == null ? Icons.check_circle : Icons.error,
              size: _responsiveController.responsiveValue(
                mobile: 16.0,
                tablet: 20.0,
              ),
              color: error == null ? Colors.green[700] : Colors.red[700],
            ),
            SizedBox(
              width: _responsiveController.responsiveValue(
                mobile: 8.0,
                tablet: 12.0,
              ),
            ),
            Expanded(
              child: Text(
                error ?? 'Şifreler eşleşiyor',
                style: TextStyle(
                  fontSize: _responsiveController.responsiveValue(
                    mobile: 12.0,
                    tablet: 14.0,
                  ),
                  color: error == null ? Colors.green[700] : Colors.red[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildGithubImportSection(BuildContext context) {
    return Container(
      padding: _responsiveController.responsivePadding(all: 16.0),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: controller.isGithubConnected
              ? Colors.green[300]!
              : Colors.blue[300]!,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                controller.isGithubConnected
                    ? Icons.check_circle
                    : Icons.download,
                size: 24.0,
                color: controller.isGithubConnected
                    ? Colors.green[700]
                    : Colors.blue[700],
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GitHub Verilerini İçe Aktar',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                        color: controller.isGithubConnected
                            ? Colors.green[800]
                            : Colors.blue[800],
                      ),
                    ),
                    Text(
                      controller.isGithubConnected
                          ? 'GitHub verileriniz form alanlarına aktarıldı'
                          : 'GitHub profilinizden bilgileri otomatik doldur (İsteğe bağlı)',
                      style: TextStyle(
                        fontSize: 12.0,
                        color: controller.isGithubConnected
                            ? Colors.green[600]
                            : Colors.blue[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          Text(
            controller.isGithubConnected
                ? 'GitHub profilinizden name, email, bio, location ve company bilgileri aktarıldı.'
                : 'GitHub profilinizden email, isim, bio ve diğer bilgileri otomatik olarak form alanlarına aktarabilirsiniz. Bu işlem isteğe bağlıdır.',
            style: TextStyle(
              fontSize: 13.0,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16.0),
          SizedBox(
            width: double.infinity,
            child: Semantics(
              button: true,
              enabled: !controller.isGithubLoading,
              label: controller.isGithubConnected
                  ? 'GitHub verilerini temizle'
                  : 'GitHub\'dan verileri al',
              hint: controller.isGithubConnected
                  ? 'Form alanlarından GitHub verilerini kaldır'
                  : 'GitHub profilinden bilgileri otomatik doldur',
              child: ElevatedButton.icon(
                onPressed: controller.isGithubConnected
                    ? () {
                        // GitHub bağlantısını kaldır
                        controller.disconnectGithub();
                      }
                    : (controller.isGithubLoading
                          ? null
                          : () async {
                              await controller.importGithubData();
                            }),
                icon: controller.isGithubLoading
                    ? SizedBox(
                        width: 16.0,
                        height: 16.0,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                          semanticsLabel: 'Yükleniyor göstergesi',
                        ),
                      )
                    : Icon(
                        controller.isGithubConnected
                            ? Icons.clear
                            : Icons.download,
                        size: 20.0,
                        semanticLabel: controller.isGithubConnected
                            ? 'Temizle simgesi'
                            : 'İndir simgesi',
                      ),
                label: Text(
                  controller.isGithubLoading
                      ? 'GitHub verileriniz alınıyor...'
                      : (controller.isGithubConnected
                            ? 'GitHub Verilerini Temizle'
                            : 'GitHub\'dan Verileri Al'),
                  style: TextStyle(
                    fontSize: 16.0 * MediaQuery.of(context).textScaleFactor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: controller.isGithubConnected
                      ? Colors.grey[600]
                      : Colors.blue[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ValidationMessage extends StatelessWidget {
  final IconData icon;
  final String message;
  final Color color;
  final double iconSize;
  final double fontSize;

  const ValidationMessage({
    super.key,
    required this.icon,
    required this.message,
    required this.color,
    required this.iconSize,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final responsiveController = Get.find<ResponsiveController>();
    return Padding(
      padding: EdgeInsets.only(
        bottom: responsiveController.responsiveValue(mobile: 8, tablet: 12),
      ),
      child: Row(
        children: [
          Icon(icon, size: iconSize, color: color),
          SizedBox(
            width: responsiveController.responsiveValue(mobile: 8, tablet: 12),
          ),
          Text(
            message,
            style: TextStyle(color: color, fontSize: fontSize),
          ),
        ],
      ),
    );
  }
}
