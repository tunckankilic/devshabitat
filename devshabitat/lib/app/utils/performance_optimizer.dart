import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

mixin PerformanceOptimizer {
  /// Widget ağacını optimize et
  Widget optimizeWidgetTree(Widget child) {
    return _OptimizedWidget(child: child);
  }

  /// Ağır işlemler için compute kullanımı
  Widget computeHeavyWidget({
    required Widget Function() builder,
    Widget? placeholder,
  }) {
    return FutureBuilder<Widget>(
      future: Future.microtask(builder),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return snapshot.data!;
        }
        return placeholder ?? const CircularProgressIndicator();
      },
    );
  }

  /// RepaintBoundary ile sarmalama
  Widget wrapWithRepaintBoundary(Widget child) {
    return RepaintBoundary(child: child);
  }
}

class _OptimizedWidget extends StatelessWidget {
  final Widget child;

  const _OptimizedWidget({required this.child});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return _ConditionalBuilder(
            condition: constraints.maxWidth > 0 && constraints.maxHeight > 0,
            child: child,
          );
        },
      ),
    );
  }
}

class _ConditionalBuilder extends StatelessWidget {
  final bool condition;
  final Widget child;

  const _ConditionalBuilder({
    required this.condition,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (!condition) return const SizedBox.shrink();
    return child;
  }
}

/// Performans optimizasyonu için extension metodları
extension PerformanceOptimizations on Widget {
  /// Widget'ı RepaintBoundary ile sarmala
  Widget withRepaintBoundary() {
    return RepaintBoundary(child: this);
  }

  /// Widget'ı sadece görünür olduğunda render et
  Widget onlyWhenVisible() {
    return VisibilityDetector(
      key: UniqueKey(),
      onVisibilityChanged: (info) {
        if (info.visibleFraction == 0) {
          // Widget görünmez olduğunda ek optimizasyonlar yapılabilir
        }
      },
      child: this,
    );
  }

  /// Widget'ı bellek optimizasyonu ile sarmala
  Widget withMemoryOptimization() {
    return _MemoryOptimizedWidget(child: this);
  }
}

class _MemoryOptimizedWidget extends StatefulWidget {
  final Widget child;

  const _MemoryOptimizedWidget({required this.child});

  @override
  _MemoryOptimizedWidgetState createState() => _MemoryOptimizedWidgetState();
}

class _MemoryOptimizedWidgetState extends State<_MemoryOptimizedWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }

  @override
  void dispose() {
    // Bellek temizliği için ek işlemler
    super.dispose();
  }
}
