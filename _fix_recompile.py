"""Fix the Kotlin recompile in repair_engine.py."""
from pathlib import Path

engine = Path("factory/assembly/repair/repair_engine.py")
content = engine.read_text(encoding="utf-8")

# Find and replace the Kotlin recompile section
# We need to find the elif block for kotlin
lines = content.splitlines()

# Find the start of the kotlin elif
start_idx = None
for i, line in enumerate(lines):
    if 'elif self.language == "kotlin":' in line:
        start_idx = i
        break

if start_idx is None:
    print("Kotlin elif not found!")
    exit(1)

# Find the end (next except or return that's at the same indent level)
end_idx = len(lines)
for i in range(start_idx + 1, len(lines)):
    stripped = lines[i].lstrip()
    indent = len(lines[i]) - len(stripped)
    # Back to 12-space indent (same as elif) or less = end of block
    if indent <= 12 and stripped and not stripped.startswith("#"):
        end_idx = i
        break

print(f"Replacing lines {start_idx}-{end_idx}")

new_block = [
    '            elif self.language == "kotlin":',
    '                import os as _os',
    '                java_home = _os.environ.get("JAVA_HOME", "C:/Program Files/Android/Android Studio/jbr")',
    '                android_home = _os.environ.get("ANDROID_HOME", "C:/Users/Admin/AppData/Local/Android/Sdk")',
    '                env = _os.environ.copy()',
    '                env["JAVA_HOME"] = java_home',
    '                env["ANDROID_HOME"] = android_home',
    '                # Use cmd /c to properly capture Gradle output on Windows',
    '                bat_path = _os.path.join(self.project_dir, "_kt_compile.bat")',
    '                with open(bat_path, "w") as bf:',
    '                    bf.write("@echo off\\r\\n")',
    '                    bf.write("set JAVA_HOME=" + java_home + "\\r\\n")',
    '                    bf.write("set ANDROID_HOME=" + android_home + "\\r\\n")',
    '                    bf.write("call /tmp/gradle-8.4/bin/gradle compileDebugKotlin --no-daemon 2>&1\\r\\n")',
    '                result = subprocess.run(',
    '                    ["cmd", "/c", bat_path],',
    '                    cwd=self.project_dir,',
    '                    capture_output=True, text=True, timeout=300,',
    '                )',
    '                try:',
    '                    _os.remove(bat_path)',
    '                except Exception:',
    '                    pass',
    '                return result.stdout',
]

result_lines = lines[:start_idx] + new_block + lines[end_idx:]
engine.write_text("\n".join(result_lines), encoding="utf-8")
print("Kotlin recompile fixed")

import ast
ast.parse(engine.read_text(encoding="utf-8"))
print("Syntax OK")
