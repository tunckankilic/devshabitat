import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/responsive_controller.dart';

class ResponsiveWrapper extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveWrapper({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = Get.find<ResponsiveController>();

    return Obx(() {
      if (responsive.isDesktop) {
        return desktop ?? tablet ?? mobile;
      } else if (responsive.isTablet) {
        return tablet ?? mobile;
      } else {
        return mobile;
      }
    });
  }
}

class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ResponsiveController responsive)
  builder;

  const ResponsiveBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    final responsive = Get.find<ResponsiveController>();
    return Obx(() => builder(context, responsive));
  }
}

class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? maxWidth;
  final double? maxHeight;
  final Color? backgroundColor;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.padding,
    this.maxWidth,
    this.maxHeight,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = Get.find<ResponsiveController>();

    return Obx(() {
      EdgeInsets responsivePadding = padding ?? EdgeInsets.zero;

      if (padding == null) {
        if (responsive.isMobile) {
          responsivePadding = const EdgeInsets.all(16);
        } else if (responsive.isTablet) {
          responsivePadding = const EdgeInsets.all(24);
        } else {
          responsivePadding = const EdgeInsets.all(32);
        }
      }

      Widget content = Container(
        padding: responsivePadding,
        color: backgroundColor,
        child: child,
      );

      if (maxWidth != null || maxHeight != null) {
        content = ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxWidth ?? double.infinity,
            maxHeight: maxHeight ?? double.infinity,
          ),
          child: content,
        );
      }

      return content;
    });
  }
}

class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final double spacing;
  final double runSpacing;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
    this.spacing = 16,
    this.runSpacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = Get.find<ResponsiveController>();

    return Obx(() {
      int columns = mobileColumns;

      if (responsive.isDesktop) {
        columns = desktopColumns;
      } else if (responsive.isTablet) {
        columns = tabletColumns;
      }

      return Wrap(
        spacing: spacing,
        runSpacing: runSpacing,
        children: children.map((child) {
          return SizedBox(
            width:
                (MediaQuery.of(context).size.width -
                    (spacing * (columns - 1))) /
                columns,
            child: child,
          );
        }).toList(),
      );
    });
  }
}

class ResponsiveRow extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final bool wrapOnMobile;

  const ResponsiveRow({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.wrapOnMobile = true,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = Get.find<ResponsiveController>();

    return Obx(() {
      if (responsive.isMobile && wrapOnMobile) {
        return Column(
          mainAxisAlignment: mainAxisAlignment,
          crossAxisAlignment: crossAxisAlignment,
          children: children,
        );
      } else {
        return Row(
          mainAxisAlignment: mainAxisAlignment,
          crossAxisAlignment: crossAxisAlignment,
          children: children,
        );
      }
    });
  }
}

class ResponsiveColumn extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final bool rowOnDesktop;

  const ResponsiveColumn({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.rowOnDesktop = false,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = Get.find<ResponsiveController>();

    return Obx(() {
      if (responsive.isDesktop && rowOnDesktop) {
        return Row(
          mainAxisAlignment: mainAxisAlignment,
          crossAxisAlignment: crossAxisAlignment,
          children: children,
        );
      } else {
        return Column(
          mainAxisAlignment: mainAxisAlignment,
          crossAxisAlignment: crossAxisAlignment,
          children: children,
        );
      }
    });
  }
}

class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const ResponsiveText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = Get.find<ResponsiveController>();

    return Obx(() {
      TextStyle responsiveStyle = style ?? const TextStyle();

      // Font size adjustments based on screen size
      if (style?.fontSize != null) {
        double fontSize = style!.fontSize!;

        if (responsive.isMobile) {
          fontSize *= 0.9; // 10% smaller on mobile
        } else if (responsive.isDesktop) {
          fontSize *= 1.1; // 10% larger on desktop
        }

        responsiveStyle = responsiveStyle.copyWith(fontSize: fontSize);
      }

      return Text(
        text,
        style: responsiveStyle,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      );
    });
  }
}

class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final double? mobile;
  final double? tablet;
  final double? desktop;

  const ResponsivePadding({
    super.key,
    required this.child,
    this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = Get.find<ResponsiveController>();

    return Obx(() {
      double padding = mobile ?? 16;

      if (responsive.isDesktop) {
        padding = desktop ?? tablet ?? mobile ?? 32;
      } else if (responsive.isTablet) {
        padding = tablet ?? mobile ?? 24;
      }

      return Padding(padding: EdgeInsets.all(padding), child: child);
    });
  }
}
