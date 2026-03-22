"""Tier 1: Deterministic (free) Swift fixes based on Xcode error patterns."""
import os, re, shutil
from dataclasses import dataclass, field

FOUNDATION_TYPES = {"Data","URL","UUID","Date","Calendar","Timer","UserDefaults","TimeInterval","TimeZone","Locale","JSONEncoder","JSONDecoder","FileManager","Bundle","NotificationCenter","DispatchQueue","DateFormatter","LocalizedError"}
SWIFTUI_TYPES = {"View","State","Binding","Color","Text","Button","HStack","VStack","ZStack","NavigationStack","List","ForEach","ScrollView","Image","Label","Spacer","Divider","Font","Toggle","Picker","Slider","ProgressView","Sheet","Alert","NavigationLink","StateObject","ObservedObject","EnvironmentObject","Published","ObservableObject","Observable","GeometryReader","Canvas","AppStorage","Scene","WindowGroup","TabView","Section","Form","Circle","Rectangle","RoundedRectangle","Animation"}
JUNK_NAMES = {"GeneratedHelpers","GeneratedCode","Helpers"}
FRAMEWORK_STUBS = {"Hashable","Equatable","Codable","Identifiable","Comparable","Sendable","Task","MainActor","HStack","VStack","ZStack","Color","Preview","TimeInterval","LocalizedError","NSPersistentContainer","XCTest","XCTestCase","DriveAI","DriveAIDomain"}

@dataclass
class FixReport:
    quarantined: list = field(default_factory=list)
    fixed_files: list = field(default_factory=list)
    import_adds: int = 0
    lines_disabled: int = 0
    dupes_removed: int = 0
    @property
    def total_actions(self): return len(self.quarantined) + len(self.fixed_files)

class DeterministicFixes:
    def fix_all(self, errors, project_dir):
        from mac_agent.repair.xcode_error_parser import XcodeErrorParser
        report = FixReport()

        # Pre-pass: move test files out of app target
        self._move_tests(project_dir, report)

        # Pre-pass: ensure @main entry point exists
        self._ensure_main_entry(project_dir, errors, report)

        grouped = XcodeErrorParser().group_by_file(errors)
        for fp, ferrs in grouped.items():
            if not os.path.isfile(fp): continue
            if self._should_quarantine(fp, ferrs):
                self._quarantine(fp, project_dir); report.quarantined.append(fp); continue
            try: content = open(fp, encoding="utf-8").read()
            except: continue
            orig = content
            content = self._fix_imports(content, ferrs)
            content = self._fix_top_level(content, ferrs)
            content = self._fix_enum(content)
            content = self._fix_pseudo(content)
            if content != orig:
                open(fp,"w",encoding="utf-8").write(content); report.fixed_files.append(fp)
        return report

    def _move_tests(self, project_dir, report):
        """Move *Tests.swift from Models/ to Tests/ (they can't be in the app target)."""
        for subdir in ["Models", "Views", "ViewModels", "Services"]:
            src = os.path.join(project_dir, subdir)
            if not os.path.isdir(src): continue
            for f in os.listdir(src):
                if f.endswith("Tests.swift"):
                    tests_dir = os.path.join(project_dir, "Tests")
                    os.makedirs(tests_dir, exist_ok=True)
                    dest = os.path.join(tests_dir, f)
                    if not os.path.exists(dest):
                        shutil.move(os.path.join(src, f), dest)
                        report.fixed_files.append(dest)

    def _ensure_main_entry(self, project_dir, errors, report):
        """If linker reports missing _main, create a @main App entry point."""
        has_main_error = any("_main" in e.message or "Undefined symbols" in e.message
                           for e in errors if e.severity == "error")
        if not has_main_error: return

        # Check if @main already exists
        for root, dirs, files in os.walk(project_dir):
            if "quarantine" in root or "Tests" in root: continue
            for f in files:
                if f.endswith(".swift"):
                    try:
                        c = open(os.path.join(root, f), encoding="utf-8").read()
                        if "@main" in c: return
                    except: pass

        # Infer app name from project.yml or directory name
        app_name = os.path.basename(project_dir)
        views_dir = os.path.join(project_dir, "Views")
        os.makedirs(views_dir, exist_ok=True)
        entry = os.path.join(views_dir, f"{app_name}App.swift")
        if not os.path.exists(entry):
            content = f"import SwiftUI\n\n@main\nstruct {app_name}App: App {{\n    var body: some Scene {{\n        WindowGroup {{\n            ContentView()\n        }}\n    }}\n}}\n"
            open(entry, "w", encoding="utf-8").write(content)
            # Also create ContentView if missing
            cv = os.path.join(views_dir, "ContentView.swift")
            if not os.path.exists(cv):
                open(cv, "w", encoding="utf-8").write('import SwiftUI\n\nstruct ContentView: View {\n    var body: some View {\n        Text("Hello, World!")\n    }\n}\n')
            report.fixed_files.append(entry)

    def _should_quarantine(self, fp, errors):
        name = os.path.splitext(os.path.basename(fp))[0]
        if name in JUNK_NAMES: return True
        if name in FRAMEWORK_STUBS: return True
        ec = sum(1 for e in errors if e.severity=="error")
        if ec > 10: return True
        if all(e.error_code=="top_level_code" for e in errors if e.severity=="error") and ec>0: return True
        try:
            c = open(fp,encoding="utf-8").read()
            if "{ ... }" in c or c.count(" ... ")>2: return True
        except: pass
        return False

    def _quarantine(self, fp, project_dir):
        qd = os.path.join(project_dir,"quarantine"); os.makedirs(qd,exist_ok=True)
        dest = os.path.join(qd, os.path.basename(fp))
        if not os.path.exists(dest): shutil.move(fp, dest)

    def _fix_imports(self, content, errors):
        nf = ns = False
        for e in errors:
            if e.severity!="error" or e.error_code not in ("missing_type","missing_identifier"): continue
            m = re.search(r"'(\w+)'", e.message)
            if not m: continue
            sym = m.group(1)
            if sym in FOUNDATION_TYPES: nf=True
            if sym in SWIFTUI_TYPES: ns=True
        lines = content.split(chr(10))
        existing = {l.strip() for l in lines if l.strip().startswith("import ")}
        adds = []
        if ns and "import SwiftUI" not in existing: adds.append("import SwiftUI")
        if nf and "import Foundation" not in existing: adds.append("import Foundation")
        if adds:
            ip=0
            for i,ln in enumerate(lines):
                if ln.strip().startswith("import "): ip=i+1
            if ip==0: lines = adds + [""] + lines
            else:
                for j,a in enumerate(adds): lines.insert(ip+j, a)
            return chr(10).join(lines)
        return content

    def _fix_top_level(self, content, errors):
        tl = [e for e in errors if e.error_code=="top_level_code"]
        if not tl: return content
        lines = content.split(chr(10))
        for e in tl:
            idx = e.line-1
            if 0<=idx<len(lines): lines[idx] = "// [AUTO-DISABLED] " + lines[idx]
        return chr(10).join(lines)

    def _fix_enum(self, content):
        pat = re.compile(r"(enum\s+\w+)\s*:\s*(String|Int|Double|Float)(\s*\{)")
        if pat.search(content) and re.search(r"case\s+\w+\s*\(", content):
            content = pat.sub(r"", content)
        return content

    def _fix_pseudo(self, content):
        lines = content.split(chr(10))
        out = []
        for ln in lines:
            if ln.strip()=="...":
                indent = ln[:len(ln)-len(ln.lstrip())]
                out.append(indent + 'fatalError("Not implemented")')
            else: out.append(ln)
        return chr(10).join(out)
