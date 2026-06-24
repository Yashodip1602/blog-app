import 'dart:io';

void main() {
  final dir = Directory('lib');
  final entities = dir.listSync(recursive: true);

  for (final entity in entities) {
    if (entity is File && entity.path.endsWith('.dart')) {
      var content = entity.readAsStringSync();
      
      // Remove 'const ' before AppColors
      content = content.replaceAll(RegExp(r'const\s+AppColors'), 'AppColors');
      
      // Remove 'const ' before Text/Icon widgets that use AppColors
      content = content.replaceAll(RegExp(r'const\s+(Text|Icon|Divider|SizedBox|Container|Row|Column|Padding)\(([^)]*AppColors[^)]*)\)'), r'$1($2)');
      
      // Just aggressively remove 'const ' from Icon if it contains AppColors
      content = content.replaceAll(RegExp(r'const\s+Icon\(([^;]*AppColors\.of\(context\)[^;]*)\)'), r'Icon($1)');
      
      // For Text with style
      content = content.replaceAll(RegExp(r'const\s+Text\(([^;]*AppColors\.of\(context\)[^;]*)\)'), r'Text($1)');
      
      // For Divider
      content = content.replaceAll(RegExp(r'const\s+Divider\(([^;]*AppColors\.of\(context\)[^;]*)\)'), r'Divider($1)');

      entity.writeAsStringSync(content);
    }
  }
}
