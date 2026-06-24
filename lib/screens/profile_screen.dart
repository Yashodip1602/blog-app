import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_container.dart';
import '../models/user_model.dart';
import 'login_screen.dart';
import 'user_management_screen.dart';
import 'author_role_request_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserRole currentUserRole = UserRole.user; // Mock role to test Author Request flow as a normal user
  String _userName = 'Yashodip Mahajan';
  String _userEmail = 'user@example.com';
  String _userHandle = '@yashodip';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('demoUserName') ?? 'Yashodip Mahajan';
      _userEmail = prefs.getString('demoUserEmail') ?? 'user@example.com';
      _userHandle = '@${_userName.toLowerCase().replaceAll(' ', '')}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Background handled by Dashboard
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            children: [
              // Header
              Center(
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.of(context).primary.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage('https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&q=80&w=300&h=300'),
                      ),
                    ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack),
                    
                    const SizedBox(height: 16),
                    
                    Text(
                      _userName,
                      style: GoogleFonts.inter(
                        color: AppColors.of(context).textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ).animate().fadeIn(delay: 100.ms, duration: 600.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuart),
                    
                    const SizedBox(height: 4),
                    
                    Text(
                      _userHandle,
                      style: GoogleFonts.inter(
                        color: AppColors.of(context).primary,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ).animate().fadeIn(delay: 150.ms, duration: 600.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuart),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      _userEmail,
                      style: GoogleFonts.inter(
                        color: AppColors.of(context).textSecondary,
                        fontSize: 14,
                      ),
                    ).animate().fadeIn(delay: 160.ms, duration: 600.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuart),
                    
                    const SizedBox(height: 4),
                    
                    Text(
                      '+1 234 567 8900',
                      style: GoogleFonts.inter(
                        color: AppColors.of(context).textSecondary,
                        fontSize: 14,
                      ),
                    ).animate().fadeIn(delay: 170.ms, duration: 600.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuart),
                    
                    const SizedBox(height: 16),
                    
                    Text(
                      'Passionate Flutter developer, UI/UX enthusiast, and tech writer. Creating beautiful cross-platform experiences.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: AppColors.of(context).textSecondary,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuart),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      'Joined June 2026',
                      style: GoogleFonts.inter(
                        color: AppColors.of(context).textHint,
                        fontSize: 12,
                      ),
                    ).animate().fadeIn(delay: 250.ms, duration: 600.ms),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Stats Cards
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatItem('12', 'Blogs Published'),
                  _buildStatItem('128', 'Bookmarks'),
                  _buildStatItem('15k', 'Total Likes'),
                ],
              ).animate().fadeIn(delay: 300.ms, duration: 600.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuart),
              
              const SizedBox(height: 32),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: AppColors.of(context).primaryGradient,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.of(context).primary.withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: 1,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: () {},
                          child: Center(
                            child: Text(
                              'Edit Profile',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 400.ms, duration: 600.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuart),
              
              const SizedBox(height: 40),
              
              // Menu Options
              GlassContainer(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    _buildMenuItem(Icons.article_outlined, 'My Blogs'),
                    Divider(color: AppColors.of(context).glassBorder, height: 1),
                    _buildMenuItem(Icons.bookmark_border, 'Bookmarks'),
                    Divider(color: AppColors.of(context).glassBorder, height: 1),
                    _buildMenuItem(Icons.notifications_none_outlined, 'Notifications'),
                    Divider(color: AppColors.of(context).glassBorder, height: 1),
                    _buildMenuItem(
                      Icons.settings_outlined, 
                      'Settings',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingsScreen(),
                          ),
                        );
                      },
                    ),
                    Divider(color: AppColors.of(context).glassBorder, height: 1),
                    _buildMenuItem(Icons.lock_outline, 'Privacy & Security'),
                    Divider(color: AppColors.of(context).glassBorder, height: 1),
                    _buildMenuItem(Icons.help_outline, 'Help & Support'),
                    Divider(color: AppColors.of(context).glassBorder, height: 1),
                    if (currentUserRole != UserRole.user) ...[
                      _buildMenuItem(
                        Icons.group_outlined,
                        'User Management',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const UserManagementScreen(),
                            ),
                          );
                        },
                      ),
                      Divider(color: AppColors.of(context).glassBorder, height: 1),
                    ],
                    _buildMenuItem(
                      Icons.person_add_alt_1,
                      'Author Role Request',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AuthorRoleRequestScreen(),
                          ),
                        );
                      },
                    ),
                    Divider(color: AppColors.of(context).glassBorder, height: 1),
                    _buildMenuItem(Icons.logout, 'Logout', color: Colors.redAccent, onTap: () => _showLogoutDialog(context)),
                  ],
                ),
              ).animate().fadeIn(delay: 500.ms, duration: 600.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuart),
              
              const SizedBox(height: 100), // FAB spacing
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Column(
      children: [
        Text(
          count,
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
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {Color? color, VoidCallback? onTap}) {
    final effectiveColor = color ?? AppColors.of(context).textPrimary;
    return ListTile(
      leading: Icon(icon, color: effectiveColor == AppColors.of(context).textPrimary ? AppColors.of(context).textSecondary : effectiveColor),
      title: Text(
        title,
        style: GoogleFonts.inter(
          color: effectiveColor,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: AppColors.of(context).textSecondary),
      onTap: onTap ?? () {},
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.of(context).surfaceLight,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Logout',
            style: GoogleFonts.inter(color: AppColors.of(context).textPrimary, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: GoogleFonts.inter(color: AppColors.of(context).textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.of(context).textSecondary)),
            ),
            TextButton(
              onPressed: () {
                // Mock clearing token
                Navigator.pop(context); // close dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Logged out successfully.', style: GoogleFonts.inter(color: Colors.white)),
                    backgroundColor: Colors.redAccent,
                  ),
                );
                // Redirect to login
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
              child: Text('Logout', style: GoogleFonts.inter(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
