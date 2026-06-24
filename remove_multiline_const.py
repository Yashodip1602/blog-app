import os

for root, _, files in os.walk('lib'):
    for file in files:
        if file.endswith('.dart'):
            path = os.path.join(root, file)
            with open(path, 'r') as f:
                content = f.read()
            
            new_content = content.replace('const BoxDecoration(', 'BoxDecoration(')
            new_content = new_content.replace('const Border(', 'Border(')
            new_content = new_content.replace('const BorderSide(', 'BorderSide(')
            new_content = new_content.replace('const Icon(Icons.arrow_forward, color:\n                                        AppColors.of(context).textSecondary, size: 14)', 'Icon(Icons.arrow_forward, color:\n                                        AppColors.of(context).textSecondary, size: 14)')
            
            # Specifically for author_role_request_screen.dart:344
            new_content = new_content.replace('const Icon(Icons.arrow_forward', 'Icon(Icons.arrow_forward')
            
            if new_content != content:
                with open(path, 'w') as f:
                    f.write(new_content)
                print(f"Updated {path}")
