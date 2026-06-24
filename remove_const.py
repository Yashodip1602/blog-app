import os
import re

for root, _, files in os.walk('lib'):
    for file in files:
        if file.endswith('.dart'):
            path = os.path.join(root, file)
            with open(path, 'r') as f:
                content = f.read()
            
            # Use regex to find `const` followed by spaces, and then a widget name, and somewhere inside its parameters `AppColors`
            # Actually, the simplest is: if a line contains `AppColors.`, remove `const ` from that line!
            # Since dart format will format it anyway, this is a bit brute force but safe.
            lines = content.split('\n')
            new_lines = []
            for line in lines:
                if 'AppColors.' in line and 'const ' in line:
                    # Remove 'const '
                    line = line.replace('const ', '')
                new_lines.append(line)
            
            new_content = '\n'.join(new_lines)
            if new_content != content:
                with open(path, 'w') as f:
                    f.write(new_content)
                print(f"Updated {path}")
