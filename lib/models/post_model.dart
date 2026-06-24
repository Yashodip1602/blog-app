import 'user_model.dart';

class PostModel {
  final String id;
  final String title;
  final String description;
  final String coverImageUrl;
  final String publishedDate;
  final String readingTime;
  final String likesCount;
  final String commentsCount;
  final UserModel author;

  PostModel({
    required this.id,
    required this.title,
    required this.description,
    required this.coverImageUrl,
    required this.publishedDate,
    required this.readingTime,
    required this.likesCount,
    required this.commentsCount,
    required this.author,
  });
}
