import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../theme/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late ThemeMode _selectedTheme;

  @override
  void initState() {
    super.initState();
    _selectedTheme = themeNotifier.value;
  }

  Future<void> _updateTheme(ThemeMode mode) async {
    setState(() {
      _selectedTheme = mode;
    });
    themeNotifier.value = mode;
    
    final prefs = await SharedPreferences.getInstance();
    if (mode == ThemeMode.light) {
      prefs.setString('themeMode', 'light');
    } else if (mode == ThemeMode.dark) {
      prefs.setString('themeMode', 'dark');
    } else {
      prefs.setString('themeMode', 'system');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? AppColors.of(context).textPrimary : Colors.black87;
    final secondaryColor = isDarkMode ? AppColors.of(context).textSecondary : Colors.black54;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final surfaceColor = AppColors.of(context).surfaceLight;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor.withOpacity(0.95),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Settings',
          style: GoogleFonts.inter(color: textColor, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Appearance',
              style: GoogleFonts.inter(
                color: AppColors.of(context).primary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.of(context).glassBorder),
              ),
              child: Column(
                children: [
                  _buildThemeOption(
                    title: 'System Default',
                    value: ThemeMode.system,
                    icon: Icons.brightness_auto,
                    textColor: textColor,
                    secondaryColor: secondaryColor,
                  ),
                  Divider(color: AppColors.of(context).glassBorder.withOpacity(0.5), height: 1),
                  _buildThemeOption(
                    title: 'Light Theme',
                    value: ThemeMode.light,
                    icon: Icons.light_mode,
                    textColor: textColor,
                    secondaryColor: secondaryColor,
                  ),
                  Divider(color: AppColors.of(context).glassBorder.withOpacity(0.5), height: 1),
                  _buildThemeOption(
                    title: 'Dark Theme',
                    value: ThemeMode.dark,
                    icon: Icons.dark_mode,
                    textColor: textColor,
                    secondaryColor: secondaryColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption({
    required String title,
    required ThemeMode value,
    required IconData icon,
    required Color textColor,
    required Color secondaryColor,
  }) {
    return RadioListTile<ThemeMode>(
      value: value,
      groupValue: _selectedTheme,
      onChanged: (ThemeMode? newValue) {
        if (newValue != null) {
          _updateTheme(newValue);
        }
      },
      title: Row(
        children: [
          Icon(icon, color: secondaryColor, size: 20),
          const SizedBox(width: 12),
          Text(
            title,
            style: GoogleFonts.inter(
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      activeColor: AppColors.of(context).primary,
      controlAffinity: ListTileControlAffinity.trailing,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
    );
  }
}
