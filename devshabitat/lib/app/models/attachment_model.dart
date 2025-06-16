enum AttachmentType {
  image,
  video,
  document,
}

class MessageAttachment {
  final String id;
  final String url;
  final String fileName;
  final AttachmentType type;
  final int? size;
  final String? mimeType;
  final String? thumbnailUrl;

  MessageAttachment({
    required this.id,
    required this.url,
    required this.fileName,
    required this.type,
    this.size,
    this.mimeType,
    this.thumbnailUrl,
  });

  factory MessageAttachment.fromMap(Map<String, dynamic> map) {
    return MessageAttachment(
      id: map['id'] as String,
      url: map['url'] as String,
      fileName: map['fileName'] as String,
      type: AttachmentType.values.firstWhere(
        (type) => type.name == (map['type'] as String),
        orElse: () => AttachmentType.document,
      ),
      size: map['size'] as int?,
      mimeType: map['mimeType'] as String?,
      thumbnailUrl: map['thumbnailUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'url': url,
      'fileName': fileName,
      'type': type.name,
      'size': size,
      'mimeType': mimeType,
      'thumbnailUrl': thumbnailUrl,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'fileName': fileName,
      'type': type.name,
      'size': size,
      'mimeType': mimeType,
      'thumbnailUrl': thumbnailUrl,
    };
  }

  factory MessageAttachment.fromJson(Map<String, dynamic> json) {
    return MessageAttachment(
      id: json['id'] as String,
      url: json['url'] as String,
      fileName: json['fileName'] as String,
      type: AttachmentType.values.firstWhere(
        (type) => type.name == json['type'],
        orElse: () => AttachmentType.document,
      ),
      size: json['size'] as int?,
      mimeType: json['mimeType'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
    );
  }
}
