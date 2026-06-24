import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../utils/mock_data.dart';
import '../models/notification_model.dart';
import 'author_profile_screen.dart';
import 'blog_details_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late List<NotificationModel> _notifications;

  @override
  void initState() {
    super.initState();
    // Copy the list to avoid modifying the original mock data directly if we want to reset
    _notifications = List.from(MockDatabase.notifications);
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification.isRead = true;
      }
    });
  }

  void _markAsRead(int index) {
    final notification = _notifications[index];
    
    if (!notification.isRead) {
      setState(() {
        notification.isRead = true;
      });
    }

    // Handle Redirection
    if (notification.type == NotificationType.follow && notification.relatedUser != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AuthorProfileScreen(
            authorName: notification.relatedUser!.fullName,
            authorAvatarUrl: notification.relatedUser!.profilePhotoUrl,
          ),
        ),
      );
    } else if ((notification.type == NotificationType.like || notification.type == NotificationType.comment) &&
                notification.relatedPost != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BlogDetailsScreen(
            authorName: notification.relatedPost!.author.fullName,
            authorAvatarUrl: notification.relatedPost!.author.profilePhotoUrl,
            publishedDate: notification.relatedPost!.publishedDate,
            coverImageUrl: notification.relatedPost!.coverImageUrl,
            title: notification.relatedPost!.title,
            readingTime: notification.relatedPost!.readingTime,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Notifications',
                    style: GoogleFonts.inter(
                      color: AppColors.of(context).textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: _markAllAsRead,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.of(context).primary,
                    ),
                    child: Text(
                      'Mark all as read',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            
            // Notifications List
            Expanded(
              child: _notifications.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.notifications_off_outlined, size: 64, color: AppColors.of(context).textSecondary.withOpacity(0.5)),
                          const SizedBox(height: 16),
                          Text(
                            'No notifications yet',
                            style: GoogleFonts.inter(
                              color: AppColors.of(context).textSecondary,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      itemCount: _notifications.length + 1, // +1 for bottom padding
                      itemBuilder: (context, index) {
                        if (index == _notifications.length) {
                          return const SizedBox(height: 80); // padding for bottom nav
                        }
                        
                        final notification = _notifications[index];
                        return _buildNotificationTile(notification, index);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationTile(NotificationModel notification, int index) {
    return GestureDetector(
      onTap: () => _markAsRead(index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: notification.isRead 
              ? AppColors.of(context).surfaceLight.withOpacity(0.2) 
              : AppColors.of(context).primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notification.isRead 
                ? AppColors.of(context).glassBorder 
                : AppColors.of(context).primary.withOpacity(0.3),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon or Avatar
            _buildNotificationIcon(notification),
            const SizedBox(width: 16),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: GoogleFonts.inter(
                            color: AppColors.of(context).textPrimary,
                            fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Text(
                        notification.timeAgo,
                        style: GoogleFonts.inter(
                          color: AppColors.of(context).textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notification.message,
                    style: GoogleFonts.inter(
                      color: AppColors.of(context).textSecondary,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            
            // Unread dot indicator
            if (!notification.isRead) ...[
              const SizedBox(width: 8),
              Container(
                margin: const EdgeInsets.only(top: 6),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.of(context).primary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(NotificationModel notification) {
    // If it has an avatar, show it with a small type badge
    if (notification.avatarUrl != null) {
      return Stack(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage(notification.avatarUrl!),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.of(context).background,
                shape: BoxShape.circle,
              ),
              child: _getTypeIcon(notification.type, size: 12),
            ),
          ),
        ],
      );
    }
    
    // Otherwise just show the type icon in a circle
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.of(context).surfaceLight.withOpacity(0.5),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: _getTypeIcon(notification.type, size: 24),
      ),
    );
  }

  Widget _getTypeIcon(NotificationType type, {required double size}) {
    switch (type) {
      case NotificationType.like:
        return Icon(Icons.favorite, color: Colors.pinkAccent, size: size);
      case NotificationType.comment:
        return Icon(Icons.chat_bubble, color: Colors.blueAccent, size: size);
      case NotificationType.follow:
        return Icon(Icons.person_add, color: AppColors.of(context).primary, size: size);
      case NotificationType.system:
        return Icon(Icons.info, color: Colors.amber, size: size);
    }
  }
}
