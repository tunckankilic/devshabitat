import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/file_upload_controller.dart';
import '../models/message_model.dart';
import '../core/theme/dev_habitat_colors.dart';

class AdvancedFileUpload extends StatefulWidget {
  final String userId;
  final String conversationId;
  final Function(List<AttachmentData>) onFilesSelected;
  final Function(AttachmentData) onFileUploaded;
  final Function(String) onUploadCancelled;
  final bool showPreview;
  final bool allowMultiple;
  final List<String> allowedExtensions;
  final int maxFileSizeMB;
  final String? customTitle;
  final String? customSubtitle;

  const AdvancedFileUpload({
    super.key,
    required this.userId,
    required this.conversationId,
    required this.onFilesSelected,
    required this.onFileUploaded,
    required this.onUploadCancelled,
    this.showPreview = true,
    this.allowMultiple = true,
    this.allowedExtensions = const [],
    this.maxFileSizeMB = 10,
    this.customTitle,
    this.customSubtitle,
  });

  @override
  State<AdvancedFileUpload> createState() => _AdvancedFileUploadState();
}

class _AdvancedFileUploadState extends State<AdvancedFileUpload>
    with TickerProviderStateMixin {
  final FileUploadController _controller = Get.find<FileUploadController>();
  final List<File> _selectedFiles = [];
  final List<AttachmentData> _uploadedFiles = [];
  bool _isDragOver = false;
  bool _isUploading = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _selectFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: widget.allowMultiple,
        allowedExtensions: widget.allowedExtensions.isNotEmpty
            ? widget.allowedExtensions
            : null,
      );

      if (result != null && result.files.isNotEmpty) {
        final files = result.files
            .where((file) => file.path != null)
            .map((file) => File(file.path!))
            .toList();

        await _processSelectedFiles(files);
      }
    } catch (e) {
      _showErrorSnackbar('Dosya seçilirken hata oluştu: $e');
    }
  }

  Future<void> _selectImages() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage(
        imageQuality: 80,
      );

      if (images.isNotEmpty) {
        final files = images.map((image) => File(image.path)).toList();
        await _processSelectedFiles(files);
      }
    } catch (e) {
      _showErrorSnackbar('Resim seçilirken hata oluştu: $e');
    }
  }

  Future<void> _processSelectedFiles(List<File> files) async {
    final validFiles = <File>[];
    final errors = <String>[];

    for (final file in files) {
      // Dosya boyutu kontrolü
      final fileSizeMB = await file.length() / (1024 * 1024);
      if (fileSizeMB > widget.maxFileSizeMB) {
        errors.add(
            '${file.path.split('/').last} dosyası çok büyük (${fileSizeMB.toStringAsFixed(1)}MB)');
        continue;
      }

      // Dosya türü kontrolü
      if (widget.allowedExtensions.isNotEmpty) {
        final extension = file.path.split('.').last.toLowerCase();
        if (!widget.allowedExtensions.contains(extension)) {
          errors.add('${file.path.split('/').last} dosya türü desteklenmiyor');
          continue;
        }
      }

      validFiles.add(file);
    }

    if (errors.isNotEmpty) {
      _showErrorSnackbar(errors.join('\n'));
    }

    if (validFiles.isNotEmpty) {
      setState(() {
        _selectedFiles.addAll(validFiles);
      });

      widget.onFilesSelected(_selectedFiles
          .map((file) => AttachmentData(
                type: _getAttachmentType(file.path),
                url: file.path,
                name: file.path.split('/').last,
                size: file.lengthSync(),
              ))
          .toList());

      if (widget.showPreview) {
        _showPreviewDialog();
      }
    }
  }

  AttachmentType _getAttachmentType(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    final imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
    final videoExtensions = ['mp4', 'mov', 'avi', 'mkv'];
    final audioExtensions = ['mp3', 'wav', 'ogg', 'm4a'];

    if (imageExtensions.contains(extension)) {
      return AttachmentType.image;
    } else if (videoExtensions.contains(extension)) {
      return AttachmentType.video;
    } else if (audioExtensions.contains(extension)) {
      return AttachmentType.audio;
    }
    return AttachmentType.file;
  }

  Future<void> _uploadFiles() async {
    if (_selectedFiles.isEmpty) return;

    setState(() {
      _isUploading = true;
    });

    for (final file in _selectedFiles) {
      try {
        final messageId = DateTime.now().millisecondsSinceEpoch.toString();
        final attachment = await _controller.uploadWithProgress(
          file,
          widget.userId,
          messageId,
        );

        if (attachment != null) {
          _uploadedFiles.add(attachment);
          widget.onFileUploaded(attachment);
        }
      } catch (e) {
        _showErrorSnackbar(
            '${file.path.split('/').last} yüklenirken hata oluştu: $e');
      }
    }

    setState(() {
      _isUploading = false;
      _selectedFiles.clear();
    });
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  void _showPreviewDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: Get.width * 0.9,
          height: Get.height * 0.7,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Seçilen Dosyalar (${_selectedFiles.length})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _selectedFiles.length,
                  itemBuilder: (context, index) {
                    final file = _selectedFiles[index];
                    final attachmentType = _getAttachmentType(file.path);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: _buildFileIcon(attachmentType),
                        title: Text(
                          file.path.split('/').last,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(_formatFileSize(file.lengthSync())),
                        trailing: IconButton(
                          onPressed: () => _removeFile(index),
                          icon: const Icon(Icons.remove_circle,
                              color: Colors.red),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _selectedFiles.isEmpty ? null : _uploadFiles,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DevHabitatColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Yükle'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _selectedFiles.clear();
                        });
                        Get.back();
                      },
                      child: const Text('İptal'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileIcon(AttachmentType type) {
    IconData iconData;
    Color iconColor;

    switch (type) {
      case AttachmentType.image:
        iconData = Icons.image;
        iconColor = Colors.green;
        break;
      case AttachmentType.video:
        iconData = Icons.video_file;
        iconColor = Colors.red;
        break;
      case AttachmentType.audio:
        iconData = Icons.audio_file;
        iconColor = Colors.orange;
        break;
      case AttachmentType.file:
        iconData = Icons.insert_drive_file;
        iconColor = Colors.blue;
        break;
    }

    return Icon(iconData, color: iconColor, size: 32);
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Hata',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: _isDragOver
                    ? DevHabitatColors.primary
                    : Colors.grey.shade300,
                width: _isDragOver ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
              color: _isDragOver
                  ? DevHabitatColors.primary.withOpacity(0.1)
                  : Colors.grey.shade50,
            ),
            child: DragTarget<File>(
              onWillAccept: (files) {
                setState(() {
                  _isDragOver = true;
                });
                _animationController.forward();
                return true;
              },
              onAccept: (files) async {
                setState(() {
                  _isDragOver = false;
                });
                _animationController.reverse();
                await _processSelectedFiles([files]);
              },
              onLeave: (files) {
                setState(() {
                  _isDragOver = false;
                });
                _animationController.reverse();
              },
              builder: (context, candidateData, rejectedData) {
                return GestureDetector(
                  onTap: _showFileSelectionDialog,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isDragOver
                              ? Icons.cloud_upload
                              : Icons.cloud_upload_outlined,
                          size: 48,
                          color: _isDragOver
                              ? DevHabitatColors.primary
                              : Colors.grey.shade600,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.customTitle ?? 'Dosya Yükle',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _isDragOver
                                ? DevHabitatColors.primary
                                : Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.customSubtitle ??
                              'Dosyaları buraya sürükleyin veya seçmek için tıklayın',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                        ),
                        if (_selectedFiles.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: DevHabitatColors.primary,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              '${_selectedFiles.length} dosya seçildi',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                        if (_isUploading) ...[
                          const SizedBox(height: 16),
                          const LinearProgressIndicator(),
                          const SizedBox(height: 8),
                          const Text('Yükleniyor...'),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showFileSelectionDialog() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Dosya Seç',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildSelectionOption(
                    icon: Icons.photo_library,
                    title: 'Galeri',
                    subtitle: 'Resim seç',
                    onTap: () {
                      Get.back();
                      _selectImages();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSelectionOption(
                    icon: Icons.folder_open,
                    title: 'Dosya',
                    subtitle: 'Dosya seç',
                    onTap: () {
                      Get.back();
                      _selectFiles();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: DevHabitatColors.primary),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Progress tracking widget
class UploadProgressWidget extends StatelessWidget {
  final String fileName;
  final double progress;
  final VoidCallback? onCancel;

  const UploadProgressWidget({
    super.key,
    required this.fileName,
    required this.progress,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              if (onCancel != null)
                IconButton(
                  onPressed: onCancel,
                  icon: const Icon(Icons.close, size: 16),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(DevHabitatColors.primary),
          ),
          const SizedBox(height: 4),
          Text(
            '${(progress * 100).toInt()}%',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
