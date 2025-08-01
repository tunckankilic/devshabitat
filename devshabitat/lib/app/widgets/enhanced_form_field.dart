import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/enhanced_form_validation_controller.dart';
import '../widgets/responsive/responsive_text.dart';

enum FieldType {
  email,
  password,
  username,
  phone,
  name,
  url,
  bio,
  title,
  company,
  githubUsername,
  custom,
}

class EnhancedFormField extends StatefulWidget {
  final FieldType fieldType;
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int? maxLines;
  final int? maxLength;
  final bool enabled;
  final bool required;
  final String? Function(String?)? customValidator;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSubmitted;
  final FocusNode? focusNode;
  final String? customFieldName;
  final List<ValidationRule>? customRules;
  final bool showSuccessIcon;
  final bool showErrorIcon;
  final EdgeInsetsGeometry? contentPadding;
  final InputBorder? border;
  final Color? successColor;
  final Color? errorColor;
  final double? iconSize;
  final bool enableRealTimeValidation;

  const EnhancedFormField({
    super.key,
    required this.fieldType,
    required this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.required = true,
    this.customValidator,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.customFieldName,
    this.customRules,
    this.showSuccessIcon = true,
    this.showErrorIcon = true,
    this.contentPadding,
    this.border,
    this.successColor,
    this.errorColor,
    this.iconSize,
    this.enableRealTimeValidation = true,
  });

  @override
  State<EnhancedFormField> createState() => _EnhancedFormFieldState();
}

class _EnhancedFormFieldState extends State<EnhancedFormField> {
  late EnhancedFormValidationController _validationController;
  late FocusNode _focusNode;
  final _isFocused = false.obs;
  final _hasInteracted = false.obs;
  final _hasValue = false.obs;

  @override
  void initState() {
    super.initState();
    _validationController = Get.find<EnhancedFormValidationController>();
    _focusNode = widget.focusNode ?? FocusNode();

    // Add custom rules if provided
    if (widget.customRules != null && widget.customFieldName != null) {
      for (final rule in widget.customRules!) {
        _validationController.addCustomRule(widget.customFieldName!, rule);
      }
    }

    // Setup focus listener for accessibility
    _focusNode.addListener(_onFocusChange);

    // Setup controller listener for real-time validation
    if (widget.enableRealTimeValidation) {
      widget.controller.addListener(_onTextChanged);
    }

    // Initial value check
    _hasValue.value = widget.controller.text.isNotEmpty;
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    if (widget.enableRealTimeValidation) {
      widget.controller.removeListener(_onTextChanged);
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    _isFocused.value = _focusNode.hasFocus;
    if (_isFocused.value) {
      _hasInteracted.value = true;
    }
  }

  void _onTextChanged() {
    if (!widget.enableRealTimeValidation) return;

    final text = widget.controller.text;
    _hasValue.value = text.isNotEmpty;
    _validateField(text);
  }

  void _validateField(String text) {
    switch (widget.fieldType) {
      case FieldType.email:
        _validationController.validateEmail(text);
        break;
      case FieldType.password:
        _validationController.validatePassword(text);
        break;
      case FieldType.username:
        _validationController.validateUsername(text);
        break;
      case FieldType.phone:
        _validationController.validatePhone(text);
        break;
      case FieldType.name:
        _validationController.validateName(text);
        break;
      case FieldType.url:
        _validationController.validateUrl(text);
        break;
      case FieldType.bio:
        _validationController.validateBio(text);
        break;
      case FieldType.title:
        _validationController.validateTitle(text);
        break;
      case FieldType.company:
        _validationController.validateCompany(text);
        break;
      case FieldType.githubUsername:
        _validationController.validateGithubUsername(text);
        break;
      case FieldType.custom:
        if (widget.customFieldName != null) {
          _validationController.validateWithCustomRules(
            widget.customFieldName!,
            text,
          );
          // Custom validation logic would be handled here
        }
        break;
    }
  }

  String? _getValidator(String? value) {
    // Custom validator takes precedence
    if (widget.customValidator != null) {
      return widget.customValidator!(value);
    }

    // Required field validation
    if (widget.required && (value == null || value.trim().isEmpty)) {
      return 'Bu alan zorunludur';
    }

    // If not required and empty, no validation needed
    if (!widget.required && (value == null || value.trim().isEmpty)) {
      return null;
    }

    // Field-specific validation
    switch (widget.fieldType) {
      case FieldType.email:
        if (!GetUtils.isEmail(value!)) {
          return 'Geçerli bir e-posta adresi giriniz';
        }
        break;
      case FieldType.password:
        if (value!.length < 8) {
          return 'Şifre en az 8 karakter olmalıdır';
        }
        break;
      case FieldType.username:
        if (value!.length < 3) {
          return 'Kullanıcı adı en az 3 karakter olmalıdır';
        }
        if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
          return 'Sadece harf, rakam ve alt çizgi kullanabilirsiniz';
        }
        break;
      case FieldType.phone:
        if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(value!)) {
          return 'Geçerli bir telefon numarası giriniz';
        }
        break;
      case FieldType.name:
        if (value!.length < 2) {
          return 'İsim en az 2 karakter olmalıdır';
        }
        if (!RegExp(r'^[a-zA-ZğüşıöçĞÜŞİÖÇ\s]+$').hasMatch(value)) {
          return 'Sadece harf kullanabilirsiniz';
        }
        break;
      case FieldType.url:
        if (!RegExp(
                r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
                caseSensitive: false)
            .hasMatch(value!)) {
          return 'Geçerli bir URL giriniz';
        }
        break;
      case FieldType.bio:
        if (value!.length > 500) {
          return 'Bio en fazla 500 karakter olabilir';
        }
        break;
      case FieldType.title:
        if (value!.length < 2) {
          return 'Ünvan en az 2 karakter olmalıdır';
        }
        if (value.length > 100) {
          return 'Ünvan en fazla 100 karakter olabilir';
        }
        break;
      case FieldType.company:
        if (value!.length > 100) {
          return 'Şirket adı en fazla 100 karakter olabilir';
        }
        break;
      case FieldType.githubUsername:
        if (value!.isEmpty) {
          return 'GitHub kullanıcı adı en az 1 karakter olmalıdır';
        }
        if (value.length > 39) {
          return 'GitHub kullanıcı adı en fazla 39 karakter olabilir';
        }
        if (!RegExp(r'^[a-zA-Z0-9-]+$').hasMatch(value)) {
          return 'Sadece harf, rakam ve tire kullanabilirsiniz';
        }
        break;
      case FieldType.custom:
        // Custom validation handled by customValidator
        break;
    }

