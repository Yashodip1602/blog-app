import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../utils/mock_data.dart';
import '../models/user_model.dart';
import '../models/post_model.dart';
import '../widgets/blog_card.dart';
import 'author_profile_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<UserModel> _matchedAuthors = [];
  List<PostModel> _matchedPosts = [];

  void _onSearchChanged(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _matchedAuthors = [];
        _matchedPosts = [];
      });
      return;
    }

    final lowerQuery = query.toLowerCase();

    setState(() {
      _matchedAuthors = MockDatabase.users
          .where((user) => user.fullName.toLowerCase().contains(lowerQuery))
          .toList();

      _matchedPosts = MockDatabase.posts
          .where((post) =>
              post.title.toLowerCase().contains(lowerQuery) ||
              post.description.toLowerCase().contains(lowerQuery) ||
              post.author.fullName.toLowerCase().contains(lowerQuery))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      body: SafeArea(
        child: Column(
          children: [
            // Header & Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Search',
                    style: GoogleFonts.inter(
                      color: AppColors.of(context).textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.of(context).surfaceLight.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.of(context).glassBorder),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      autofocus: true,
                      style: GoogleFonts.inter(color: AppColors.of(context).textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Search blogs, authors, or topics...',
                        hintStyle: GoogleFonts.inter(color: AppColors.of(context).textHint),
                        prefixIcon: Icon(Icons.search, color: AppColors.of(context).textSecondary),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear, color: AppColors.of(context).textSecondary),
                                onPressed: () {
                                  _searchController.clear();
                                  _onSearchChanged('');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Search Results
            Expanded(
              child: _buildBody(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_searchController.text.trim().isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: AppColors.of(context).textSecondary.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              'Start typing to search',
              style: GoogleFonts.inter(
                color: AppColors.of(context).textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    if (_matchedAuthors.isEmpty && _matchedPosts.isEmpty) {
      return Center(
        child: Text(
          'No results found',
          style: GoogleFonts.inter(
            color: AppColors.of(context).textSecondary,
            fontSize: 16,
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      children: [
        if (_matchedAuthors.isNotEmpty) ...[
          _buildSectionHeader('Authors'),
          ..._matchedAuthors.map((author) => _buildAuthorTile(author)),
          const SizedBox(height: 16),
        ],
        
        if (_matchedPosts.isNotEmpty) ...[
          _buildSectionHeader('Posts'),
          ..._matchedPosts.map((post) => BlogCard(
            authorName: post.author.fullName,
            authorAvatarUrl: post.author.profilePhotoUrl,
            publishedDate: post.publishedDate,
            coverImageUrl: post.coverImageUrl,
            title: post.title,
            description: post.description,
            readingTime: post.readingTime,
            likesCount: post.likesCount,
            commentsCount: post.commentsCount,
          )),
        ],
        
        const SizedBox(height: 80), // Padding for bottom nav
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: GoogleFonts.inter(
          color: AppColors.of(context).textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAuthorTile(UserModel author) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AuthorProfileScreen(
              authorName: author.fullName,
              authorAvatarUrl: author.profilePhotoUrl,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: AppColors.of(context).surfaceLight.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.of(context).glassBorder),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage(author.profilePhotoUrl),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    author.fullName,
                    style: GoogleFonts.inter(
                      color: AppColors.of(context).textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${author.role.name[0].toUpperCase()}${author.role.name.substring(1)}',
                    style: GoogleFonts.inter(
                      color: AppColors.of(context).primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.of(context).textSecondary),
          ],
        ),
      ),
    );
  }
}
