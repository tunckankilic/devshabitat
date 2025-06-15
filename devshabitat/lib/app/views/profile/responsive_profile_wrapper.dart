import 'package:flutter/material.dart';
import '../../controllers/profile_controller.dart';
import 'small_phone_profile.dart';
import 'large_phone_profile.dart';
import 'tablet_profile.dart';

class ResponsiveProfileWrapper extends StatelessWidget {
  final ProfileController profileController;

  const ResponsiveProfileWrapper({
    Key? key,
    required this.profileController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Tablet boyutu (768px ve üzeri)
        if (constraints.maxWidth >= 768) {
          return TabletProfile(profileController: profileController);
        }
        // Büyük telefon boyutu (480px - 767px)
        else if (constraints.maxWidth >= 480) {
          return LargePhoneProfile(profileController: profileController);
        }
        // Küçük telefon boyutu (480px altı)
        else {
          return SmallPhoneProfile(profileController: profileController);
        }
      },
    );
  }
}
