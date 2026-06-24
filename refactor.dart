import 'dart:io';

void main() {
  final dir = Directory('lib');
  final entities = dir.listSync(recursive: true);

  for (final entity in entities) {
    if (entity is File && entity.path.endsWith('.dart') && !entity.path.endsWith('app_colors.dart') && !entity.path.endsWith('main.dart')) {
      final content = entity.readAsStringSync();
      // Only replace if it matches AppColors.property, avoiding AppColors.of(context)
      final newContent = content.replaceAllMapped(RegExp(r'AppColors\.(?!of\()([a-zA-Z0-9_]+)'), (match) {
        return 'AppColors.of(context).${match.group(1)}';
      });

      if (content != newContent) {
        entity.writeAsStringSync(newContent);
        print('Updated: ${entity.path}');
      }
    }
  }
}
