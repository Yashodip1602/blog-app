import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_container.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'user_management_screen.dart';
import 'author_role_request_screen.dart';
import 'settings_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserRole currentUserRole = UserRole.user; // Mock role to test Author Request flow as a normal user
  String _userName = '';
  String _userEmail = '';
  String _userHandle = '';
  String _userPhone = '';
  String _profilePhotoUrl = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final response = await ApiService().getProfile();
      if (response['success'] == true) {
        final data = response['data'];
        
        // Save to local storage
        final prefs = await SharedPreferences.getInstance();
        if (data['full_name'] != null) await prefs.setString('demoUserName', data['full_name']);
        if (data['email'] != null) await prefs.setString('demoUserEmail', data['email']);
        if (data['phone_no'] != null) await prefs.setString('userPhone', data['phone_no']);
        if (data['profile_photo_url'] != null) await prefs.setString('profilePhotoUrl', data['profile_photo_url']);

        setState(() {
          _userName = data['full_name'] ?? _userName;
          _userEmail = data['email'] ?? _userEmail;
          _userPhone = data['phone_no'] ?? _userPhone;
          if (data['profile_photo_url'] != null && data['profile_photo_url'].toString().isNotEmpty) {
            _profilePhotoUrl = data['profile_photo_url'];
          }
          _userHandle = _userName.isNotEmpty ? '@${_userName.toLowerCase().replaceAll(' ', '')}' : '';
        });
      }
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _userName = prefs.getString('demoUserName') ?? '';
        _userEmail = prefs.getString('demoUserEmail') ?? '';
        _userPhone = prefs.getString('userPhone') ?? '';
        _profilePhotoUrl = prefs.getString('profilePhotoUrl') ?? '';
        _userHandle = _userName.isNotEmpty ? '@${_userName.toLowerCase().replaceAll(' ', '')}' : '';
      });
    }
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
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.of(context).surfaceLight,
                        backgroundImage: _profilePhotoUrl.isNotEmpty ? NetworkImage(_profilePhotoUrl) : null,
                        child: _profilePhotoUrl.isEmpty ? Icon(Icons.person, size: 50, color: AppColors.of(context).textSecondary) : null,
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
                      _userPhone,
                      style: GoogleFonts.inter(
                        color: AppColors.of(context).textSecondary,
                        fontSize: 14,
                      ),
                    ).animate().fadeIn(delay: 170.ms, duration: 600.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuart),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Stats Cards
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatItem('120', 'Following'),
                  _buildStatItem('340', 'Followers'),
                  _buildStatItem('12', 'Total Posts'),
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
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EditProfileScreen(),
                              ),
                            );
                            if (result == true) {
                              _loadUserData();
                            }
                          },
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
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                
                // Save remember me data to restore it after clear
                final rememberMe = prefs.getBool('remember_me');
                final savedEmail = prefs.getString('saved_email');
                final savedPassword = prefs.getString('saved_password');
                
                // Clear all local storage
                await prefs.clear();
                await ApiService().removeToken();
                
                // Restore remember me data
                if (rememberMe == true) {
                  await prefs.setBool('remember_me', true);
                  if (savedEmail != null) await prefs.setString('saved_email', savedEmail);
                  if (savedPassword != null) await prefs.setString('saved_password', savedPassword);
                }

                if (context.mounted) {
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
                }
              },
              child: Text('Logout', style: GoogleFonts.inter(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
