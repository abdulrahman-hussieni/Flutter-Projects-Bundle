import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
  });

  /// يحوّل الـ Note إلى Map لرفعه على Firestore
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      // Firestore بيفضل تخزين التاريخ كـ Timestamp
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// ينشئ Note من بيانات Firestore
  factory Note.fromJson(Map<String, dynamic> json) {
    final rawDate = json['createdAt'];

    DateTime dateTime;
    if (rawDate is Timestamp) {
      dateTime = rawDate.toDate();
    } else if (rawDate is String) {
      dateTime = DateTime.parse(rawDate);
    } else {
      dateTime = DateTime.now();
    }

    return Note(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      createdAt: dateTime,
    );
  }

  /// صيغة تاريخ مقروءة
  String get formattedDate {
    return '${createdAt.day.toString().padLeft(2, '0')}/'
        '${createdAt.month.toString().padLeft(2, '0')}/'
        '${createdAt.year} '
        '${createdAt.hour.toString().padLeft(2, '0')}:'
        '${createdAt.minute.toString().padLeft(2, '0')}';
  }

  /// يعرض أول 100 حرف فقط لو النص طويل
  String get truncatedContent {
    if (content.length <= 100) return content;
    return '${content.substring(0, 100)}...';
  }
}
