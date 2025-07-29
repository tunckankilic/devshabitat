import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../controllers/email_auth_controller.dart';
import '../../controllers/responsive_controller.dart';
import '../../widgets/adaptive_touch_target.dart';

class EmailVerificationAdvancedView extends StatefulWidget {
  const EmailVerificationAdvancedView({super.key});

  @override
  State<EmailVerificationAdvancedView> createState() =>
      _EmailVerificationAdvancedViewState();
}

class _EmailVerificationAdvancedViewState
    extends State<EmailVerificationAdvancedView> with TickerProviderStateMixin {
  final EmailAuthController _emailAuthController =
      Get.find<EmailAuthController>();
  final ResponsiveController _responsiveController =
      Get.find<ResponsiveController>();

  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  Timer? _verificationTimer;
  bool _isChecking = false;
  bool _isResending = false;
  bool _showMultiEmailSupport = false;

  // Multi-email support
  final List<String> _additionalEmails = <String>[].obs;
  final TextEditingController _newEmailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startEmailVerificationCheck();
    _loadUserEmails();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    _pulseController.repeat(reverse: true);
    _fadeController.forward();
  }

  void _startEmailVerificationCheck() {
    _verificationTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _checkEmailVerification(timer);
    });
  }

  Future<void> _loadUserEmails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Kullanıcının ek email'lerini yükle
      final emails = await _emailAuthController.getAdditionalEmails();
      _additionalEmails.assignAll(emails);
    }
  }

  Future<void> _checkEmailVerification(Timer timer) async {
    if (_isChecking) return;

    setState(() => _isChecking = true);

    try {
      await FirebaseAuth.instance.currentUser?.reload();
      final user = FirebaseAuth.instance.currentUser;

      if (user?.emailVerified == true) {
        timer.cancel();
        _showVerificationSuccess();
        Get.offAllNamed('/home');
      }
    } catch (e) {
      _showError('Email doğrulama kontrolü sırasında hata oluştu: $e');
    } finally {
      setState(() => _isChecking = false);
    }
  }

  Future<void> _resendEmail() async {
    setState(() => _isResending = true);

    try {
      await _emailAuthController.resendEmailVerification();
      _showSuccess('Doğrulama emaili tekrar gönderildi');
    } catch (e) {
      _showError('Email gönderilemedi: $e');
    } finally {
      setState(() => _isResending = false);
    }
  }

  Future<void> _addAdditionalEmail() async {
    if (_newEmailController.text.isEmpty) {
      _showError('Lütfen email adresini girin');
      return;
    }

    if (_additionalEmails.contains(_newEmailController.text)) {
      _showError('Bu email adresi zaten eklenmiş');
      return;
    }

    _additionalEmails.add(_newEmailController.text);
    _newEmailController.clear();
    _showSuccess('Ek email adresi eklendi');
  }

  void _removeAdditionalEmail(String email) {
    _additionalEmails.remove(email);
    _showSuccess('Email adresi kaldırıldı');
  }

  void _showVerificationSuccess() {
    Get.snackbar(
      'Başarılı!',
      'Email adresiniz doğrulandı. Hoş geldiniz!',
      backgroundColor: Colors.green.withOpacity(0.8),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  void _showSuccess(String message) {
    Get.snackbar(
      'Başarılı',
      message,
      backgroundColor: Colors.green.withOpacity(0.8),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  void _showError(String message) {
    Get.snackbar(
      'Hata',
      message,
      backgroundColor: Colors.red.withOpacity(0.8),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.error, color: Colors.white),
    );
  }

  void _showEmailChangeDialog() {
    final TextEditingController newEmailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Email Adresi Değiştir'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: newEmailController,
              decoration: const InputDecoration(
                labelText: 'Yeni Email Adresi',
                hintText: 'ornek@email.com',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Mevcut Şifre',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 8),
            Text(
              'Email adresinizi değiştirmek için mevcut şifrenizi girmeniz gerekiyor.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (newEmailController.text.isEmpty ||
                  passwordController.text.isEmpty) {
                _showError('Lütfen tüm alanları doldurun');
                return;
              }

              try {
                // Önce reauthenticate yap
                await _emailAuthController.reauthenticate(
                  FirebaseAuth.instance.currentUser?.email ?? '',
                  passwordController.text,
                );

                // Sonra email'i güncelle
                await _emailAuthController.updateEmail(newEmailController.text);

                Get.back();
                _showSuccess('Email adresi başarıyla güncellendi');
              } catch (e) {
                _showError('Email güncellenemedi: $e');
              }
            },
            child: const Text('Güncelle'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Email Doğrulama Yardımı'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• Email kutunuzu kontrol edin'),
            Text('• Spam klasörünü kontrol edin'),
            Text('• Email gelmezse "Tekrar Gönder" butonuna tıklayın'),
            Text(
                '• Email adresinizi değiştirmek istiyorsanız "Email Değiştir" butonunu kullanın'),
            Text('• Birden fazla email adresi ekleyebilirsiniz'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _verificationTimer?.cancel();
    _pulseController.dispose();
    _fadeController.dispose();
    _newEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Gelişmiş Email Doğrulama',
          style: TextStyle(
            fontSize: _responsiveController.responsiveValue(
              mobile: 18.0,
              tablet: 22.0,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelpDialog(),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: _responsiveController.responsivePadding(all: 24.0),
          child: Column(
            children: [
              _buildEmailIcon(),
              SizedBox(
                  height: _responsiveController.responsiveValue(
                      mobile: 32.0, tablet: 40.0)),
              _buildTitle(),
              SizedBox(
                  height: _responsiveController.responsiveValue(
                      mobile: 16.0, tablet: 20.0)),
              _buildDescription(user),
              SizedBox(
                  height: _responsiveController.responsiveValue(
                      mobile: 32.0, tablet: 40.0)),
              _buildCurrentEmailSection(user),
              SizedBox(
                  height: _responsiveController.responsiveValue(
                      mobile: 24.0, tablet: 32.0)),
              _buildActionButtons(),
              SizedBox(
                  height: _responsiveController.responsiveValue(
                      mobile: 24.0, tablet: 32.0)),
              _buildMultiEmailSection(),
              SizedBox(
                  height: _responsiveController.responsiveValue(
                      mobile: 24.0, tablet: 32.0)),
              _buildLoadingIndicator(),
              SizedBox(
                  height: _responsiveController.responsiveValue(
                      mobile: 16.0, tablet: 20.0)),
              _buildSkipButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailIcon() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: _responsiveController.responsiveValue(
                mobile: 120.0, tablet: 160.0),
            height: _responsiveController.responsiveValue(
                mobile: 120.0, tablet: 160.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[100]!, Colors.blue[200]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              Icons.email_outlined,
              size: _responsiveController.responsiveValue(
                  mobile: 60.0, tablet: 80.0),
              color: Colors.blue[600],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitle() {
    return Text(
      'Email Adresinizi Doğrulayın',
      style: TextStyle(
        fontSize:
            _responsiveController.responsiveValue(mobile: 24.0, tablet: 28.0),
        fontWeight: FontWeight.bold,
        color: Colors.grey[800],
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDescription(User? user) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Text(
            'Doğrulama emaili ${user?.email} adresine gönderildi.',
            style: TextStyle(
              fontSize: _responsiveController.responsiveValue(
                  mobile: 16.0, tablet: 18.0),
              color: Colors.grey[700],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8.0),
          Text(
            'Lütfen email kutunuzu kontrol edin ve doğrulama linkine tıklayın.',
            style: TextStyle(
              fontSize: _responsiveController.responsiveValue(
                  mobile: 14.0, tablet: 16.0),
              color: Colors.grey[600],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentEmailSection(User? user) {
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
              Icon(Icons.email, color: Colors.blue[600], size: 20),
              const SizedBox(width: 8),
              Text(
                'Mevcut Email',
                style: TextStyle(
                  fontSize: _responsiveController.responsiveValue(
                      mobile: 16.0, tablet: 18.0),
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            user?.email ?? 'Email bulunamadı',
            style: TextStyle(
              fontSize: _responsiveController.responsiveValue(
                  mobile: 14.0, tablet: 16.0),
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AdaptiveTouchTarget(
                  child: OutlinedButton.icon(
                    onPressed: _showEmailChangeDialog,
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Email Değiştir'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: AdaptiveTouchTarget(
            child: ElevatedButton.icon(
              onPressed: _isResending ? null : _resendEmail,
              icon: _isResending
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.refresh),
              label: Text(
                _isResending ? 'Gönderiliyor...' : 'Emaili Tekrar Gönder',
                style: TextStyle(
                  fontSize: _responsiveController.responsiveValue(
                      mobile: 16.0, tablet: 18.0),
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding: _responsiveController.responsivePadding(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: AdaptiveTouchTarget(
            child: OutlinedButton.icon(
              onPressed: () => setState(
                  () => _showMultiEmailSupport = !_showMultiEmailSupport),
              icon: Icon(_showMultiEmailSupport
                  ? Icons.expand_less
                  : Icons.expand_more),
              label: Text(_showMultiEmailSupport
                  ? 'Çoklu Email Gizle'
                  : 'Çoklu Email Ekle'),
              style: OutlinedButton.styleFrom(
                padding: _responsiveController.responsivePadding(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMultiEmailSection() {
    if (!_showMultiEmailSupport) return const SizedBox.shrink();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
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
                  fontSize: _responsiveController.responsiveValue(
                      mobile: 16.0, tablet: 18.0),
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
                  controller: _newEmailController,
                  decoration: InputDecoration(
                    hintText: 'Yeni email adresi ekle',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              AdaptiveTouchTarget(
                child: IconButton(
                  onPressed: _addAdditionalEmail,
                  icon: const Icon(Icons.add),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.blue[100],
                    foregroundColor: Colors.blue[600],
                  ),
                ),
              ),
            ],
          ),
          if (_additionalEmails.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...(_additionalEmails.map((email) => _buildEmailChip(email))),
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
        onDeleted: () => _removeAdditionalEmail(email),
        backgroundColor: Colors.blue[50],
        side: BorderSide(color: Colors.blue[200]!),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    if (!_isChecking) return const SizedBox.shrink();

    return Column(
      children: [
        CircularProgressIndicator(),
        const SizedBox(height: 16),
        Text(
          'Email doğrulaması kontrol ediliyor...',
          style: TextStyle(
            fontSize: _responsiveController.responsiveValue(
                mobile: 14.0, tablet: 16.0),
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSkipButton() {
    return TextButton(
      onPressed: () {
        Get.offAllNamed('/home');
      },
      child: Text(
        'Şimdilik Geç (Geliştirme)',
        style: TextStyle(
          fontSize:
              _responsiveController.responsiveValue(mobile: 14.0, tablet: 16.0),
          color: Colors.grey[500],
        ),
      ),
    );
  }
}
