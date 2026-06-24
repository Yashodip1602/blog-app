import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';
import 'home_feed_screen.dart';
import 'search_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'create_post_screen.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  final bool _isAuthor = true; // Toggle this to test Author vs Viewer roles

  final List<Widget> _screens = [
    const HomeFeedScreen(),
    const SearchScreen(),
    const NotificationsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.of(context).backgroundGradient,
        ),
        child: IndexedStack(
          index: _getScreenIndex(),
          children: _screens,
        ),
      ),

      extendBody: true,
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  int _getScreenIndex() {
    if (_isAuthor) {
      // If author, index 2 is Create Blog (which doesn't map to IndexedStack directly)
      // So we map it based on logic. But let's just map BottomNav index to Screen index.
      if (_currentIndex == 0) return 0;
      if (_currentIndex == 1) return 1;
      if (_currentIndex == 2) return 0; // Create Blog opens modal usually, keep on home
      if (_currentIndex == 3) return 2;
      if (_currentIndex == 4) return 3;
    }
    return _currentIndex;
  }

  Widget _buildBottomNav() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.of(context).glassBackground,
            border: Border(
              top: BorderSide(color: AppColors.of(context).glassBorder, width: 1),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildNavItem(Icons.home_filled, 0),
                  _buildNavItem(Icons.search, 1),
                  if (_isAuthor)
                    _buildNavItem(Icons.add_box_outlined, 2, isSpecial: true),
                  _buildNavItem(Icons.notifications_none_outlined, _isAuthor ? 3 : 2),
                  _buildNavItem(Icons.person_outline, _isAuthor ? 4 : 3),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, {bool isSpecial = false}) {
    final isSelected = _currentIndex == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (isSpecial) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const CreatePostScreen()));
            return;
          }
          setState(() {
            _currentIndex = index;
          });
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: isSelected && !isSpecial
            ? ShaderMask(
                shaderCallback: (Rect bounds) {
                  return AppColors.of(context).primaryGradient.createShader(bounds);
                },
                child: Icon(icon, color: Colors.white, size: 28),
              )
            : Icon(
                icon,
                color: isSpecial ? AppColors.of(context).textPrimary : AppColors.of(context).textSecondary,
                size: 28,
              ),
        ),
      ),
    );
  }
}
