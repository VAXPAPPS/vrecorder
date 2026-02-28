import 'package:equatable/equatable.dart';

class Recording extends Equatable {
  final String id;
  final String filename;
  final String filePath;
  final DateTime createdAt;
  final Duration duration;
  final int fileSize; // in bytes
  final String? notes;

  const Recording({
    required this.id,
    required this.filename,
    required this.filePath,
    required this.createdAt,
    required this.duration,
    required this.fileSize,
    this.notes,
  });

  /// Empty Recording for default values
  Recording.empty()
      : id = '',
        filename = '',
        filePath = '',
        createdAt = DateTime.now(),
        duration = Duration.zero,
        fileSize = 0,
        notes = null;

  @override
  List<Object?> get props => [
        id,
        filename,
        filePath,
        createdAt,
        duration,
        fileSize,
        notes,
      ];

  // Format duration as string
  String get durationString {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Format file size as string
  String get fileSizeString {
    if (fileSize < 1024) {
      return '$fileSize B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(2)} KB';
    } else {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
  }

  // Copy with updates
  Recording copyWith({
    String? id,
    String? filename,
    String? filePath,
    DateTime? createdAt,
    Duration? duration,
    int? fileSize,
    String? notes,
  }) {
    return Recording(
      id: id ?? this.id,
      filename: filename ?? this.filename,
      filePath: filePath ?? this.filePath,
      createdAt: createdAt ?? this.createdAt,
      duration: duration ?? this.duration,
      fileSize: fileSize ?? this.fileSize,
      notes: notes ?? this.notes,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'filename': filename,
    'filePath': filePath,
    'createdAt': createdAt.toIso8601String(),
    'duration': duration.inMilliseconds,
    'fileSize': fileSize,
    'notes': notes,
  };

  /// Create from JSON
  factory Recording.fromJson(Map<String, dynamic> json) {
    return Recording(
      id: json['id'] as String? ?? '',
      filename: json['filename'] as String? ?? '',
      filePath: json['filePath'] as String? ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      duration: Duration(milliseconds: json['duration'] as int? ?? 0),
      fileSize: json['fileSize'] as int? ?? 0,
      notes: json['notes'] as String?,
    );
  }
}
