import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import 'author_profile_screen.dart';

class CommentModel {
  final String id;
  final String name;
  final String avatarUrl;
  final String text;
  final String time;
  final bool isAuthor;
  int likes;
  bool isLiked;
  final List<CommentModel> replies;

  CommentModel({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.text,
    required this.time,
    this.isAuthor = false,
    this.likes = 0,
    this.isLiked = false,
    List<CommentModel>? replies,
  }) : replies = replies ?? [];
}

class BlogDetailsScreen extends StatefulWidget {
  final String authorName;
  final String authorAvatarUrl;
  final String publishedDate;
  final String coverImageUrl;
  final String title;
  final String readingTime;

  const BlogDetailsScreen({
    super.key,
    required this.authorName,
    required this.authorAvatarUrl,
    required this.publishedDate,
    required this.coverImageUrl,
    required this.title,
    required this.readingTime,
  });

  @override
  State<BlogDetailsScreen> createState() => _BlogDetailsScreenState();
}

class _BlogDetailsScreenState extends State<BlogDetailsScreen> {
  bool _isLoading = true;
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocus = FocusNode();
  bool _isCommentButtonEnabled = false;

  String? _replyingToCommentId;
  final TextEditingController _replyController = TextEditingController();
  bool _isReplyButtonEnabled = false;

  final String _currentUserAvatar = 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&q=80&w=150&h=150';
  final String _currentUserName = 'Yashodip Mahajan';

  List<CommentModel> _comments = [];

