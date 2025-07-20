import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/responsive_controller.dart';

class SocialLoginButton extends StatelessWidget {
  late final _responsiveController = Get.find<ResponsiveController>();
  final String text;
  final String imagePath;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? textColor;

  SocialLoginButton({
    Key? key,
    required this.text,
    required this.imagePath,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.backgroundColor,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _responsiveController.responsiveValue(
        mobile: 48.0,
        tablet: 56.0,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          _responsiveController.responsiveValue(
            mobile: 8.0,
            tablet: 12.0,
          ),
        ),
        border: isOutlined ? Border.all(color: Colors.grey[300]!) : null,
        color: backgroundColor ?? (isOutlined ? Colors.white : Colors.blue),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(
            _responsiveController.responsiveValue(
              mobile: 8.0,
              tablet: 12.0,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: _responsiveController.responsiveValue(
                mobile: 16.0,
                tablet: 24.0,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  SizedBox(
                    width: _responsiveController.responsiveValue(
                      mobile: 24.0,
                      tablet: 32.0,
                    ),
                    height: _responsiveController.responsiveValue(
                      mobile: 24.0,
                      tablet: 32.0,
                    ),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        textColor ?? Colors.white,
                      ),
                    ),
                  )
                else ...[
                  SizedBox(
                    width: _responsiveController.responsiveValue(
                      mobile: 8.0,
                      tablet: 12.0,
                    ),
                  ),
                  Image.asset(
                    imagePath,
                    height: _responsiveController.responsiveValue(
                      mobile: 24.0,
                      tablet: 32.0,
                    ),
                    width: _responsiveController.responsiveValue(
                      mobile: 24.0,
                      tablet: 32.0,
                    ),
                  ),
                  SizedBox(
                    width: _responsiveController.responsiveValue(
                      mobile: 8.0,
                      tablet: 12.0,
                    ),
                  ),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: _responsiveController.responsiveValue(
                        mobile: 16.0,
                        tablet: 18.0,
                      ),
                      color: textColor ?? Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
