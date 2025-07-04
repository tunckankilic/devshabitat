import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';

class AssetOptimizationService extends GetxService {
  static const int _maxConcurrentDownloads = 3;

  final DefaultCacheManager _cacheManager = DefaultCacheManager();
  final Map<String, Future<File?>> _preloadQueue = {};
  final int _maxPreloadQueueSize = 20;
  final Duration _preloadTimeout = const Duration(seconds: 30);
  final _semaphore = Semaphore(_maxConcurrentDownloads);

  /// Önbelleğe alınmış network image widget'ı
  Widget getOptimizedNetworkImage({
    required String imageUrl,
    double? width,
    double? height,
    BoxFit? fit,
    Widget? placeholder,
    Widget? errorWidget,
    bool preload = false,
    int? maxWidth,
    int? maxHeight,
    int? memCacheWidth,
    int? memCacheHeight,
  }) {
    if (preload) {
      _preloadImage(imageUrl);
    }

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
      memCacheWidth: memCacheWidth ?? width?.toInt(),
      memCacheHeight: memCacheHeight ?? height?.toInt(),
      maxWidthDiskCache: maxWidth,
      maxHeightDiskCache: maxHeight,
      progressIndicatorBuilder: (context, url, progress) {
        return Center(
          child: CircularProgressIndicator(
            value: progress.progress,
          ),
        );
      },
    );
  }

  Future<void> _preloadImage(String url) async {
    if (_preloadQueue.length >= _maxPreloadQueueSize) {
      final oldestUrl = _preloadQueue.keys.first;
      _preloadQueue.remove(oldestUrl);
    }

    if (!_preloadQueue.containsKey(url)) {
      _preloadQueue[url] = _downloadWithTimeout(url);
    }
  }

  Future<File?> _downloadWithTimeout(String url) async {
    try {
      await _semaphore.acquire();
      return await _cacheManager
          .getSingleFile(url)
          .timeout(_preloadTimeout)
          .whenComplete(() => _semaphore.release());
    } catch (e) {
      _semaphore.release();
      debugPrint('Resim önbelleğe alınırken hata: $e');
      return null;
    }
  }

  /// Önbellek temizleme
  Future<void> clearImageCache() async {
    await _cacheManager.emptyCache();
    imageCache.clear();
    imageCache.clearLiveImages();
    _preloadQueue.clear();
  }

  /// Belirli bir URL için önbelleği temizle
  Future<void> removeFromCache(String url) async {
    await _cacheManager.removeFile(url);
    _preloadQueue.remove(url);
  }

  /// Önbelleğe alma işlemi
  Future<void> preCacheImage(String url) async {
    try {
      await _preloadImage(url);
    } catch (e) {
      debugPrint('Resim önbelleğe alınırken hata: $e');
    }
  }

  /// Toplu önbelleğe alma
  Future<void> preCacheImages(List<String> urls) async {
    final chunks = _chunkList(urls, _maxConcurrentDownloads);
    for (final chunk in chunks) {
      await Future.wait(
        chunk.map((url) => preCacheImage(url)),
      );
    }
  }

  List<List<T>> _chunkList<T>(List<T> list, int chunkSize) {
    final chunks = <List<T>>[];
    for (var i = 0; i < list.length; i += chunkSize) {
      chunks.add(
        list.sublist(
          i,
          i + chunkSize > list.length ? list.length : i + chunkSize,
        ),
      );
    }
    return chunks;
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

  @override
  void onClose() {
    _preloadQueue.clear();
    super.onClose();
  }
}

class Semaphore {
  final int maxCount;
  int _currentCount = 0;
  final List<Completer<void>> _queue = [];

  Semaphore(this.maxCount);

  Future<void> acquire() async {
    if (_currentCount < maxCount) {
      _currentCount++;
      return;
    }

    final completer = Completer<void>();
    _queue.add(completer);
    await completer.future;
  }

  void release() {
    if (_queue.isEmpty) {
      _currentCount--;
    } else {
      final completer = _queue.removeAt(0);
      completer.complete();
    }
  }
}