  @override
  void initState() {
    super.initState();
    _commentController.addListener(() {
      setState(() {
        _isCommentButtonEnabled = _commentController.text.trim().isNotEmpty;
      });
    });
    _replyController.addListener(() {
      setState(() {
        _isReplyButtonEnabled = _replyController.text.trim().isNotEmpty;
      });
    });

    // Simulate network load & load initial comments
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _comments = [
            CommentModel(
              id: '1',
              name: 'Sarah Jenkins',
              avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
              text: 'This is an incredibly insightful article! The code snippet for the glassmorphism effect is exactly what I needed.',
              time: '2 hours ago',
              likes: 12,
              replies: [
                CommentModel(
                  id: '1-1',
                  name: widget.authorName,
                  avatarUrl: widget.authorAvatarUrl,
                  text: 'Thank you Sarah! I\'m glad you found it helpful. Let me know if you run into any performance issues with the blur filter.',
                  time: '1 hour ago',
                  isAuthor: true,
                  likes: 5,
                ),
              ],
            ),
          ];
        });
      }
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _replyController.dispose();
    _commentFocus.dispose();
    super.dispose();
  }

  void _postComment() {
    if (_commentController.text.trim().isEmpty) return;
    setState(() {
      _comments.insert(0, CommentModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _currentUserName,
        avatarUrl: _currentUserAvatar,
        text: _commentController.text.trim(),
        time: 'Just now',
      ));
      _commentController.clear();
      FocusScope.of(context).unfocus();
    });
  }

  void _postReply(String parentId) {
    if (_replyController.text.trim().isEmpty) return;
    
    setState(() {
      for (var comment in _comments) {
        if (comment.id == parentId) {
          comment.replies.add(CommentModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: _currentUserName,
            avatarUrl: _currentUserAvatar,
            text: _replyController.text.trim(),
            time: 'Just now',
            // if we want to test author badge on new replies, set isAuthor based on name match
            isAuthor: _currentUserName == widget.authorName,
          ));
          break;
        }
      }
      _replyingToCommentId = null;
      _replyController.clear();
      FocusScope.of(context).unfocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: _isLoading ? _buildShimmerLoading() : _buildContent(),
          ),
        ],
      ),
      bottomNavigationBar: _isLoading ? null : _buildMainCommentInputBox(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 250.0,
      pinned: true,
      backgroundColor: AppColors.of(context).background.withOpacity(0.9),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(icon: const Icon(Icons.bookmark_border, color: Colors.white), onPressed: () {}),
        IconButton(icon: const Icon(Icons.share_outlined, color: Colors.white), onPressed: () {}),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Hero(
          tag: widget.coverImageUrl,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                widget.coverImageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(color: AppColors.of(context).surface),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.6),
                      Colors.transparent,
                      AppColors.of(context).background,
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 24,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.of(context).primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Technology',
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _shimmerBox(height: 32, width: double.infinity),
          const SizedBox(height: 8),
          _shimmerBox(height: 32, width: 200),
          const SizedBox(height: 24),
          Row(
            children: [
              _shimmerBox(height: 48, width: 48, shape: BoxShape.circle),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _shimmerBox(height: 16, width: 120),
                  const SizedBox(height: 8),
                  _shimmerBox(height: 12, width: 80),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          _shimmerBox(height: 16, width: double.infinity),
          const SizedBox(height: 8),
          _shimmerBox(height: 16, width: double.infinity),
          const SizedBox(height: 8),
          _shimmerBox(height: 16, width: 300),
        ],
      ).animate(onPlay: (controller) => controller.repeat()).shimmer(duration: 1200.ms, color: Colors.white24),
    );
  }

  Widget _shimmerBox({required double height, required double width, BoxShape shape = BoxShape.rectangle}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: AppColors.of(context).surfaceLight,
        shape: shape,
        borderRadius: shape == BoxShape.rectangle ? BorderRadius.circular(8) : null,
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: GoogleFonts.inter(
              color: AppColors.of(context).textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ).animate().fadeIn(duration: 500.ms),
          
          const SizedBox(height: 24),
          
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AuthorProfileScreen(
                    authorName: widget.authorName,
                    authorAvatarUrl: widget.authorAvatarUrl,
                  ),
                ),
              );
            },
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(widget.authorAvatarUrl),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.authorName,
                      style: GoogleFonts.inter(color: AppColors.of(context).textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      '${widget.publishedDate} • ${widget.readingTime}',
                      style: GoogleFonts.inter(color: AppColors.of(context).textSecondary, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(delay: 100.ms),
          
          const SizedBox(height: 32),
          
          _buildParagraph('Flutter is Google’s UI toolkit for building beautiful, natively compiled applications for mobile, web, and desktop from a single codebase. In 2026, the ecosystem has matured dramatically.'),
          _buildHeading('Why Glassmorphism Still Rules'),
          _buildParagraph('Despite changing trends, the layered, frosted-glass effect remains a staple for premium SaaS and professional platforms. It provides depth without clutter.'),
          _buildQuoteBlock('Design is not just what it looks like and feels like. Design is how it works. — Steve Jobs'),
          _buildParagraph('Implementing it in Flutter is as easy as using BackdropFilter paired with a semi-transparent container.'),
          _buildCodeBlock('ClipRRect(\n  borderRadius: BorderRadius.circular(20),\n  child: BackdropFilter(\n    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),\n    child: Container(color: Colors.white.withOpacity(0.1)),\n  ),\n);'),
          _buildHeading('Key Takeaways'),
          _buildBulletPoint('Animations should be subtle and meaningful.'),
          _buildBulletPoint('Dark mode requires precise contrast ratios.'),
          _buildBulletPoint('Typography scales the premium feel.'),
          
          const SizedBox(height: 32),
          Divider(color: AppColors.of(context).glassBorder),
          
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildEngagementIcon(Icons.favorite, '2.4k', Colors.redAccent),
                    const SizedBox(width: 24),
                    _buildEngagementIcon(Icons.chat_bubble_outline, _comments.length.toString(), AppColors.of(context).textSecondary),
                  ],
                ),
                Row(
                  children: [
                    _buildEngagementIcon(Icons.bookmark_border, '', AppColors.of(context).textSecondary),
                    const SizedBox(width: 16),
                    _buildEngagementIcon(Icons.share_outlined, '', AppColors.of(context).textSecondary),
                  ],
                ),
              ],
            ),
          ),
          
          Divider(color: AppColors.of(context).glassBorder),
          const SizedBox(height: 32),
          
          // Comments Section Header
          Text(
            'Comments (${_comments.length})',
            style: GoogleFonts.inter(color: AppColors.of(context).textPrimary, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          
          // Comments List
          if (_comments.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  'Be the first to comment.',
                  style: GoogleFonts.inter(color: AppColors.of(context).textSecondary, fontSize: 16),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _comments.length,
              itemBuilder: (context, index) {
                return _buildCommentThread(_comments[index]);
              },
            ),
            
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        text,
        style: GoogleFonts.inter(color: AppColors.of(context).textSecondary, fontSize: 16, height: 1.6),
      ),
    );
  }

  Widget _buildHeading(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 12.0),
      child: Text(
        text,
        style: GoogleFonts.inter(color: AppColors.of(context).textPrimary, fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(color: AppColors.of(context).primary, fontSize: 20, height: 1.2)),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(color: AppColors.of(context).textSecondary, fontSize: 16, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuoteBlock(String text) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: AppColors.of(context).primary, width: 4)),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(color: AppColors.of(context).textPrimary, fontSize: 18, fontStyle: FontStyle.italic, height: 1.5),
      ),
    );
  }

  Widget _buildCodeBlock(String code) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1117),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.of(context).glassBorder),
      ),
      child: Text(
        code,
        style: GoogleFonts.jetBrainsMono(color: const Color(0xFFE6EDF3), fontSize: 14, height: 1.5),
      ),
    );
  }

  Widget _buildEngagementIcon(IconData icon, String count, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        if (count.isNotEmpty) ...[
          const SizedBox(width: 8),
          Text(count, style: GoogleFonts.inter(color: AppColors.of(context).textSecondary, fontSize: 16, fontWeight: FontWeight.w600)),
        ]
      ],
    );
  }

  Widget _buildCommentThread(CommentModel comment) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCommentCard(comment, isReply: false),
        if (_replyingToCommentId == comment.id)
          _buildReplyInputBox(comment.id),
        if (comment.replies.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 48.0, top: 8.0),
            child: Column(
              children: comment.replies.map((reply) => _buildCommentCard(reply, isReply: true)).toList(),
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCommentCard(CommentModel comment, {required bool isReply}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isReply ? AppColors.of(context).surfaceLight.withOpacity(0.3) : AppColors.of(context).surfaceLight.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.of(context).glassBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: isReply ? 16 : 20,
            backgroundImage: NetworkImage(comment.avatarUrl),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.name,
                      style: GoogleFonts.inter(color: AppColors.of(context).textPrimary, fontWeight: FontWeight.bold, fontSize: isReply ? 14 : 15),
                    ),
                    if (comment.isAuthor) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.of(context).primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.of(context).primary),
                        ),
                        child: Text('Author', style: GoogleFonts.inter(color: AppColors.of(context).primary, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                    const Spacer(),
                    Text(
                      comment.time,
                      style: GoogleFonts.inter(color: AppColors.of(context).textHint, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  comment.text,
                  style: GoogleFonts.inter(color: AppColors.of(context).textSecondary, fontSize: 14, height: 1.5),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          comment.isLiked = !comment.isLiked;
                          comment.likes += comment.isLiked ? 1 : -1;
                        });
                      },
                      child: Row(
                        children: [
                          Icon(
                            comment.isLiked ? Icons.favorite : Icons.favorite_border,
                            color: comment.isLiked ? Colors.redAccent : AppColors.of(context).textSecondary,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${comment.likes}',
                            style: GoogleFonts.inter(color: AppColors.of(context).textSecondary, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    if (!isReply)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            if (_replyingToCommentId == comment.id) {
                              _replyingToCommentId = null;
                            } else {
                              _replyingToCommentId = comment.id;
                            }
                          });
                        },
                        child: Text(
                          'Reply',
                          style: GoogleFonts.inter(color: AppColors.of(context).primary, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildReplyInputBox(String parentId) {
    return Padding(
      padding: const EdgeInsets.only(left: 48.0, bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.of(context).background,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.of(context).primary.withOpacity(0.5)),
              ),
              child: TextField(
                controller: _replyController,
                style: GoogleFonts.inter(color: AppColors.of(context).textPrimary, fontSize: 14),
                minLines: 1,
                maxLines: 3,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Write a reply...',
                  hintStyle: GoogleFonts.inter(color: AppColors.of(context).textHint, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: _isReplyButtonEnabled ? AppColors.of(context).primary : AppColors.of(context).surfaceLight,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.send, color: _isReplyButtonEnabled ? Colors.white : AppColors.of(context).textSecondary, size: 20),
              onPressed: _isReplyButtonEnabled ? () => _postReply(parentId) : null,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildMainCommentInputBox() {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + max(16.0, MediaQuery.of(context).padding.bottom),
      ),
      decoration: BoxDecoration(
        color: AppColors.of(context).surface,
        border: Border(top: BorderSide(color: AppColors.of(context).glassBorder)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage('https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.of(context).background,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.of(context).glassBorder),
              ),
              child: TextField(
                controller: _commentController,
                focusNode: _commentFocus,
                style: GoogleFonts.inter(color: AppColors.of(context).textPrimary, fontSize: 14),
                minLines: 1,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Write your comment...',
                  hintStyle: GoogleFonts.inter(color: AppColors.of(context).textHint, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: InkWell(
              onTap: _isCommentButtonEnabled ? _postComment : null,
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  gradient: _isCommentButtonEnabled ? AppColors.of(context).primaryGradient : null,
                  color: _isCommentButtonEnabled ? null : AppColors.of(context).surfaceLight,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  'Post',
                  style: GoogleFonts.inter(
                    color: _isCommentButtonEnabled ? Colors.white : AppColors.of(context).textHint,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double max(double a, double b) => a > b ? a : b;
}
