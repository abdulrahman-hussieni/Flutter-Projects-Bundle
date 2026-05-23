import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Note {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final String userId;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.userId,
  });

  /// Converts the Note to Map for uploading to Firestore
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'userId': userId,
    };
  }

  /// Creates Note from Firestore data
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
      userId: json['userId'] ?? '',
    );
  }

  /// Readable date format
  String get formattedDate {
    return '${createdAt.day.toString().padLeft(2, '0')}/'
        '${createdAt.month.toString().padLeft(2, '0')}/'
        '${createdAt.year} '
        '${createdAt.hour.toString().padLeft(2, '0')}:'
        '${createdAt.minute.toString().padLeft(2, '0')}';
  }

  /// Shows only first 100 characters if content is long
  String get truncatedContent {
    if (content.length <= 100) return content;
    return '${content.substring(0, 100)}...';
  }
}