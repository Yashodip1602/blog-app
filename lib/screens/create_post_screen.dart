import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import '../theme/app_colors.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  
  bool _hasCoverImage = false;
  String? _selectedCategory;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _summaryController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  final List<String> _tags = [];

  final quill.QuillController _quillController = quill.QuillController.basic();

  final List<String> _categories = [
    'Technology', 'Programming', 'DevOps', 'AI', 'Business', 'Travel', 'Lifestyle'
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _summaryController.dispose();
    _tagController.dispose();
    _quillController.dispose();
    super.dispose();
  }

  void _handleTagInput(String value) {
    if (value.endsWith(' ') || value.endsWith(',')) {
      final tag = value.replaceAll(',', '').trim();
      if (tag.isNotEmpty && !_tags.contains(tag)) {
        setState(() {
          _tags.add(tag);
        });
      }
      _tagController.clear();
    }
  }

  void _openPreview() {
    final title = _titleController.text.trim();
    final summary = _summaryController.text.trim();
    final content = _quillController.document
        .toPlainText()
        .trim();

    if (title.isEmpty && content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Write something first to preview!'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _BlogPreviewScreen(
          title: title.isEmpty ? 'Untitled Post' : title,
          summary: summary,
          content: content,
          category: _selectedCategory,
          tags: List.from(_tags),
          hasCoverImage: _hasCoverImage,
        ),
      ),
    );
  }

  void _publishPost() {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a category', style: TextStyle(color: Colors.white)), backgroundColor: Colors.redAccent),
        );
        return;
      }
      if (_quillController.document.isEmpty()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Content cannot be empty', style: TextStyle(color: Colors.white)), backgroundColor: Colors.redAccent),
        );
        return;
      }
      
      final contentJson = jsonEncode(_quillController.document.toDelta().toJson());
      print('Publishing post content: $contentJson');
      
      // Simulate publish delay
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text('Blog published successfully', style: GoogleFonts.inter(color: Colors.white)),
            ],
          ),
          backgroundColor: AppColors.of(context).primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      
      Navigator.pop(context); // Go back to dashboard
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      appBar: AppBar(
        backgroundColor: AppColors.of(context).background.withOpacity(0.95),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.of(context).textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Create Post',
          style: GoogleFonts.inter(color: AppColors.of(context).textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {},
            child: Text('Draft', style: GoogleFonts.inter(color: AppColors.of(context).textSecondary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover Image Upload
              GestureDetector(
                onTap: () {
                  setState(() {
                    _hasCoverImage = !_hasCoverImage; // toggle mock
                  });
                },
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.of(context).surfaceLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.of(context).glassBorder,
                      width: 1.5,
                      style: _hasCoverImage ? BorderStyle.solid : BorderStyle.none,
                    ),
                  ),
                  child: _hasCoverImage
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(
                                'https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=800',
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: IconButton(
                                  icon: const Icon(Icons.close, color: Colors.white),
                                  onPressed: () => setState(() => _hasCoverImage = false),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.cloud_upload_outlined, color: AppColors.of(context).primary, size: 48),
                              const SizedBox(height: 12),
                              Text(
                                'Add blog cover image',
                                style: GoogleFonts.inter(color: AppColors.of(context).textSecondary, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                ),
              ).animate().fadeIn(duration: 400.ms),

              const SizedBox(height: 32),

              // Blog Title
              TextFormField(
                controller: _titleController,
                style: GoogleFonts.inter(color: AppColors.of(context).textPrimary, fontSize: 24, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  hintText: 'Enter blog title',
                  hintStyle: GoogleFonts.inter(color: AppColors.of(context).textHint, fontSize: 24, fontWeight: FontWeight.bold),
                  border: InputBorder.none,
                ),
                validator: (value) => value == null || value.trim().isEmpty ? 'Title is required' : null,
              ).animate().fadeIn(delay: 100.ms),

              const SizedBox(height: 24),

              // Category Dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.of(context).surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.of(context).glassBorder),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    hint: Text('Select Category', style: GoogleFonts.inter(color: AppColors.of(context).textHint)),
                    dropdownColor: AppColors.of(context).surface,
                    icon: Icon(Icons.keyboard_arrow_down, color: AppColors.of(context).textSecondary),
                    isExpanded: true,
                    style: GoogleFonts.inter(color: AppColors.of(context).textPrimary),
                    items: _categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCategory = newValue;
                      });
                    },
                  ),
                ),
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 24),

              // Tags Input
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.of(context).surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.of(context).glassBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_tags.isNotEmpty)
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: _tags.map((tag) {
                          return Chip(
                            label: Text(tag, style: GoogleFonts.inter(color: Colors.white, fontSize: 12)),
                            backgroundColor: AppColors.of(context).primary,
                            deleteIcon: const Icon(Icons.close, color: Colors.white, size: 16),
                            onDeleted: () {
                              setState(() {
                                _tags.remove(tag);
                              });
                            },
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            side: BorderSide.none,
                          );
                        }).toList(),
                      ),
                    TextField(
                      controller: _tagController,
                      style: GoogleFonts.inter(color: AppColors.of(context).textPrimary),
                      decoration: InputDecoration(
                        hintText: _tags.isEmpty ? 'Add tags (press space)' : 'Add more...',
                        hintStyle: GoogleFonts.inter(color: AppColors.of(context).textHint),
                        border: InputBorder.none,
                      ),
                      onChanged: _handleTagInput,
                      onSubmitted: (value) {
                        _handleTagInput('$value ');
                      },
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 300.ms),

              const SizedBox(height: 24),

              // Short Description
              TextFormField(
                controller: _summaryController,
                style: GoogleFonts.inter(color: AppColors.of(context).textSecondary, fontSize: 16),
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Write short blog summary...',
                  hintStyle: GoogleFonts.inter(color: AppColors.of(context).textHint, fontSize: 16),
                  filled: true,
                  fillColor: AppColors.of(context).surfaceLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.of(context).glassBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.of(context).glassBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.of(context).primary),
                  ),
                ),
              ).animate().fadeIn(delay: 400.ms),

              const SizedBox(height: 32),

              // Rich Text Editor Toolbar
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.of(context).glassBorder)),
                ),
                child: quill.QuillSimpleToolbar(
                  controller: _quillController,
                  config: const quill.QuillSimpleToolbarConfig(
                    showFontFamily: false,
                    showFontSize: false,
                    showColorButton: false,
                    showBackgroundColorButton: false,
                    showClearFormat: false,
                    showAlignmentButtons: false,
                    showDirection: false,
                    showSearchButton: false,
                    showInlineCode: false,
                    showSubscript: false,
                    showSuperscript: false,
                    showListCheck: false,
                    showIndent: false,
                    showUnderLineButton: false,
                  ),
                ),
              ).animate().fadeIn(delay: 500.ms),

              // Blog Content Editor
              Container(
                height: 300,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.of(context).surfaceLight.withOpacity(0.3),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: quill.QuillEditor.basic(
                  controller: _quillController,
                  config: const quill.QuillEditorConfig(
                    placeholder: 'Start writing your blog...',
                    padding: EdgeInsets.zero,
                  ),
                ),
              ).animate().fadeIn(delay: 500.ms),

              const SizedBox(height: 40),

              // Action Buttons Row
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.of(context).surfaceLight,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.of(context).glassBorder),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: _openPreview,
                          child: Center(
                            child: Text(
                              'Preview',
                              style: GoogleFonts.inter(color: AppColors.of(context).textPrimary, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0),

              const SizedBox(height: 16),

              // Publish Button
              Container(
                height: 56,
                width: double.infinity,
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
                    onTap: _publishPost,
                    child: Center(
                      child: Text(
                        'Publish Post',
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.2, end: 0),

              const SizedBox(height: 60), // bottom padding
            ],
          ),
        ),
      ),
    );
  }

}