    return null;
  }

  bool _isFieldValid() {
    switch (widget.fieldType) {
      case FieldType.email:
        return _validationController.isEmailValid;
      case FieldType.password:
        return _validationController.isPasswordValid;
      case FieldType.username:
        return _validationController.isUsernameValid;
      case FieldType.phone:
        return _validationController.isPhoneValid;
      case FieldType.name:
        return _validationController.isNameValid;
      case FieldType.url:
        return _validationController.isUrlValid;
      case FieldType.bio:
        return _validationController.isBioValid;
      case FieldType.title:
        return _validationController.isTitleValid;
      case FieldType.company:
        return _validationController.isCompanyValid;
      case FieldType.githubUsername:
        return _validationController.isGithubUsernameValid;
      case FieldType.custom:
        return true; // Custom validation handled separately
    }
  }

  bool _isFieldSuccess() {
    switch (widget.fieldType) {
      case FieldType.email:
        return _validationController.emailSuccess;
      case FieldType.password:
        return _validationController.passwordSuccess;
      case FieldType.username:
        return _validationController.usernameSuccess;
      case FieldType.phone:
        return _validationController.phoneSuccess;
      case FieldType.name:
        return _validationController.nameSuccess;
      case FieldType.url:
        return _validationController.urlSuccess;
      case FieldType.bio:
        return _validationController.bioSuccess;
      case FieldType.title:
        return _validationController.titleSuccess;
      case FieldType.company:
        return _validationController.companySuccess;
      case FieldType.githubUsername:
        return _validationController.githubUsernameSuccess;
      case FieldType.custom:
        return false; // Custom success handled separately
    }
  }

  String? _getFieldError() {
    switch (widget.fieldType) {
      case FieldType.email:
        return _validationController.emailError;
      case FieldType.password:
        return _validationController.passwordError;
      case FieldType.username:
        return _validationController.usernameError;
      case FieldType.phone:
        return _validationController.phoneError;
      case FieldType.name:
        return _validationController.nameError;
      case FieldType.url:
        return _validationController.urlError;
      case FieldType.bio:
        return _validationController.bioError;
      case FieldType.title:
        return _validationController.titleError;
      case FieldType.company:
        return _validationController.companyError;
      case FieldType.githubUsername:
        return _validationController.githubUsernameError;
      case FieldType.custom:
        return null; // Custom error handled separately
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSuccess = _isFieldSuccess();
      final error = _getFieldError();
      final hasError = error != null && _hasInteracted.value;
      final hasValue = _hasValue.value;
      final isValid = _isFieldValid();
      final isFocused = _isFocused.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType ?? _getKeyboardType(),
            maxLines: widget.maxLines,
            maxLength: widget.maxLength,
            enabled: widget.enabled,
            onTap: widget.onTap,
            onChanged: (value) {
              widget.onChanged?.call(value);
              if (widget.enableRealTimeValidation) {
                _validateField(value);
              }
            },
            onFieldSubmitted: (_) => widget.onSubmitted?.call(),
            validator: _getValidator,
            style: TextStyle(
              fontSize: 16,
              color: widget.enabled ? null : Colors.grey[600],
            ),
            decoration: InputDecoration(
              labelText: widget.required ? '${widget.label} *' : widget.label,
              hintText: widget.hint,
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                      widget.prefixIcon,
                      size: widget.iconSize ?? 24,
                      color: _getIconColor(hasError, isSuccess, hasValue),
                    )
                  : null,
              suffixIcon: _buildSuffixIcon(hasError, isSuccess, hasValue),
              contentPadding: widget.contentPadding ??
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: widget.border ??
                  OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _getBorderColor(
                          hasError, isSuccess, isFocused, isValid),
                    ),
                  ),
              enabledBorder: widget.border ??
                  OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _getBorderColor(
                          hasError, isSuccess, isFocused, isValid),
                    ),
                  ),
              focusedBorder: widget.border ??
                  OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color:
                          _getBorderColor(hasError, isSuccess, true, isValid),
                      width: 2,
                    ),
                  ),
              errorBorder: widget.border ??
                  OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: widget.errorColor ?? Colors.red,
                      width: 2,
                    ),
                  ),
              focusedErrorBorder: widget.border ??
                  OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: widget.errorColor ?? Colors.red,
                      width: 2,
                    ),
                  ),
              filled: true,
              fillColor: widget.enabled ? Colors.grey[50] : Colors.grey[100],
              errorStyle: TextStyle(
                color: widget.errorColor ?? Colors.red,
                fontSize: 12,
              ),
            ),
          ),
          if (hasError) ...[
            const SizedBox(height: 8),
            ResponsiveText(
              error,
              style: TextStyle(
                color: widget.errorColor ?? Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      );
    });
  }

  Widget? _buildSuffixIcon(bool hasError, bool isSuccess, bool hasValue) {
    if (hasError && widget.showErrorIcon) {
      return Icon(
        Icons.error_outline,
        color: widget.errorColor ?? Colors.red,
        size: widget.iconSize ?? 20,
      );
    }

    if (isSuccess && widget.showSuccessIcon && hasValue) {
      return Icon(
        Icons.check_circle_outline,
        color: widget.successColor ?? Colors.green,
        size: widget.iconSize ?? 20,
      );
    }

    if (widget.suffixIcon != null) {
      return Icon(
        widget.suffixIcon,
        size: widget.iconSize ?? 20,
        color: _getIconColor(hasError, isSuccess, hasValue),
      );
    }

    return null;
  }

  Color _getBorderColor(
      bool hasError, bool isSuccess, bool isFocused, bool isValid) {
    if (hasError) {
      return widget.errorColor ?? Colors.red;
    }
    if (isSuccess) {
      return widget.successColor ?? Colors.green;
    }
    if (isFocused) {
      return Theme.of(context).primaryColor;
    }
    if (isValid) {
      return Colors.blue;
    }
    return Colors.grey[400]!;
  }

  Color _getIconColor(bool hasError, bool isSuccess, bool hasValue) {
    if (hasError) {
      return widget.errorColor ?? Colors.red;
    }
    if (isSuccess && hasValue) {
      return widget.successColor ?? Colors.green;
    }
    return Colors.grey[600]!;
  }

  TextInputType _getKeyboardType() {
    switch (widget.fieldType) {
      case FieldType.email:
        return TextInputType.emailAddress;
      case FieldType.password:
        return TextInputType.visiblePassword;
      case FieldType.phone:
        return TextInputType.phone;
      case FieldType.url:
        return TextInputType.url;
      case FieldType.bio:
        return TextInputType.multiline;
      default:
        return TextInputType.text;
    }
  }
}
