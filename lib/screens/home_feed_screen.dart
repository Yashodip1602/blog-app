import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../widgets/blog_card.dart';

class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  String _userName = 'Yashodip'; // Default

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('demoUserName') ?? 'Yashodip';
    });
  }

  final List<String> _filters = [
    'Technology', 'Programming', 'DevOps', 'AI', 'Business', 'Travel', 'Lifestyle'
  ];
  String _selectedFilter = 'Technology';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Background handled by Dashboard
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 24,
                        backgroundImage: NetworkImage('https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&q=80&w=150&h=150'),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Good Morning, $_userName 👋',
                            style: GoogleFonts.inter(
                              color: AppColors.of(context).textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            "Discover today's stories.",
                            style: GoogleFonts.inter(
                              color: AppColors.of(context).textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Stack(
                    children: [
                      IconButton(
                        icon: Icon(Icons.notifications_none_outlined, color: AppColors.of(context).textPrimary, size: 28),
                        onPressed: () {},
                      ),
                      Positioned(
                        right: 12,
                        top: 12,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.1, end: 0, curve: Curves.easeOutQuart),
            


            
            // Filter Chips
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                itemCount: _filters.length,
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  final isSelected = filter == _selectedFilter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      },
                      labelStyle: GoogleFonts.inter(
                        color: isSelected ? Colors.white : AppColors.of(context).textSecondary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                      selectedColor: AppColors.of(context).primary,
                      backgroundColor: AppColors.of(context).surfaceLight,
                      side: BorderSide(
                        color: isSelected ? AppColors.of(context).primary : AppColors.of(context).glassBorder,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  );
                },
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideX(begin: 0.1, end: 0, curve: Curves.easeOutQuart),
            
            const SizedBox(height: 24),
            
            // Blog Feed
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                children: [
                  const BlogCard(
                    authorName: 'Alex Rivero',
                    authorAvatarUrl: 'https://images.unsplash.com/photo-1599566150163-29194dcaad36?auto=format&fit=crop&q=80&w=150&h=150',
                    publishedDate: '2 hours ago',
                    coverImageUrl: 'https://images.unsplash.com/photo-1555066931-4365d14bab8c?auto=format&fit=crop&q=80&w=800&h=450',
                    title: 'The Future of Flutter: What to Expect in 2026',
                    description: 'Explore the upcoming features, performance improvements, and new architectural patterns that will define the next era of Flutter development.',
                    readingTime: '5 min read',
                    likesCount: '1.2k',
                    commentsCount: '84',
                  ).animate().fadeIn(delay: 300.ms, duration: 600.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuart),
                  
                  const BlogCard(
                    authorName: 'Sarah Jenkins',
                    authorAvatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=150&h=150',
                    publishedDate: '5 hours ago',
                    coverImageUrl: 'https://images.unsplash.com/photo-1518770660439-4636190af475?auto=format&fit=crop&q=80&w=800&h=450',
                    title: 'Designing with Glassmorphism in Modern UI',
                    description: 'A comprehensive guide to creating stunning glassmorphism interfaces that look premium, accessible, and performant on mobile devices.',
                    readingTime: '8 min read',
                    likesCount: '3.4k',
                    commentsCount: '156',
                  ).animate().fadeIn(delay: 400.ms, duration: 600.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuart),
                  
                  const SizedBox(height: 80), // padding for FAB and bottom nav
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
