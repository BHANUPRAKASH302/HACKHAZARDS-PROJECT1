import os
import re

lib_dir = "lib"
patterns = [
    r"const\s+Icon\(",
    r"const\s+Divider\(",
    r"const\s+BoxDecoration\(",
    r"const\s+OutlineInputBorder\(",
    r"const\s+BorderSide\(",
    r"const\s+Expanded\("
]

updated_count = 0

for root, dirs, files in os.walk(lib_dir):
    for f in files:
        if f.endswith(".dart"):
            path = os.path.join(root, f)
            with open(path, "r") as file:
                content = file.read()
            original = content
            for p in patterns:
                content = re.sub(p, lambda m: m.group(0).replace("const ", "").replace("const\t", "").replace("const\n", ""), content)
            if content != original:
                with open(path, "w") as file:
                    file.write(content)
                print(f"Updated {path}")
                updated_count += 1

print(f"Done. Updated {updated_count} files.")
