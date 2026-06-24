import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../widgets/blog_card.dart';

class AuthorProfileScreen extends StatefulWidget {
  final String authorName;
  final String authorAvatarUrl;
  final int followersCount;

  const AuthorProfileScreen({
    super.key,
    required this.authorName,
    required this.authorAvatarUrl,
    this.followersCount = 0,
  });

  @override
  State<AuthorProfileScreen> createState() => _AuthorProfileScreenState();
}

class _AuthorProfileScreenState extends State<AuthorProfileScreen> {
  bool _isFollowing = false;
  late int _followersCount;

  final int _totalPostsCount = 100;
  final int _itemsPerPage = 10;
  int _currentPage = 1;
  int get _totalPages => (_totalPostsCount / _itemsPerPage).ceil();

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _followersCount = widget.followersCount;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    if (page < 1 || page > _totalPages) return;
    setState(() {
      _currentPage = page;
    });
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        360.0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    }
  }

  void _toggleFollow() {
    setState(() {
      _isFollowing = !_isFollowing;
      _followersCount += _isFollowing ? 1 : -1;
    });

    if (_isFollowing) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'You will now receive notifications for ${widget.authorName}\'s posts.',
          ),
          backgroundColor: AppColors.of(context).primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.of(context).background,
            elevation: 0,
            pinned: true,
            expandedHeight: 360,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: AppColors.of(context).textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: LayoutBuilder(
              builder: (BuildContext ctx, BoxConstraints constraints) {
                final top = constraints.biggest.height;
                final isCollapsed = top <= kToolbarHeight + MediaQuery.of(ctx).padding.top + 20;

                return FlexibleSpaceBar(
                  centerTitle: true,
                  title: isCollapsed
                      ? AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: 1.0,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundImage: NetworkImage(widget.authorAvatarUrl),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                widget.authorName,
                                style: GoogleFonts.inter(
                                  color: AppColors.of(context).textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                  background: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: NetworkImage(widget.authorAvatarUrl),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.authorName,
                            style: GoogleFonts.inter(
                              color: AppColors.of(context).textPrimary,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Follow Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _toggleFollow,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isFollowing
                                    ? AppColors.of(context).surfaceLight
                                    : AppColors.of(context).primary,
                                foregroundColor: _isFollowing
                                    ? AppColors.of(context).textPrimary
                                    : Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: _isFollowing
                                      ? BorderSide(color: AppColors.of(context).glassBorder)
                                      : BorderSide.none,
                                ),
                              ),
                              child: Text(
                                _isFollowing ? 'Following' : 'Follow',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Stats Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildStatColumn(_followersCount.toString(), 'Followers'),
                              Container(
                                height: 40,
                                width: 1,
                                color: AppColors.of(context).glassBorder,
                              ),
                              _buildStatColumn(_totalPostsCount.toString(), 'Posts'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Divider + Latest Posts header
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Divider(color: AppColors.of(context).glassBorder),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Text(
                    'Latest Posts',
                    style: GoogleFonts.inter(
                      color: AppColors.of(context).textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Posts List
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final postIndex = ((_currentPage - 1) * _itemsPerPage) + index;
                  return BlogCard(
                    authorName: widget.authorName,
                    authorAvatarUrl: widget.authorAvatarUrl,
                    publishedDate: '${postIndex + 1} days ago',
                    coverImageUrl:
                        'https://images.unsplash.com/photo-1555066931-4365d14bab8c?auto=format&fit=crop&q=80&w=800&h=450',
                    title: 'Post #${postIndex + 1} by ${widget.authorName}',
                    description:
                        'This is a sample post description showcasing the author\'s work on the profile page.',
                    readingTime: '5 min read',
                    likesCount: '${100 + postIndex * 5}',
                    commentsCount: '${10 + postIndex}',
                  );
                },
                childCount: (_totalPostsCount - ((_currentPage - 1) * _itemsPerPage))
                    .clamp(0, _itemsPerPage),
              ),
            ),
          ),

          // Pagination Controls
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Previous Button
                  IconButton(
                    icon: Icon(Icons.chevron_left,
                        color: _currentPage > 1
                            ? AppColors.of(context).textPrimary
                            : AppColors.of(context).textSecondary),
                    onPressed: _currentPage > 1 ? () => _goToPage(_currentPage - 1) : null,
                  ),

                  // Page numbers
                  ...List.generate(_totalPages, (index) {
                    final pageNumber = index + 1;
                    final isSelected = pageNumber == _currentPage;

                    // Show only nearby pages
                    if (_totalPages > 5 &&
                        pageNumber != 1 &&
                        pageNumber != _totalPages &&
                        (pageNumber < _currentPage - 1 || pageNumber > _currentPage + 1)) {
                      if (pageNumber == _currentPage - 2 || pageNumber == _currentPage + 2) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Text(
                            '...',
                            style: TextStyle(color: AppColors.of(context).textSecondary),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }

                    return GestureDetector(
                      onTap: () => _goToPage(pageNumber),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.of(context).primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.of(context).primary
                                : AppColors.of(context).glassBorder,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          pageNumber.toString(),
                          style: GoogleFonts.inter(
                            color: isSelected
                                ? Colors.white
                                : AppColors.of(context).textPrimary,
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }),

                  // Next Button
                  IconButton(
                    icon: Icon(Icons.chevron_right,
                        color: _currentPage < _totalPages
                            ? AppColors.of(context).textPrimary
                            : AppColors.of(context).textSecondary),
                    onPressed:
                        _currentPage < _totalPages ? () => _goToPage(_currentPage + 1) : null,
                  ),
                ],
              ),
            ),
          ),

          // Bottom padding for nav bar
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            color: AppColors.of(context).textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            color: AppColors.of(context).textSecondary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
