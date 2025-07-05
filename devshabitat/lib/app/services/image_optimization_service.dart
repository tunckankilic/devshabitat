import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:logger/logger.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ImageOptimizationService extends GetxService {
  static ImageOptimizationService get to => Get.find();

  final Logger _logger = Logger();
  final DefaultCacheManager _cacheManager = DefaultCacheManager();

  // Önbellek ayarları
  static const Duration cacheDuration = Duration(days: 7);
  static const int maxCacheSize = 200; // MB cinsinden
  static const int compressionQuality = 85;

  // Resim boyutları için presetler
  static const Map<String, Size> imageSizePresets = {
    'thumbnail': Size(100, 100),
    'small': Size(300, 300),
    'medium': Size(600, 600),
    'large': Size(1200, 1200),
  };

  @override
  void onInit() {
    super.onInit();
    _initializeCache();
  }

  Future<void> _initializeCache() async {
    try {
      final cacheDir = await getTemporaryDirectory();
      final cacheSize = await _calculateDirectorySize(cacheDir);

      // Önbellek boyutu limiti aşıldıysa temizle
      if (cacheSize > maxCacheSize * 1024 * 1024) {
        await _cacheManager.emptyCache();
        _logger.i('Cache cleared due to size limit');
      }
    } catch (e) {
      _logger.e('Error initializing image cache: $e');
    }
  }

  // Optimize edilmiş resim widget'ı
  Widget optimizedImage({
    required String imageUrl,
    double? width,
    double? height,
    BoxFit? fit,
    String preset = 'medium',
    Widget? placeholder,
    Widget? errorWidget,
    bool useLazyLoading = true,
  }) {
    // Resim boyutunu belirle
    final targetSize = imageSizePresets[preset] ?? imageSizePresets['medium']!;
    final optimizedUrl = _getOptimizedImageUrl(
      imageUrl,
      width: targetSize.width.toInt(),
      height: targetSize.height.toInt(),
    );

    if (!useLazyLoading) {
      return _buildCachedImage(
        optimizedUrl,
        width,
        height,
        fit,
        placeholder,
        errorWidget,
      );
    }

    return VisibilityDetector(
      key: Key(optimizedUrl),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0) {
          _prefetchImage(optimizedUrl);
        }
      },
      child: _buildCachedImage(
        optimizedUrl,
        width,
        height,
        fit,
        placeholder,
        errorWidget,
      ),
    );
  }

  Widget _buildCachedImage(
    String imageUrl,
    double? width,
    double? height,
    BoxFit? fit,
    Widget? placeholder,
    Widget? errorWidget,
  ) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit ?? BoxFit.cover,
      placeholder: (context, url) =>
          placeholder ?? const CircularProgressIndicator(),
      errorWidget: (context, url, error) =>
          errorWidget ?? const Icon(Icons.error),
      cacheManager: _cacheManager,
      fadeInDuration: const Duration(milliseconds: 300),
      maxHeightDiskCache: 1200,
      memCacheHeight: 800,
      useOldImageOnUrlChange: true,
    );
  }

  // Resmi önbelleğe al
  Future<void> _prefetchImage(String imageUrl) async {
    try {
      await _cacheManager.downloadFile(imageUrl);
    } catch (e) {
      _logger.e('Error prefetching image: $e');
    }
  }

  // Resmi önbellekten temizle
  Future<void> clearImageCache(String imageUrl) async {
    try {
      await _cacheManager.removeFile(imageUrl);
    } catch (e) {
      _logger.e('Error clearing image cache: $e');
    }
  }

  // Tüm resim önbelleğini temizle
  Future<void> clearAllImageCache() async {
    try {
      await _cacheManager.emptyCache();
    } catch (e) {
      _logger.e('Error clearing all image cache: $e');
    }
  }

  // Resmi optimize et ve kaydet
  Future<File?> optimizeAndSaveImage(File imageFile) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath = path.join(
        dir.path,
        'optimized_${path.basename(imageFile.path)}',
      );

      final result = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        targetPath,
        quality: compressionQuality,
        keepExif: false,
      );

      if (result != null) {
        final originalSize = await imageFile.length();
        final optimizedSize = await result.length();

        _logger.i(
          'Image optimized: ${(originalSize - optimizedSize) / 1024}KB reduced',
        );
        return File(result.path);
      }

      return null;
    } catch (e) {
      _logger.e('Error optimizing image: $e');
      return null;
    }
  }

  // Resim URL'ini optimize et
  String _getOptimizedImageUrl(
    String url, {
    required int width,
    required int height,
  }) {
    // CDN veya resim servisine göre URL'i optimize et
    if (url.contains('cloudinary.com')) {
      return _optimizeCloudinaryUrl(url, width, height);
    } else if (url.contains('imgix.net')) {
      return _optimizeImgixUrl(url, width, height);
    }
    return url;
  }

  // Cloudinary URL optimizasyonu
  String _optimizeCloudinaryUrl(String url, int width, int height) {
    final uri = Uri.parse(url);
    final pathSegments = List<String>.from(uri.pathSegments);

    // Transformasyon parametrelerini ekle
    if (!pathSegments.contains('upload')) {
      return url;
    }

    final transformIndex = pathSegments.indexOf('upload');
    pathSegments.insert(transformIndex + 1, 'c_fill,w_$width,h_$height,q_auto');

    return uri.replace(pathSegments: pathSegments).toString();
  }

  // Imgix URL optimizasyonu
  String _optimizeImgixUrl(String url, int width, int height) {
    final uri = Uri.parse(url);
    final queryParams = Map<String, String>.from(uri.queryParameters);

    queryParams.addAll({
      'w': width.toString(),
      'h': height.toString(),
      'fit': 'crop',
      'auto': 'compress,format',
    });

    return uri.replace(queryParameters: queryParams).toString();
  }

  // Önbellek boyutunu hesapla
  Future<int> _calculateDirectorySize(Directory directory) async {
    int totalSize = 0;
    try {
      final files = directory.listSync(recursive: true, followLinks: false);
      for (var file in files) {
        if (file is File) {
          totalSize += await file.length();
        }
      }
    } catch (e) {
      _logger.e('Error calculating directory size: $e');
    }
    return totalSize;
  }

  @override
  void onClose() {
    _cacheManager.dispose();
    super.onClose();
  }
}
