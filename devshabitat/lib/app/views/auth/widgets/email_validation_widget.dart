import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/email_auth_controller.dart';
import '../../../controllers/responsive_controller.dart';

class EmailValidationWidget extends StatelessWidget {
  final TextEditingController emailController;
  final String? labelText;
  final String? hintText;
  final bool showValidationStatus;
  final VoidCallback? onEmailValidated;

  const EmailValidationWidget({
    super.key,
    required this.emailController,
    this.labelText,
    this.hintText,
    this.showValidationStatus = true,
    this.onEmailValidated,
  });

  @override
  Widget build(BuildContext context) {
    final EmailAuthController emailAuthController =
        Get.find<EmailAuthController>();
    final ResponsiveController responsiveController =
        Get.find<ResponsiveController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: emailController,
          decoration: InputDecoration(
            labelText: labelText ?? 'Email Adresi',
            hintText: hintText ?? 'ornek@email.com',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            prefixIcon: const Icon(Icons.email_outlined),
            suffixIcon: Obx(() {
              if (emailController.text.isEmpty) {
                return const SizedBox.shrink();
              }

              if (emailAuthController.isEmailValid) {
                return Icon(
                  Icons.check_circle,
                  color: Colors.green[600],
                  size: 20,
                );
              } else {
                return Icon(
                  Icons.error,
                  color: Colors.red[600],
                  size: 20,
                );
              }
            }),
          ),
          keyboardType: TextInputType.emailAddress,
          onChanged: (value) {
            emailAuthController.validateEmailOnChange(value);
            if (onEmailValidated != null && emailAuthController.isEmailValid) {
              onEmailValidated!();
            }
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Lütfen email adresinizi girin';
            }
            if (!emailAuthController.isEmailValid) {
              return 'Geçerli bir email adresi girin';
            }
            return null;
          },
        ),
        if (showValidationStatus) ...[
          const SizedBox(height: 8),
          Obx(() {
            if (emailController.text.isEmpty) {
              return const SizedBox.shrink();
            }

            if (emailAuthController.isEmailValid) {
              return Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green[600],
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Geçerli email formatı',
                    style: TextStyle(
                      color: Colors.green[600],
                      fontSize: responsiveController.responsiveValue(
                        mobile: 12.0,
                        tablet: 14.0,
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return Row(
                children: [
                  Icon(
                    Icons.error,
                    color: Colors.red[600],
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Geçersiz email formatı',
                    style: TextStyle(
                      color: Colors.red[600],
                      fontSize: responsiveController.responsiveValue(
                        mobile: 12.0,
                        tablet: 14.0,
                      ),
                    ),
                  ),
                ],
              );
            }
          }),
        ],
      ],
    );
  }
}

class EmailAvailabilityWidget extends StatelessWidget {
  final String email;
  final VoidCallback? onEmailAvailable;

  const EmailAvailabilityWidget({
    super.key,
    required this.email,
    this.onEmailAvailable,
  });

  @override
  Widget build(BuildContext context) {
    final EmailAuthController emailAuthController =
        Get.find<EmailAuthController>();
    final ResponsiveController responsiveController =
        Get.find<ResponsiveController>();

    return Obx(() {
      if (email.isEmpty || !emailAuthController.isEmailValid) {
        return const SizedBox.shrink();
      }

      switch (emailAuthController.emailVerificationStatus) {
        case 'checking':
          return Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.blue[600],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Email kontrol ediliyor...',
                style: TextStyle(
                  color: Colors.blue[600],
                  fontSize: responsiveController.responsiveValue(
                    mobile: 12.0,
                    tablet: 14.0,
                  ),
                ),
              ),
            ],
          );

        case 'available':
          return Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green[600],
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Email kullanılabilir',
                style: TextStyle(
                  color: Colors.green[600],
                  fontSize: responsiveController.responsiveValue(
                    mobile: 12.0,
                    tablet: 14.0,
                  ),
                ),
              ),
            ],
          );

        case 'taken':
          return Row(
            children: [
              Icon(
                Icons.error,
                color: Colors.red[600],
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Bu email zaten kullanılıyor',
                style: TextStyle(
                  color: Colors.red[600],
                  fontSize: responsiveController.responsiveValue(
                    mobile: 12.0,
                    tablet: 14.0,
                  ),
                ),
              ),
            ],
          );

        case 'error':
          return Row(
            children: [
              Icon(
                Icons.warning,
                color: Colors.orange[600],
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Email kontrol edilemedi',
                style: TextStyle(
                  color: Colors.orange[600],
                  fontSize: responsiveController.responsiveValue(
                    mobile: 12.0,
                    tablet: 14.0,
                  ),
                ),
              ),
            ],
          );

        default:
          return const SizedBox.shrink();
      }
    });
  }
}
