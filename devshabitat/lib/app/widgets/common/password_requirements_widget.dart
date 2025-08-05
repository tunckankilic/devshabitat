import 'package:flutter/material.dart';

class PasswordRequirementsWidget extends StatelessWidget {
  final bool hasMinLength;
  final bool hasUppercase;
  final bool hasLowercase;
  final bool hasNumber;
  final bool hasSpecialChar;
  final bool passwordsMatch;
  final bool isVisible;

  const PasswordRequirementsWidget({
    Key? key,
    required this.hasMinLength,
    required this.hasUppercase,
    required this.hasLowercase,
    required this.hasNumber,
    required this.hasSpecialChar,
    required this.passwordsMatch,
    required this.isVisible,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return Semantics(
      label: 'Şifre gereksinimleri kontrol listesi',
      hint: 'Şifrenizin güvenlik gereksinimlerini kontrol edin',
      child: AnimatedOpacity(
        opacity: isVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Şifre Gereksinimleri:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.0 * MediaQuery.of(context).textScaleFactor,
                  ),
                ),
                const SizedBox(height: 8),
                _buildRequirement('En az 8 karakter', hasMinLength, context),
                _buildRequirement(
                  'En az bir büyük harf',
                  hasUppercase,
                  context,
                ),
                _buildRequirement(
                  'En az bir küçük harf',
                  hasLowercase,
                  context,
                ),
                _buildRequirement('En az bir rakam', hasNumber, context),
                _buildRequirement(
                  'En az bir özel karakter',
                  hasSpecialChar,
                  context,
                ),
                _buildRequirement(
                  'Şifreler eşleşiyor',
                  passwordsMatch,
                  context,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequirement(String text, bool isMet, BuildContext context) {
    return Semantics(
      label: text,
      value: isMet ? 'Karşılandı' : 'Karşılanmadı',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Icon(
              isMet ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isMet ? Colors.green[700] : Colors.grey[600],
              size: 16,
              semanticLabel: isMet
                  ? 'Tamamlandı işareti'
                  : 'Tamamlanmadı işareti',
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: isMet ? Colors.green[700] : Colors.grey[600],
                fontSize: 12.0 * MediaQuery.of(context).textScaleFactor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
