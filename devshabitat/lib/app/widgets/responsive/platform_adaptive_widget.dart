import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;

class PlatformAdaptiveWidget extends StatelessWidget {
  final Widget Function(BuildContext) androidBuilder;
  final Widget Function(BuildContext) iosBuilder;
  final bool forceAndroid;
  final bool forceIOS;

  const PlatformAdaptiveWidget({
    super.key,
    required this.androidBuilder,
    required this.iosBuilder,
    this.forceAndroid = false,
    this.forceIOS = false,
  });

  @override
  Widget build(BuildContext context) {
    if (forceAndroid) return androidBuilder(context);
    if (forceIOS) return iosBuilder(context);
    return Platform.isIOS ? iosBuilder(context) : androidBuilder(context);
  }
}

// Platform özel buton
class PlatformButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool isDestructive;
  final bool isSecondary;

  const PlatformButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.isDestructive = false,
    this.isSecondary = false,
  });

  @override
  Widget build(BuildContext context) {
    return PlatformAdaptiveWidget(
      androidBuilder: (context) => ElevatedButton(
        onPressed: onPressed,
        style: _getAndroidButtonStyle(context),
        child: child,
      ),
      iosBuilder: (context) => CupertinoButton(
        onPressed: onPressed,
        color: _getIOSButtonColor(context),
        child: child,
      ),
    );
  }

  ButtonStyle _getAndroidButtonStyle(BuildContext context) {
    if (isDestructive) {
      return ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      );
    }
    if (isSecondary) {
      return ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[200],
        foregroundColor: Colors.black87,
      );
    }
    return ElevatedButton.styleFrom();
  }

  Color? _getIOSButtonColor(BuildContext context) {
    if (isDestructive) return CupertinoColors.destructiveRed;
    if (isSecondary) return CupertinoColors.systemGrey5;
    return null;
  }
}

// Platform özel input
class PlatformTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? placeholder;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;

  const PlatformTextField({
    super.key,
    this.controller,
    this.placeholder,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
    this.textInputAction,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return PlatformAdaptiveWidget(
      androidBuilder: (context) => TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: placeholder,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        obscureText: obscureText,
        keyboardType: keyboardType,
        onChanged: onChanged,
        textInputAction: textInputAction,
        focusNode: focusNode,
      ),
      iosBuilder: (context) => CupertinoTextField(
        controller: controller,
        placeholder: placeholder,
        obscureText: obscureText,
        keyboardType: keyboardType,
        onChanged: onChanged,
        textInputAction: textInputAction,
        focusNode: focusNode,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}

// Platform özel dialog
class PlatformAlertDialog extends StatelessWidget {
  final String title;
  final String message;
  final List<PlatformDialogAction> actions;

  const PlatformAlertDialog({
    super.key,
    required this.title,
    required this.message,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return PlatformAdaptiveWidget(
      androidBuilder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: actions.map((action) {
          return TextButton(
            onPressed: action.onPressed,
            style: _getAndroidActionStyle(action.isDestructive),
            child: Text(action.text),
          );
        }).toList(),
      ),
      iosBuilder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: actions.map((action) {
          return CupertinoDialogAction(
            onPressed: action.onPressed,
            isDestructiveAction: action.isDestructive,
            child: Text(action.text),
          );
        }).toList(),
      ),
    );
  }

  ButtonStyle? _getAndroidActionStyle(bool isDestructive) {
    if (isDestructive) {
      return TextButton.styleFrom(foregroundColor: Colors.red);
    }
    return null;
  }
}

class PlatformDialogAction {
  final String text;
  final VoidCallback onPressed;
  final bool isDestructive;

  const PlatformDialogAction({
    required this.text,
    required this.onPressed,
    this.isDestructive = false,
  });
}
