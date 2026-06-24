import 'user_model.dart';
import 'post_model.dart';

enum NotificationType {
  like,
  comment,
  follow,
  system,
}

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String timeAgo;
  final NotificationType type;
  final String? avatarUrl;
  bool isRead;
  final UserModel? relatedUser;
  final PostModel? relatedPost;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.timeAgo,
    required this.type,
    this.avatarUrl,
    this.isRead = false,
    this.relatedUser,
    this.relatedPost,
  });
}
