import 'package:flutter/material.dart';

class SettingsListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isLargeScreen;

  const SettingsListTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.trailing,
    this.onTap,
    this.isLargeScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: isLargeScreen ? 32.0 : 16.0,
        vertical: 8.0,
      ),
      leading: Icon(
        icon,
        size: isLargeScreen ? 32.0 : 24.0,
        color: Theme.of(context).primaryColor,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: isLargeScreen ? 18.0 : 16.0,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: TextStyle(
                fontSize: isLargeScreen ? 14.0 : 12.0,
              ),
            )
          : null,
      trailing: trailing,
      onTap: onTap,
    );
  }
}
