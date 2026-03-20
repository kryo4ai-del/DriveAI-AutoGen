"""Web Assembly Line — npm + Next.js.

Web assembly uses Node.js + npm to build Next.js/React/TypeScript apps.
Can run on both Windows and Mac (Node.js is cross-platform).
"""

import json
import os
import re
import shutil
import subprocess
from pathlib import Path

from factory.assembly.handoff_protocol import ProductionHandoff
from factory.assembly.lines.base_line import (
    BaseAssemblyLine, CompileResult, FixAction,
)


class WebAssemblyLine(BaseAssemblyLine):
    """Web assembly for TypeScript/React/Next.js."""

    def __init__(self):
        self.handoff = None
        self.project_dir = None
        self.src_dir = None

    def receive_handoff(self, handoff: ProductionHandoff) -> bool:
        if handoff.platform != "web":
            return False
        self.handoff = handoff
        self.project_dir = Path(handoff.source_directory)
        ts_files = [f for f in handoff.file_manifest if f.endswith((".ts", ".tsx"))]
        print(f"  [Web] Accepted: {len(ts_files)} .ts/.tsx files from {handoff.project_name}")
        return len(ts_files) > 0

    def create_build_system(self) -> dict:
        """Generate real Next.js project files."""
        created = []

        # package.json
        pkg = {
            "name": "askfin-web",
            "version": "1.0.0",
            "private": True,
            "scripts": {
                "dev": "next dev",
                "build": "next build",
                "start": "next start",
                "lint": "next lint"
            },
            "dependencies": {
                "next": "14.2.0",
                "react": "^18.3.0",
                "react-dom": "^18.3.0"
            },
            "devDependencies": {
                "@types/node": "^20.0.0",
                "@types/react": "^18.3.0",
                "@types/react-dom": "^18.3.0",
                "typescript": "^5.4.0",
                "tailwindcss": "^3.4.0",
                "postcss": "^8.4.0",
                "autoprefixer": "^10.4.0",
                "@testing-library/react": "^14.0.0",
                "@testing-library/jest-dom": "^6.0.0",
                "jest": "^29.0.0"
            }
        }
        (self.project_dir / "package.json").write_text(
            json.dumps(pkg, indent=2), encoding="utf-8"
        )
        created.append("package.json")

        # tsconfig.json
        tsconfig = {
            "compilerOptions": {
                "target": "es5",
                "lib": ["dom", "dom.iterable", "esnext"],
                "allowJs": True,
                "skipLibCheck": True,
                "strict": True,
                "noEmit": True,
                "esModuleInterop": True,
                "module": "esnext",
                "moduleResolution": "bundler",
                "resolveJsonModule": True,
                "isolatedModules": True,
                "jsx": "preserve",
                "incremental": True,
                "plugins": [{"name": "next"}],
                "paths": {"@/*": ["./src/*"]}
            },
            "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx"],
            "exclude": ["node_modules"]
        }
        (self.project_dir / "tsconfig.json").write_text(
            json.dumps(tsconfig, indent=2), encoding="utf-8"
        )
        created.append("tsconfig.json")

        # next.config.js
        (self.project_dir / "next.config.js").write_text(
            "/** @type {import('next').NextConfig} */\n"
            "const nextConfig = {}\n\n"
            "module.exports = nextConfig\n",
            encoding="utf-8",
        )
        created.append("next.config.js")

        # tailwind.config.ts
        tw_lines = [
            "import type { Config } from 'tailwindcss'",
            "",
            "const config: Config = {",
            "  content: [",
            "    './src/pages/**/*.{js,ts,jsx,tsx,mdx}',",
            "    './src/components/**/*.{js,ts,jsx,tsx,mdx}',",
            "    './src/app/**/*.{js,ts,jsx,tsx,mdx}',",
            "  ],",
            "  theme: { extend: {} },",
            "  plugins: [],",
            "}",
            "export default config",
        ]
        (self.project_dir / "tailwind.config.ts").write_text(
            "\n".join(tw_lines), encoding="utf-8"
        )
        created.append("tailwind.config.ts")

        # postcss.config.js
        (self.project_dir / "postcss.config.js").write_text(
            "module.exports = {\n"
            "  plugins: {\n"
            "    tailwindcss: {},\n"
            "    autoprefixer: {},\n"
            "  },\n"
            "}\n",
            encoding="utf-8",
        )
        created.append("postcss.config.js")

        # .eslintrc.json
        (self.project_dir / ".eslintrc.json").write_text(
            json.dumps({"extends": "next/core-web-vitals"}, indent=2),
            encoding="utf-8",
        )
        created.append(".eslintrc.json")

        # next-env.d.ts
        (self.project_dir / "next-env.d.ts").write_text(
            "/// <reference types=\"next\" />\n"
            "/// <reference types=\"next/image-types/global\" />\n\n"
            "// NOTE: This file should not be edited\n",
            encoding="utf-8",
        )
        created.append("next-env.d.ts")

        print(f"  [Web] Build system: {len(created)} files created")
        return {"created": created, "status": "ok"}

    def organize_files(self) -> dict:
        """Move .ts/.tsx files into Next.js App Router structure."""
        if not self.handoff:
            return {"status": "no_handoff"}

        src_root = self.project_dir / "src"
        self.src_dir = src_root

        moved = 0
        skipped = 0
        errors = 0

        for rel_path in self.handoff.file_manifest:
            if not rel_path.endswith((".ts", ".tsx")):
                continue
            src = self.project_dir / rel_path
            if not src.is_file():
                skipped += 1
                continue

            try:
                file_content = src.read_text(encoding="utf-8")
            except Exception:
                errors += 1
                continue

            target_sub = self._classify_file(file_content, src.name)
            target_dir = src_root / target_sub.replace("/", os.sep)
            target_dir.mkdir(parents=True, exist_ok=True)
            target_file = target_dir / src.name

            if target_file.exists():
                skipped += 1
                continue

            shutil.copy2(str(src), str(target_file))
            moved += 1

        print(f"  [Web] Organized: {moved} files, {skipped} skipped, {errors} errors")
        return {"moved": moved, "skipped": skipped, "errors": errors, "status": "ok"}

    def _classify_file(self, content: str, filename: str) -> str:
        """Classify a .ts/.tsx file into the correct src/ subdirectory."""
        name_lower = filename.lower()

        # Hooks
        if name_lower.startswith("use") and filename.endswith(".ts"):
            return "hooks"

        # Context providers
        if "createContext" in content:
            return "contexts"

        # Pure types/interfaces (no functions, no JSX)
        has_jsx = "<div" in content or "<section" in content or "className=" in content
        has_func = "export function" in content or "export const" in content
        if not has_jsx and not has_func:
            if "export interface" in content or "export type" in content:
                return "types"

        # Services (API calls, business logic)
        if "fetch(" in content or "axios" in content or "Service" in filename:
            return "services"

        # Utils
        if "Util" in filename or "Helper" in filename or "util" in name_lower:
            return "utils"

        # Components (default for .tsx with JSX)
        if filename.endswith(".tsx"):
            return "components"

        # Default
        return "types" if filename.endswith(".ts") else "components"

    def wire_app(self) -> dict:
        """Generate Next.js app entry points and layout."""
        if not self.src_dir:
            self.src_dir = self.project_dir / "src"

        created = []
        app_dir = self.src_dir / "app"
        app_dir.mkdir(parents=True, exist_ok=True)

        # globals.css
        css_lines = [
            "@tailwind base;",
            "@tailwind components;",
            "@tailwind utilities;",
            "",
            ":root {",
            "  --foreground-rgb: 255, 255, 255;",
            "  --background-start-rgb: 15, 23, 42;",
            "  --background-end-rgb: 15, 23, 42;",
            "}",
            "",
            "body {",
            "  color: rgb(var(--foreground-rgb));",
            "  background: linear-gradient(",
            "    to bottom,",
            "    rgb(var(--background-start-rgb)),",
            "    rgb(var(--background-end-rgb))",
            "  );",
            "  min-height: 100vh;",
            "}",
        ]
        (app_dir / "globals.css").write_text("\n".join(css_lines), encoding="utf-8")
        created.append("app/globals.css")

        # layout.tsx
        layout_lines = [
            "import type { Metadata } from 'next'",
            "import './globals.css'",
            "",
            "export const metadata: Metadata = {",
            "  title: 'AskFin - Fuehrerschein Trainer',",
            "  description: 'AI-powered coaching for German driving exam',",
            "}",
            "",
            "export default function RootLayout({",
            "  children,",
            "}: {",
            "  children: React.ReactNode",
            "}) {",
            "  return (",
            "    <html lang=\"de\">",
            "      <body>",
            "        <nav className=\"bg-slate-800 p-4\">",
            "          <div className=\"max-w-6xl mx-auto flex gap-6\">",
            "            <a href=\"/\" className=\"text-white font-bold\">AskFin</a>",
            "            <a href=\"/training\" className=\"text-slate-300 hover:text-white\">Training</a>",
            "            <a href=\"/exam\" className=\"text-slate-300 hover:text-white\">Generalprobe</a>",
            "            <a href=\"/skillmap\" className=\"text-slate-300 hover:text-white\">Skill Map</a>",
            "            <a href=\"/readiness\" className=\"text-slate-300 hover:text-white\">Readiness</a>",
            "          </div>",
            "        </nav>",
            "        <main className=\"max-w-6xl mx-auto p-6\">",
            "          {children}",
            "        </main>",
            "      </body>",
            "    </html>",
            "  )",
            "}",
        ]
        (app_dir / "layout.tsx").write_text("\n".join(layout_lines), encoding="utf-8")
        created.append("app/layout.tsx")

        # Home page
        home_lines = [
            "export default function Home() {",
            "  return (",
            "    <div className=\"space-y-8\">",
            "      <h1 className=\"text-4xl font-bold text-white\">AskFin</h1>",
            "      <p className=\"text-slate-300 text-lg\">Dein Weg zum Fuehrerschein</p>",
            "      <div className=\"grid grid-cols-1 md:grid-cols-2 gap-6\">",
            "        <a href=\"/training\" className=\"bg-slate-800 rounded-xl p-6 hover:bg-slate-700 transition\">",
            "          <h2 className=\"text-xl font-semibold text-white\">Taegliches Training</h2>",
            "          <p className=\"text-slate-400 mt-2\">Adaptives Fragentraining</p>",
            "        </a>",
            "        <a href=\"/exam\" className=\"bg-slate-800 rounded-xl p-6 hover:bg-slate-700 transition\">",
            "          <h2 className=\"text-xl font-semibold text-white\">Generalprobe</h2>",
            "          <p className=\"text-slate-400 mt-2\">30-Fragen Pruefungssimulation</p>",
            "        </a>",
            "        <a href=\"/skillmap\" className=\"bg-slate-800 rounded-xl p-6 hover:bg-slate-700 transition\">",
            "          <h2 className=\"text-xl font-semibold text-white\">Skill Map</h2>",
            "          <p className=\"text-slate-400 mt-2\">Kompetenz pro Kategorie</p>",
            "        </a>",
            "        <a href=\"/readiness\" className=\"bg-slate-800 rounded-xl p-6 hover:bg-slate-700 transition\">",
            "          <h2 className=\"text-xl font-semibold text-white\">Readiness Score</h2>",
            "          <p className=\"text-slate-400 mt-2\">0-100% Pruefungsbereitschaft</p>",
            "        </a>",
            "      </div>",
            "    </div>",
            "  )",
            "}",
        ]
        (app_dir / "page.tsx").write_text("\n".join(home_lines), encoding="utf-8")
        created.append("app/page.tsx")

        # Feature page shells
        features = {
            "training": ("Training", "Adaptives Fragentraining"),
            "exam": ("Generalprobe", "Pruefungssimulation"),
            "skillmap": ("Skill Map", "Kompetenzuebersicht"),
            "readiness": ("Readiness Score", "Pruefungsbereitschaft"),
        }
        for slug, (title, desc) in features.items():
            feat_dir = app_dir / slug
            feat_dir.mkdir(exist_ok=True)
            page_lines = [
                "'use client'",
                "",
                f"export default function {title.replace(' ', '')}Page() {{",
                "  return (",
                f"    <div className=\"space-y-6\">",
                f"      <h1 className=\"text-3xl font-bold text-white\">{title}</h1>",
                f"      <p className=\"text-slate-400\">{desc}</p>",
                "      {/* TODO: Import and render generated components */}",
                "    </div>",
                "  )",
                "}",
            ]
            (feat_dir / "page.tsx").write_text("\n".join(page_lines), encoding="utf-8")
            created.append(f"app/{slug}/page.tsx")

        print(f"  [Web] Wiring: {len(created)} files created")
        return {"created": created, "status": "ok"}

    def compile(self) -> CompileResult:
        """Attempt npm install + tsc --noEmit + next build."""
        # Check if npm is available
        try:
            subprocess.run(["npm", "--version"], capture_output=True, timeout=10)
        except (FileNotFoundError, subprocess.TimeoutExpired):
            cmd = f"cd {self.project_dir} && npm install && npx tsc --noEmit"
            return CompileResult(
                success=False, skipped=True,
                skip_reason=f"npm not available. Run manually: {cmd}",
                command=cmd,
            )

        # npm install
        print("  [Web] Running npm install...")
        try:
            install = subprocess.run(
                ["npm", "install"],
                cwd=str(self.project_dir),
                capture_output=True, text=True, timeout=120,
            )
            if install.returncode != 0:
                return CompileResult(
                    success=False,
                    errors=[f"npm install failed: {install.stderr[:500]}"],
                    error_count=1,
                    command="npm install",
                )
        except subprocess.TimeoutExpired:
            return CompileResult(success=False, errors=["npm install timed out"], error_count=1)

        # TypeScript type check
        print("  [Web] Running tsc --noEmit...")
        try:
            tsc = subprocess.run(
                ["npx", "tsc", "--noEmit"],
                cwd=str(self.project_dir),
                capture_output=True, text=True, timeout=120,
            )
            out = tsc.stdout + tsc.stderr
            errs = [l.strip() for l in out.splitlines() if ": error " in l]
            warns = [l.strip() for l in out.splitlines() if ": warning " in l]
            return CompileResult(
                success=tsc.returncode == 0,
                errors=errs, warnings=warns,
                error_count=len(errs), warning_count=len(warns),
                command="npx tsc --noEmit",
            )
        except subprocess.TimeoutExpired:
            return CompileResult(success=False, errors=["tsc timed out"], error_count=1)

    def diagnose_errors(self, compile_result: CompileResult) -> list[FixAction]:
        fixes = []
        for error in compile_result.errors[:20]:
            # Cannot find module
            m = re.search(r"Cannot find module '([^']+)'", error)
            if m:
                fixes.append(FixAction(
                    file_path="", action="add_import",
                    description=f"Missing module: {m.group(1)}",
                ))
            # Cannot find name
            m = re.search(r"Cannot find name '([^']+)'", error)
            if m:
                fixes.append(FixAction(
                    file_path="", action="create_type_stub",
                    description=f"Missing type: {m.group(1)}",
                ))
        return fixes

    def apply_fixes(self, fixes: list[FixAction]) -> dict:
        applied = 0
        for fix in fixes:
            if fix.action == "add_import" and fix.file_path and os.path.isfile(fix.file_path):
                content = Path(fix.file_path).read_text(encoding="utf-8")
                if fix.content and fix.content not in content:
                    content = fix.content + "\n" + content
                    Path(fix.file_path).write_text(content, encoding="utf-8")
                    applied += 1
        return {"applied": applied, "total": len(fixes)}

    def run_tests(self) -> dict:
        try:
            subprocess.run(["npm", "--version"], capture_output=True, timeout=10)
        except (FileNotFoundError, subprocess.TimeoutExpired):
            return {"status": "skipped", "reason": "npm not available"}
        try:
            result = subprocess.run(
                ["npm", "test", "--", "--passWithNoTests"],
                cwd=str(self.project_dir),
                capture_output=True, text=True, timeout=120,
            )
            return {"status": "passed" if result.returncode == 0 else "failed"}
        except subprocess.TimeoutExpired:
            return {"status": "timeout"}
