import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_container.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/api_service.dart';
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
  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool('remember_me') ?? false;
    if (rememberMe) {
      setState(() {
        _rememberMe = true;
        _emailController.text = prefs.getString('saved_email') ?? '';
        _passwordController.text = prefs.getString('saved_password') ?? '';
      });
    }
  }

  Widget _buildTextField({
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextEditingController? controller,
    String? errorText,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.of(context).surfaceLight.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: errorText != null ? Colors.redAccent : AppColors.of(context).glassBorder),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword && _obscurePassword,
            style: GoogleFonts.inter(color: AppColors.of(context).textPrimary),
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.inter(color: AppColors.of(context).textHint),
              prefixIcon: Icon(icon, color: errorText != null ? Colors.redAccent : AppColors.of(context).textSecondary, size: 20),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: errorText != null ? Colors.redAccent : AppColors.of(context).textSecondary,
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
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 8),
            child: Text(
              errorText,
              style: GoogleFonts.inter(color: Colors.redAccent, fontSize: 12),
            ),
          ),
      ],
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
                        errorText: _emailError,
                        onChanged: (val) {
                          if (_emailError != null) setState(() => _emailError = null);
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        hint: 'Enter your password',
                        icon: Icons.lock_outline,
                        isPassword: true,
                        controller: _passwordController,
                        errorText: _passwordError,
                        onChanged: (val) {
                          if (_passwordError != null) setState(() => _passwordError = null);
                        },
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
                            onTap: _isLoading ? null : () async {
                              final email = _emailController.text.trim();
                              final password = _passwordController.text;
                              
                              bool hasError = false;
                              
                              if (email.isEmpty) {
                                setState(() {
                                  _emailError = 'Please enter email or phone number';
                                });
                                hasError = true;
                              } else {
                                setState(() => _emailError = null);
                              }
                              
                              if (password.isEmpty) {
                                setState(() {
                                  _passwordError = 'Please enter your password';
                                });
                                hasError = true;
                              } else {
                                setState(() => _passwordError = null);
                              }
                              
                              if (hasError) return;

                              setState(() {
                                _isLoading = true;
                              });

                              try {
                                final response = await ApiService().login(email: email, password: password);
                                
                                if (response['success'] == true) {
                                  final prefs = await SharedPreferences.getInstance();
                                  
                                  // Save Remember Me state
                                  await prefs.setBool('remember_me', _rememberMe);
                                  if (_rememberMe) {
                                    await prefs.setString('saved_email', email);
                                    await prefs.setString('saved_password', password);
                                  } else {
                                    await prefs.remove('saved_email');
                                    await prefs.remove('saved_password');
                                  }

                                  // Also save basic info if needed for dashboard cache
                                  final data = response['data'];
                                  if (data != null) {
                                    if (data['full_name'] != null) await prefs.setString('demoUserName', data['full_name']);
                                    if (data['email'] != null) await prefs.setString('demoUserEmail', data['email']);
                                    if (data['phone_no'] != null) await prefs.setString('userPhone', data['phone_no']);
                                    if (data['profile_photo_url'] != null) await prefs.setString('profilePhotoUrl', data['profile_photo_url']);
                                  }

                                  if (mounted) {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (context) => const DashboardScreen()),
                                    );
                                  }
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(e.toString().replaceAll('Exception: ', ''), style: GoogleFonts.inter(color: Colors.white)),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                }
                              } finally {
                                if (mounted) {
                                  setState(() {
                                    _isLoading = false;
                                  });
                                }
                              }
                            },
                            child: Center(
                              child: _isLoading 
                                ? const SizedBox(
                                    width: 24, 
                                    height: 24, 
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                                  )
                                : Text(
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
