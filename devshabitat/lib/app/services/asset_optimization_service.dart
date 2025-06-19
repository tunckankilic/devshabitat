import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AssetOptimizationService extends GetxService {
  final DefaultCacheManager _cacheManager = DefaultCacheManager();

  /// Önbelleğe alınmış network image widget'ı
  Widget getOptimizedNetworkImage({
    required String imageUrl,
    double? width,
    double? height,
    BoxFit? fit,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit ?? BoxFit.cover,
      placeholder: (context, url) =>
          placeholder ?? const Center(child: CircularProgressIndicator()),
      errorWidget: (context, url, error) =>
          errorWidget ?? const Icon(Icons.error),
      cacheManager: _cacheManager,
      fadeInDuration: const Duration(milliseconds: 300),
      memCacheWidth: width?.toInt(),
      memCacheHeight: height?.toInt(),
    );
  }

  /// Önbellek temizleme
  Future<void> clearImageCache() async {
    await _cacheManager.emptyCache();
    imageCache.clear();
    imageCache.clearLiveImages();
  }

  /// Belirli bir URL için önbelleği temizle
  Future<void> removeFromCache(String url) async {
    await _cacheManager.removeFile(url);
  }

  /// Önbelleğe alma işlemi
  Future<void> preCacheImage(String url) async {
    try {
      await _cacheManager.downloadFile(url);
    } catch (e) {
      debugPrint('Resim önbelleğe alınırken hata: $e');
    }
  }

  /// Toplu önbelleğe alma
  Future<void> preCacheImages(List<String> urls) async {
    for (final url in urls) {
      await preCacheImage(url);
    }
  }

  /// Önbellek durumunu kontrol et
  Future<bool> isImageCached(String url) async {
    final fileInfo = await _cacheManager.getFileFromCache(url);
    return fileInfo != null;
  }

  /// Önbellek boyutunu al
  Future<int> getCacheSize() async {
    final hasCache = await _cacheManager.getFileFromCache('/');
    return hasCache?.file.lengthSync() ?? 0;
  }
}
