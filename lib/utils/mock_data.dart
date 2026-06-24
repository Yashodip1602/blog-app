import '../models/user_model.dart';
import '../models/post_model.dart';
import '../models/notification_model.dart';

class MockDatabase {
  static List<UserModel> users = [
    UserModel(
      id: '1',
      fullName: 'Yashodip Jejurkar',
      email: 'yashodip@example.com',
      phone: '+1 234 567 8900',
      profilePhotoUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=300',
      role: UserRole.superAdmin,
      status: UserStatus.active,
    ),
    UserModel(
      id: '2',
      fullName: 'Rohan More',
      email: 'rohan@gmail.com',
      phone: '+91 9876543210',
      profilePhotoUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=300',
      role: UserRole.admin,
      status: UserStatus.active,
    ),
    UserModel(
      id: '3',
      fullName: 'Michael Chen',
      email: 'mike.chen@example.com',
      phone: '+1 555 123 4567',
      profilePhotoUrl: 'https://images.unsplash.com/photo-1599566150163-29194dcaad36?w=300',
      role: UserRole.user,
      status: UserStatus.active,
    ),
    UserModel(
      id: '4',
      fullName: 'Emma Watson',
      email: 'emma.w@example.com',
      phone: '+1 444 987 6543',
      profilePhotoUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=300',
      role: UserRole.user,
      status: UserStatus.pending,
    ),
  ];

  static List<PostModel> get posts => [
    PostModel(
      id: 'p1',
      title: 'The Future of Flutter: What to Expect in 2026',
      description: 'Explore the upcoming features, performance improvements, and new architectural patterns that will define the Flutter ecosystem.',
      coverImageUrl: 'https://images.unsplash.com/photo-1555066931-4365d14bab8c?auto=format&fit=crop&q=80&w=800&h=450',
      publishedDate: 'Jun 20, 2026',
      readingTime: '5 min read',
      likesCount: '1.2k',
      commentsCount: '84',
      author: users[0],
    ),
    PostModel(
      id: 'p2',
      title: 'Mastering Glassmorphism in Flutter',
      description: 'A deep dive into creating stunning frosted-glass UI effects that look premium on every screen.',
      coverImageUrl: 'https://images.unsplash.com/photo-1561736778-92e52a7769ef?auto=format&fit=crop&q=80&w=800&h=450',
      publishedDate: 'Jun 18, 2026',
      readingTime: '7 min read',
      likesCount: '980',
      commentsCount: '62',
      author: users[1],
    ),
    PostModel(
      id: 'p3',
      title: 'Dark Mode Design Principles Every Dev Should Know',
      description: 'Learn the fundamentals of building beautiful dark themes with proper contrast, color theory, and accessibility.',
      coverImageUrl: 'https://images.unsplash.com/photo-1504639725590-34d0984388bd?auto=format&fit=crop&q=80&w=800&h=450',
      publishedDate: 'Jun 15, 2026',
      readingTime: '4 min read',
      likesCount: '2.4k',
      commentsCount: '130',
      author: users[2],
    ),
    PostModel(
      id: 'p4',
      title: 'State Management in 2026: Which One Should You Pick?',
      description: 'A comparative study of Riverpod, BLoC, Provider, and the new Flutter-native state solutions.',
      coverImageUrl: 'https://images.unsplash.com/photo-1518770660439-4636190af475?auto=format&fit=crop&q=80&w=800&h=450',
      publishedDate: 'Jun 10, 2026',
      readingTime: '10 min read',
      likesCount: '3.1k',
      commentsCount: '215',
      author: users[3],
    ),
    PostModel(
      id: 'p5',
      title: 'Building Scalable APIs with Dart & Shelf',
      description: 'How to create robust, production-ready backend services entirely in Dart using the Shelf package.',
      coverImageUrl: 'https://images.unsplash.com/photo-1516116216624-53e697fedbea?auto=format&fit=crop&q=80&w=800&h=450',
      publishedDate: 'Jun 5, 2026',
      readingTime: '8 min read',
      likesCount: '760',
      commentsCount: '45',
      author: users[0],
    ),
  ];

  static List<NotificationModel> notifications = [
    NotificationModel(
      id: 'n1',
      title: 'Rohan More liked your post',
      message: 'Rohan More liked "The Future of Flutter: What to Expect in 2026"',
      timeAgo: '2m ago',
      type: NotificationType.like,
      avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=300',
      isRead: false,
      relatedUser: users[1],
      relatedPost: posts[0],
    ),
    NotificationModel(
      id: 'n2',
      title: 'Michael Chen commented on your post',
      message: 'Michael Chen: "Great article! Really helped me understand the new architecture."',
      timeAgo: '15m ago',
      type: NotificationType.comment,
      avatarUrl: 'https://images.unsplash.com/photo-1599566150163-29194dcaad36?w=300',
      isRead: false,
      relatedUser: users[2],
      relatedPost: posts[0],
    ),
    NotificationModel(
      id: 'n3',
      title: 'Emma Watson started following you',
      message: 'Emma Watson is now following you. They will see your new posts.',
      timeAgo: '1h ago',
      type: NotificationType.follow,
      avatarUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=300',
      isRead: false,
      relatedUser: users[3],
    ),
    NotificationModel(
      id: 'n4',
      title: 'New feature available',
      message: 'BlogSphere just launched a new AI-powered writing assistant. Try it now!',
      timeAgo: '3h ago',
      type: NotificationType.system,
      isRead: true,
    ),
    NotificationModel(
      id: 'n5',
      title: 'Rohan More commented on your post',
      message: 'Rohan More: "This is exactly what I was looking for. Thanks for sharing!"',
      timeAgo: '1d ago',
      type: NotificationType.comment,
      avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=300',
      isRead: true,
      relatedUser: users[1],
      relatedPost: posts[1],
    ),
  ];

  static List<RoleRequestModel> roleRequests = [
    RoleRequestModel(
      id: 'req_1',
      user: users[2], // Michael Chen
      requestedRole: UserRole.author,
      requestedBy: 'Michael Chen',
      reason: 'I want to start publishing tech blogs.',
      status: RoleRequestStatus.pendingAdmin,
      requestedDate: DateTime.now().subtract(const Duration(hours: 2)),
    )
  ];
}
