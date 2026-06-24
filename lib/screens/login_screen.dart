import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_container.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'signup_screen.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  bool _rememberMe = false;
  final TextEditingController _emailController = TextEditingController();

  Widget _buildTextField({
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextEditingController? controller,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.of(context).surfaceLight.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.of(context).glassBorder),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && _obscurePassword,
        style: GoogleFonts.inter(color: AppColors.of(context).textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(color: AppColors.of(context).textHint),
          prefixIcon: Icon(icon, color: AppColors.of(context).textSecondary, size: 20),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.of(context).textSecondary,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildSocialButton({required String text, required Widget icon}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.of(context).surfaceLight.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.of(context).glassBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const SizedBox(width: 12),
          Text(
            text,
            style: GoogleFonts.inter(
              color: AppColors.of(context).textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: AppColors.of(context).backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Logo
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.of(context).primaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.of(context).primary.withOpacity(0.4),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.edit_document,
                    color: Colors.white,
                    size: 24,
                  ),
                ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2, end: 0, curve: Curves.easeOutQuart),
                
                const SizedBox(height: 32),
                
                // Welcome Text
                Text(
                  'Welcome Back 👋',
                  style: GoogleFonts.inter(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.of(context).textPrimary,
                    letterSpacing: -1,
                  ),
                ).animate().fadeIn(delay: 100.ms, duration: 600.ms).slideX(begin: -0.1, end: 0, curve: Curves.easeOutQuart),
                
                const SizedBox(height: 8),
                
                Text(
                  'Login to continue reading and sharing amazing stories.',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: AppColors.of(context).textSecondary,
                    height: 1.5,
                  ),
                ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideX(begin: -0.1, end: 0, curve: Curves.easeOutQuart),
                
                const SizedBox(height: 40),
                
                // Form Container
                GlassContainer(
                  child: Column(
                    children: [
                      _buildTextField(
                        hint: 'Enter email or phone number',
                        icon: Icons.email_outlined,
                        controller: _emailController,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        hint: 'Enter your password',
                        icon: Icons.lock_outline,
                        isPassword: true,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Remember me & Forgot Password
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _rememberMe = !_rememberMe;
                                });
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: Checkbox(
                                      value: _rememberMe,
                                      onChanged: (value) {
                                        setState(() {
                                          _rememberMe = value ?? false;
                                        });
                                      },
                                      activeColor: AppColors.of(context).primary,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                      side: BorderSide(color: AppColors.of(context).textSecondary),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      'Remember Me',
                                      style: GoogleFonts.inter(
                                        color: AppColors.of(context).textSecondary,
                                        fontSize: 14,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Forgot Password?',
                              style: GoogleFonts.inter(
                                color: AppColors.of(context).primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Login Button
                      Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: AppColors.of(context).primaryGradient,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.of(context).primary.withOpacity(0.3),
                              blurRadius: 15,
                              spreadRadius: 2,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(28),
                            onTap: () async {
                              final email = _emailController.text.trim();
                              if (email.isNotEmpty && email.contains('@')) {
                                String name = email.split('@').first;
                                // Capitalize first letter for display
                                if (name.isNotEmpty) {
                                  name = name[0].toUpperCase() + name.substring(1);
                                }
                                final prefs = await SharedPreferences.getInstance();
                                await prefs.setString('demoUserName', name);
                                await prefs.setString('demoUserEmail', email);
                              } else if (email.isNotEmpty) {
                                final prefs = await SharedPreferences.getInstance();
                                await prefs.setString('demoUserName', email);
                                await prefs.setString('demoUserEmail', email);
                              }
                              
                              if (mounted) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => const DashboardScreen()),
                                );
                              }
                            },
                            child: Center(
                              child: Text(
                                'Login',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 300.ms, duration: 800.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuart),
                
                const SizedBox(height: 32),
                
                // Divider
                Row(
                  children: [
                    Expanded(child: Divider(color: AppColors.of(context).glassBorder)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: GoogleFonts.inter(
                          color: AppColors.of(context).textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: AppColors.of(context).glassBorder)),
                  ],
                ).animate().fadeIn(delay: 400.ms, duration: 600.ms),
                
                const SizedBox(height: 32),
                
                _buildSocialButton(
                  text: 'Continue with Google',
                  icon: Image.network(
                    'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/120px-Google_%22G%22_logo.svg.png',
                    width: 20,
                    height: 20,
                  ),
                ).animate().fadeIn(delay: 500.ms, duration: 600.ms).slideX(begin: 0.1, end: 0, curve: Curves.easeOutQuart),
                
                const SizedBox(height: 16),
                
                _buildSocialButton(
                  text: 'Continue with Apple',
                  icon: FaIcon(FontAwesomeIcons.apple, color: AppColors.of(context).textPrimary, size: 20),
                ).animate().fadeIn(delay: 600.ms, duration: 600.ms).slideX(begin: 0.1, end: 0, curve: Curves.easeOutQuart),
                
                const SizedBox(height: 48),
                
                // Footer
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignupScreen()),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: GoogleFonts.inter(
                            color: AppColors.of(context).textSecondary,
                          ),
                        ),
                        Text(
                          "Create Account",
                          style: GoogleFonts.inter(
                            color: AppColors.of(context).primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 700.ms, duration: 600.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
