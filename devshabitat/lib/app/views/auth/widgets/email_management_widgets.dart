import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/email_auth_controller.dart';
import '../../../controllers/responsive_controller.dart';
import '../../../widgets/adaptive_touch_target.dart';

class EmailChangeDialog extends StatelessWidget {
  final String currentEmail;
  final VoidCallback? onEmailChanged;

  const EmailChangeDialog({
    super.key,
    required this.currentEmail,
    this.onEmailChanged,
  });

  @override
  Widget build(BuildContext context) {
    final EmailAuthController emailAuthController =
        Get.find<EmailAuthController>();
    final ResponsiveController responsiveController =
        Get.find<ResponsiveController>();

    final TextEditingController newEmailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    return AlertDialog(
      title: Text(
        'Email Adresi Değiştir',
        style: TextStyle(
          fontSize: responsiveController.responsiveValue(
            mobile: 18.0,
            tablet: 20.0,
          ),
        ),
      ),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mevcut Email: $currentEmail',
              style: TextStyle(
                fontSize: responsiveController.responsiveValue(
                  mobile: 14.0,
                  tablet: 16.0,
                ),
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: newEmailController,
              decoration: const InputDecoration(
                labelText: 'Yeni Email Adresi',
                hintText: 'yeni@email.com',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email_outlined),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lütfen yeni email adresini girin';
                }
                if (!GetUtils.isEmail(value)) {
                  return 'Geçerli bir email adresi girin';
                }
                if (value == currentEmail) {
                  return 'Yeni email adresi mevcut email ile aynı olamaz';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Mevcut Şifre',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock_outline),
              ),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lütfen mevcut şifrenizi girin';
                }
                if (value.length < 6) {
                  return 'Şifre en az 6 karakter olmalıdır';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            Text(
              'Email adresinizi değiştirmek için mevcut şifrenizi girmeniz gerekiyor.',
              style: TextStyle(
                fontSize: responsiveController.responsiveValue(
                  mobile: 12.0,
                  tablet: 14.0,
                ),
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('İptal'),
        ),
        Obx(() => ElevatedButton(
              onPressed: emailAuthController.isLoading
                  ? null
                  : () async {
                      if (formKey.currentState?.validate() ?? false) {
                        try {
                          // Önce reauthenticate yap
                          await emailAuthController.reauthenticate(
                            currentEmail,
                            passwordController.text,
                          );

                          // Sonra email'i güncelle
                          await emailAuthController
                              .updateEmail(newEmailController.text);

                          Get.back();
                          if (onEmailChanged != null) {
                            onEmailChanged!();
                          }
                        } catch (e) {
                          // Hata zaten controller'da handle ediliyor
                        }
                      }
                    },
              child: emailAuthController.isLoading
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Güncelle'),
            )),
      ],
    );
  }
}

class EmailResendWidget extends StatelessWidget {
  final String email;
  final VoidCallback? onResendSuccess;

  const EmailResendWidget({
    super.key,
    required this.email,
    this.onResendSuccess,
  });

  @override
  Widget build(BuildContext context) {
    final EmailAuthController emailAuthController =
        Get.find<EmailAuthController>();
    final ResponsiveController responsiveController =
        Get.find<ResponsiveController>();

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.email_outlined, color: Colors.blue[600], size: 20),
              const SizedBox(width: 8),
              Text(
                'Email Doğrulama',
                style: TextStyle(
                  fontSize: responsiveController.responsiveValue(
                    mobile: 16.0,
                    tablet: 18.0,
                  ),
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Doğrulama emaili $email adresine gönderildi.',
            style: TextStyle(
              fontSize: responsiveController.responsiveValue(
                mobile: 14.0,
                tablet: 16.0,
              ),
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: AdaptiveTouchTarget(
              child: Obx(() => ElevatedButton.icon(
                    onPressed: emailAuthController.isLoading
                        ? null
                        : () async {
                            try {
                              await emailAuthController
                                  .resendEmailVerification();
                              if (onResendSuccess != null) {
                                onResendSuccess!();
                              }
                            } catch (e) {
                              // Hata zaten controller'da handle ediliyor
                            }
                          },
                    icon: emailAuthController.isLoading
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.refresh),
                    label: Text(
                      emailAuthController.isLoading
                          ? 'Gönderiliyor...'
                          : 'Emaili Tekrar Gönder',
                      style: TextStyle(
                        fontSize: responsiveController.responsiveValue(
                          mobile: 14.0,
                          tablet: 16.0,
                        ),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  )),
            ),
          ),
        ],
      ),
    );
  }
}

class MultiEmailWidget extends StatelessWidget {
  final List<String> additionalEmails;
  final Function(String) onAddEmail;
  final Function(String) onRemoveEmail;

  const MultiEmailWidget({
    super.key,
    required this.additionalEmails,
    required this.onAddEmail,
    required this.onRemoveEmail,
  });

  @override
  Widget build(BuildContext context) {
    final ResponsiveController responsiveController =
        Get.find<ResponsiveController>();
    final TextEditingController newEmailController = TextEditingController();

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.email_outlined, color: Colors.grey[600], size: 20),
              const SizedBox(width: 8),
              Text(
                'Ek Email Adresleri',
                style: TextStyle(
                  fontSize: responsiveController.responsiveValue(
                    mobile: 16.0,
                    tablet: 18.0,
                  ),
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: newEmailController,
                  decoration: InputDecoration(
                    hintText: 'Yeni email adresi ekle',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
              const SizedBox(width: 8),
              AdaptiveTouchTarget(
                child: IconButton(
                  onPressed: () {
                    final email = newEmailController.text.trim();
                    if (email.isNotEmpty && GetUtils.isEmail(email)) {
                      onAddEmail(email);
                      newEmailController.clear();
                    }
                  },
                  icon: const Icon(Icons.add),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.blue[100],
                    foregroundColor: Colors.blue[600],
                  ),
                ),
              ),
            ],
          ),
          if (additionalEmails.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...(additionalEmails.map((email) => _buildEmailChip(email))),
          ],
        ],
      ),
    );
  }

  Widget _buildEmailChip(String email) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Chip(
        label: Text(email),
        deleteIcon: const Icon(Icons.close, size: 18),
        onDeleted: () => onRemoveEmail(email),
        backgroundColor: Colors.blue[50],
        side: BorderSide(color: Colors.blue[200]!),
      ),
    );
  }
}