// ─── Blog Preview Screen ───────────────────────────────────────────────────────

class _BlogPreviewScreen extends StatelessWidget {
  final String title;
  final String summary;
  final String content;
  final String? category;
  final List<String> tags;
  final bool hasCoverImage;

  const _BlogPreviewScreen({
    required this.title,
    required this.summary,
    required this.content,
    required this.category,
    required this.tags,
    required this.hasCoverImage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      appBar: AppBar(
        backgroundColor: AppColors.of(context).background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.of(context).textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Preview',
          style: GoogleFonts.inter(
            color: AppColors.of(context).textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.of(context).primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.of(context).primary.withOpacity(0.4)),
            ),
            child: Center(
              child: Text(
                'Draft',
                style: GoogleFonts.inter(
                  color: AppColors.of(context).primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Image
            if (hasCoverImage) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  'https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=800',
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Category badge
            if (category != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: AppColors.of(context).primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  category!,
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Title
            Text(
              title,
              style: GoogleFonts.inter(
                color: AppColors.of(context).textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 16),

            // Author row (mock current user)
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: const NetworkImage(
                    'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=300',
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'You',
                      style: GoogleFonts.inter(
                        color: AppColors.of(context).textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'Just now • Draft',
                      style: GoogleFonts.inter(
                        color: AppColors.of(context).textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Divider
            Divider(color: AppColors.of(context).glassBorder),
            const SizedBox(height: 24),

            // Summary
            if (summary.isNotEmpty) ...[
              Text(
                summary,
                style: GoogleFonts.inter(
                  color: AppColors.of(context).textSecondary,
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 24),
              Divider(color: AppColors.of(context).glassBorder),
              const SizedBox(height: 24),
            ],

            // Body content
            if (content.isNotEmpty)
              Text(
                content,
                style: GoogleFonts.inter(
                  color: AppColors.of(context).textPrimary,
                  fontSize: 16,
                  height: 1.8,
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.of(context).surfaceLight.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.of(context).glassBorder),
                ),
                child: Center(
                  child: Text(
                    'No content written yet.',
                    style: GoogleFonts.inter(color: AppColors.of(context).textHint),
                  ),
                ),
              ),

            // Tags
            if (tags.isNotEmpty) ...[
              const SizedBox(height: 32),
              Divider(color: AppColors.of(context).glassBorder),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: tags.map((tag) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.of(context).surfaceLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.of(context).glassBorder),
                  ),
                  child: Text(
                    '#$tag',
                    style: GoogleFonts.inter(
                      color: AppColors.of(context).primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )).toList(),
              ),
            ],

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
