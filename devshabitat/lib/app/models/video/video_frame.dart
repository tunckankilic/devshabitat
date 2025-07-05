import 'dart:typed_data';

class VideoFrame {
  final int width;
  final int height;
  final int rotation;
  final int timestamp;
  final Uint8List data;

  VideoFrame({
    required this.width,
    required this.height,
    required this.rotation,
    required this.timestamp,
    required this.data,
  });

  Future<dynamic> toImage() async {
    // Bu metod platform-specific olarak implemente edilmeli
    throw UnimplementedError('Platform specific implementation required');
  }
}
