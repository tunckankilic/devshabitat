import 'package:flutter/material.dart' hide FormFieldState;
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../core/services/form_validation_service.dart';

class EnhancedFormField extends StatefulWidget {
  final String fieldId;
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int? maxLines;
  final int? minLines;
  final Function(String)? onChanged;
  final bool enabled;
  final InputDecoration? decoration;
  final TextStyle? style;
  final FocusNode? focusNode;
  final bool autofocus;
  final TextInputAction? textInputAction;
  final Function(String)? onSubmitted;
  final Function()? onTap;
  final bool readOnly;
  final bool showCursor;
  final bool autocorrect;
  final bool enableSuggestions;
  final bool enableInteractiveSelection;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final EdgeInsets? contentPadding;
  final Color? cursorColor;
  final double? cursorWidth;
  final Radius? cursorRadius;
  final bool? cursorOpacityAnimates;
  final Brightness? keyboardAppearance;
  final ScrollController? scrollController;
  final ScrollPhysics? scrollPhysics;
  final Iterable<String>? autofillHints;
  final String? Function(String?)? validator;
  final String? semanticLabel;
  final String? semanticHint;

  const EnhancedFormField({
    super.key,
    required this.fieldId,
    this.controller,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.maxLines = 1,
    this.minLines,
    this.onChanged,
    this.enabled = true,
    this.decoration,
    this.style,
    this.focusNode,
    this.autofocus = false,
    this.textInputAction,
    this.onSubmitted,
    this.onTap,
    this.readOnly = false,
    this.showCursor = true,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.enableInteractiveSelection = true,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.contentPadding,
    this.cursorColor,
    this.cursorWidth,
    this.cursorRadius,
    this.cursorOpacityAnimates,
    this.keyboardAppearance,
    this.scrollController,
    this.scrollPhysics,
    this.autofillHints,
    this.validator,
    this.semanticLabel,
    this.semanticHint,
  
  });

  @override
  State<EnhancedFormField> createState() => _EnhancedFormFieldState();
}

class _EnhancedFormFieldState extends State<EnhancedFormField> {
  final _formValidation = Get.find<FormValidationService>();
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus != _isFocused) {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });

      // Alan odağını kaybettiğinde touched olarak işaretle
      if (!_isFocused) {
        _formValidation.markFieldAsTouched(widget.fieldId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final fieldState = _formValidation.getFieldState(widget.fieldId);
      final fieldError = _formValidation.getFieldError(widget.fieldId);

      // Loading durumunda suffix icon'u göster
      Widget? suffixIconWidget = widget.suffixIcon;
      if (fieldState == FormFieldState.loading) {
        suffixIconWidget = const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      }

      // Hata durumunda error icon'u göster
      if (fieldState == FormFieldState.invalid && !_isFocused) {
        suffixIconWidget = const Icon(Icons.error_outline, color: Colors.red);
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            maxLines: widget.maxLines,
            minLines: widget.minLines,
            enabled: widget.enabled,
            style: widget.style?.copyWith(
              fontSize: widget.style?.fontSize != null
                  ? widget.style!.fontSize! *
                        MediaQuery.of(context).textScaleFactor
                  : 16.0 * MediaQuery.of(context).textScaleFactor,
            ),
            autofocus: widget.autofocus,
            textInputAction: widget.textInputAction,
            onFieldSubmitted: widget.onSubmitted,
            onTap: widget.onTap,
            readOnly: widget.readOnly,
            showCursor: widget.showCursor,
            autocorrect: widget.autocorrect,
            enableSuggestions: widget.enableSuggestions,
            enableInteractiveSelection: widget.enableInteractiveSelection,
            inputFormatters: widget.inputFormatters,
            textCapitalization: widget.textCapitalization,
            cursorColor: widget.cursorColor,
            cursorWidth: widget.cursorWidth ?? 2.0,
            cursorRadius: widget.cursorRadius,
            cursorOpacityAnimates: widget.cursorOpacityAnimates,
            keyboardAppearance: widget.keyboardAppearance,
            scrollController: widget.scrollController,
            scrollPhysics: widget.scrollPhysics,
            autofillHints: widget.autofillHints,
            validator: widget.validator,
            onChanged: (value) {
              if (widget.onChanged != null) {
                widget.onChanged!(value);
              }
            },
            decoration:
                (widget.decoration ??
                        InputDecoration(
                          labelText: widget.labelText,
                          hintText: widget.hintText,
                          prefixIcon: widget.prefixIcon,
                          contentPadding: widget.contentPadding,
                        ))
                    .copyWith(
                      suffixIcon: suffixIconWidget,
                      errorText:
                          !_isFocused && fieldState == FormFieldState.invalid
                          ? fieldError
                          : null,
                      errorStyle: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
          ),
          if (_isFocused && fieldError != null && fieldError.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 12.0),
              child: Text(
                fieldError,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      );
    });
  }
}
