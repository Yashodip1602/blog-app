import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import 'glass_container.dart';
import '../screens/blog_details_screen.dart';


class BlogCard extends StatelessWidget {
  final String authorName;
  final String authorAvatarUrl;
  final String publishedDate;
  final String coverImageUrl;
  final String title;
  final String description;
  final String readingTime;
  final String likesCount;
  final String commentsCount;

  const BlogCard({
    super.key,
    required this.authorName,
    required this.authorAvatarUrl,
    required this.publishedDate,
    required this.coverImageUrl,
    required this.title,
    required this.description,
    required this.readingTime,
    required this.likesCount,
    required this.commentsCount,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 600),
            pageBuilder: (context, animation, secondaryAnimation) {
              return FadeTransition(
                opacity: animation,
                child: BlogDetailsScreen(
                  authorName: authorName,
                  authorAvatarUrl: authorAvatarUrl,
                  publishedDate: publishedDate,
                  coverImageUrl: coverImageUrl,
                  title: title,
                  readingTime: readingTime,
                ),
              );
            },
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24.0),
        child: GlassContainer(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Section
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(authorAvatarUrl),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        authorName,
                        style: GoogleFonts.inter(
                          color: AppColors.of(context).textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        publishedDate,
                        style: GoogleFonts.inter(
                          color: AppColors.of(context).textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.more_horiz, color: AppColors.of(context).textSecondary),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Middle Section
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Hero(
                  tag: coverImageUrl,
                  child: Image.network(
                    coverImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.of(context).surfaceLight,
                      child: Icon(Icons.image_not_supported, color: AppColors.of(context).textSecondary),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            Text(
              title,
              style: GoogleFonts.inter(
                color: AppColors.of(context).textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: GoogleFonts.inter(
                color: AppColors.of(context).textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Text(
              readingTime,
              style: GoogleFonts.inter(
                color: AppColors.of(context).primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 16),
            Divider(color: AppColors.of(context).glassBorder),
            const SizedBox(height: 8),
            
            // Bottom Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildIconStat(context, Icons.favorite_border, likesCount),
                    const SizedBox(width: 24),
                    _buildIconStat(context, Icons.chat_bubble_outline, commentsCount),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.bookmark_border, color: AppColors.of(context).textSecondary, size: 22),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Icon(Icons.share_outlined, color: AppColors.of(context).textSecondary, size: 22),
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildIconStat(BuildContext context, IconData icon, String count) {
    return Row(
      children: [
        Icon(icon, color: AppColors.of(context).textSecondary, size: 22),
        const SizedBox(width: 6),
        Text(
          count,
          style: GoogleFonts.inter(
            color: AppColors.of(context).textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
