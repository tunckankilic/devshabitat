import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/responsive_controller.dart';

class ResponsiveOverflowHandler extends StatelessWidget {
  final Widget child;
  final bool handleHorizontal;
  final bool handleVertical;
  final ScrollPhysics? physics;
  final EdgeInsets? padding;
  final bool adaptivePadding;
  final ScrollController? horizontalController;
  final ScrollController? verticalController;
  final Clip clipBehavior;

  const ResponsiveOverflowHandler({
    super.key,
    required this.child,
    this.handleHorizontal = true,
    this.handleVertical = true,
    this.physics,
    this.padding,
    this.adaptivePadding = true,
    this.horizontalController,
    this.verticalController,
    this.clipBehavior = Clip.hardEdge,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = Get.find<ResponsiveController>();

    Widget result = child;

    if (padding != null) {
      EdgeInsets finalPadding = padding!;
      if (adaptivePadding) {
        finalPadding = EdgeInsets.only(
          left: responsive.responsiveValue(
            mobile: padding!.left,
            tablet: padding!.left * 1.5,
          ),
          top: responsive.responsiveValue(
            mobile: padding!.top,
            tablet: padding!.top * 1.5,
          ),
          right: responsive.responsiveValue(
            mobile: padding!.right,
            tablet: padding!.right * 1.5,
          ),
          bottom: responsive.responsiveValue(
            mobile: padding!.bottom,
            tablet: padding!.bottom * 1.5,
          ),
        );
      }
      result = Padding(
        padding: finalPadding,
        child: result,
      );
    }

    if (handleHorizontal) {
      result = SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: physics,
        controller: horizontalController,
        clipBehavior: clipBehavior,
        child: result,
      );
    }

    if (handleVertical) {
      result = SingleChildScrollView(
        physics: physics,
        controller: verticalController,
        clipBehavior: clipBehavior,
        child: result,
      );
    }

    return result;
  }
}

// Safe area responsive wrapper
class ResponsiveSafeArea extends StatelessWidget {
  final Widget child;
  final bool top;
  final bool bottom;
  final bool left;
  final bool right;
  final EdgeInsets? minimumPadding;

  const ResponsiveSafeArea({
    super.key,
    required this.child,
    this.top = true,
    this.bottom = true,
    this.left = true,
    this.right = true,
    this.minimumPadding,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = Get.find<ResponsiveController>();

    return SafeArea(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      minimum: minimumPadding ??
          responsive.responsivePadding(
            left: 16,
            right: 16,
            top: 8,
            bottom: 8,
          ),
      child: child,
    );
  }
}

// Responsive flex wrapper that prevents overflow
class ResponsiveFlex extends StatelessWidget {
  final List<Widget> children;
  final Axis direction;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;
  final bool forceScroll;

  const ResponsiveFlex({
    super.key,
    required this.children,
    this.direction = Axis.vertical,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
    this.forceScroll = false,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = Get.find<ResponsiveController>();

    // Force scroll on small screens or when explicitly requested
    if (forceScroll || responsive.isSmallPhone) {
      return SingleChildScrollView(
        scrollDirection: direction,
        physics: const BouncingScrollPhysics(),
        child: _buildFlex(),
      );
    }

    return _buildFlex();
  }

  Widget _buildFlex() {
    return Flex(
      direction: direction,
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: children,
    );
  }
}

// Responsive text that adjusts to prevent overflow
class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow overflow;
  final TextAlign? textAlign;
  final double? minFontSize;
  final double? maxFontSize;

  const ResponsiveText(
    this.text, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow = TextOverflow.ellipsis,
    this.textAlign,
    this.minFontSize,
    this.maxFontSize,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = Get.find<ResponsiveController>();

    // Calculate responsive font size
    double baseFontSize = style?.fontSize ?? 16.0;
    double responsiveFontSize = responsive.responsiveValue(
      mobile: baseFontSize,
      tablet: baseFontSize * 1.2,
    );

    // Apply min/max constraints
    if (minFontSize != null && responsiveFontSize < minFontSize!) {
      responsiveFontSize = minFontSize!;
    }
    if (maxFontSize != null && responsiveFontSize > maxFontSize!) {
      responsiveFontSize = maxFontSize!;
    }

    return Text(
      text,
      style: style?.copyWith(fontSize: responsiveFontSize) ??
          TextStyle(fontSize: responsiveFontSize),
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
    );
  }
}

// Responsive image that maintains aspect ratio
class ResponsiveImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const ResponsiveImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    Widget image = Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return placeholder ?? const CircularProgressIndicator();
      },
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ?? const Icon(Icons.error);
      },
    );

    if (borderRadius != null) {
      image = ClipRRect(
        borderRadius: borderRadius!,
        child: image,
      );
    }

    return image;
  }
}
