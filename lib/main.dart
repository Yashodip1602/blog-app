import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/splash_screen.dart';
import 'theme/app_colors.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final themeStr = prefs.getString('themeMode') ?? 'system';
  if (themeStr == 'light') themeNotifier.value = ThemeMode.light;
  if (themeStr == 'dark') themeNotifier.value = ThemeMode.dark;

  runApp(const BlogSphereApp());
}

class BlogSphereApp extends StatelessWidget {
  const BlogSphereApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentThemeMode, child) {
        return MaterialApp(
          title: 'BlogSphere',
          debugShowCheckedModeBanner: false,
          themeMode: currentThemeMode,
          localizationsDelegates: const [
            FlutterQuillLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
          ],
          theme: ThemeData(
            colorScheme: ColorScheme.light(
              primary: AppColors.light.primary,
              secondary: AppColors.light.secondary,
              surface: AppColors.light.surface,
            ),
            scaffoldBackgroundColor: AppColors.light.background,
            useMaterial3: true,
            textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.dark(
              primary: AppColors.dark.primary,
              secondary: AppColors.dark.secondary,
              surface: AppColors.dark.surface,
            ),
            scaffoldBackgroundColor: AppColors.dark.background,
            useMaterial3: true,
            textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}
