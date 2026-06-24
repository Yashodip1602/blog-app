import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToLogin();
  }

  Future<void> _navigateToLogin() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            // Glowing Logo
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.of(context).primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.of(context).primary.withOpacity(0.6),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.edit_document,
                size: 48,
                color: Colors.white,
              ),
            ).animate()
             .fadeIn(duration: 800.ms)
             .scale(begin: const Offset(0.8, 0.8), duration: 800.ms, curve: Curves.easeOutBack),
            
            const SizedBox(height: 32),
            
            // App Name
            Text(
              'BlogSphere',
              style: GoogleFonts.inter(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: AppColors.of(context).textPrimary,
                letterSpacing: -1,
              ),
            ).animate()
             .fadeIn(delay: 300.ms, duration: 600.ms)
             .slideY(begin: 0.2, end: 0, delay: 300.ms, duration: 600.ms, curve: Curves.easeOutQuart),
             
            const SizedBox(height: 8),
            
            // Subtitle
            Text(
              'Read. Write. Share.',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: AppColors.of(context).textSecondary,
                letterSpacing: 0.5,
              ),
            ).animate()
             .fadeIn(delay: 500.ms, duration: 600.ms)
             .slideY(begin: 0.2, end: 0, delay: 500.ms, duration: 600.ms, curve: Curves.easeOutQuart),
             
            const Spacer(),
            
            // Loading Indicator
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: AppColors.of(context).primary,
                strokeWidth: 2.5,
              ),
            ).animate().fadeIn(delay: 800.ms, duration: 600.ms),
            
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}
