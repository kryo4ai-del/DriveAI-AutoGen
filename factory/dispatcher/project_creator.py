"""Auto-creates project directory from pipeline output. No LLM — deterministic only."""
import json
import os
from datetime import datetime
from pathlib import Path

_ROOT = Path(__file__).resolve().parent.parent.parent


class ProjectCreator:
    """Creates a project directory from Pre-Production + Roadbook output."""

    def create_from_pipeline_output(self, product, pre_prod_dir="", mvp_scope_dir=""):
        slug = product.title.lower().replace(" ", "").replace("-", "")
        project_dir = _ROOT / "projects" / slug

        # Name Gate soft check — warn if no validation, but don't block
        ng_report = project_dir / "name_gate_report.json"
        ng_data = _ROOT / "factory" / "name_gate" / "data" / f"{slug}_report.json"
        if not ng_report.exists() and not ng_data.exists():
            print(f"  [ProjectCreator] WARNING: '{product.title}' has no Name Gate "
                  f"validation. Proceeding in legacy mode.")

        project_dir.mkdir(parents=True, exist_ok=True)
        (project_dir / "specs").mkdir(exist_ok=True)

        platforms = self._detect_platforms(pre_prod_dir)
        primary = next(
            (p for p in ["ios", "android", "web"] if platforms.get(p, {}).get("status") == "active"),
            "ios",
        )
        lang_map = {"ios": "swift", "android": "kotlin", "web": "typescript"}

        # project.yaml
        ios_status = platforms.get("ios", {}).get("status", "active")
        android_status = platforms.get("android", {}).get("status", "planned")
        web_status = platforms.get("web", {}).get("status", "planned")
        extraction = lang_map.get(primary, "swift")
        today = datetime.now().strftime("%Y-%m-%d")
        desc = product.idea[:200].replace('"', "'")

        yaml_lines = [
            f'project:',
            f'  name: "{product.title}"',
            f'  slug: "{slug}"',
            f'  description: "{desc}"',
            f'  version: "1.0.0"',
            f'',
            f'lines:',
            f'  ios:',
            f'    status: {ios_status}',
            f'    language: swift',
            f'    framework: swiftui',
            f'    architecture: mvvm',
            f'    build_tool: xcodegen',
            f'    min_target: "iOS 17.0"',
            f'  android:',
            f'    status: {android_status}',
            f'    language: kotlin',
            f'    framework: jetpack_compose',
            f'  web:',
            f'    status: {web_status}',
            f'    language: typescript',
            f'    framework: nextjs',
            f'  backend:',
            f'    status: disabled',
            f'',
            f'pipeline:',
            f'  code_extraction: {extraction}',
            f'  templates: [feature, screen, viewmodel, service]',
            f'  operations_layer: true',
            f'  cd_gate: true',
            f'',
            f'metadata:',
            f'  created: "{today}"',
            f'  status: "development"',
        ]
        (project_dir / "project.yaml").write_text("\n".join(yaml_lines), encoding="utf-8")

        # project_context.md
        ctx_map = {
            "ios": _ROOT / "projects" / "askfin_v1-1" / "project_context.md",
            "android": _ROOT / "projects" / "askfin_android" / "project_context.md",
            "web": _ROOT / "projects" / "askfin_web" / "project_context.md",
        }
        ctx_src = ctx_map.get(primary)
        if ctx_src and ctx_src.exists():
            ctx = ctx_src.read_text(encoding="utf-8")
            ctx = ctx.replace("AskFin", product.title).replace("askfin", slug)
        else:
            ctx = f"# {product.title} -- Project Context\n\n## Architecture\n- Platform: {primary}\n"
        (project_dir / "project_context.md").write_text(ctx, encoding="utf-8")

        # build_spec.yaml
        features = self._extract_features(product, pre_prod_dir, mvp_scope_dir)
        spec_lines = [
            f'project: "{product.title}"',
            f'description: "{desc}"',
            f'build_mode: layered',
            f'target_lines:',
            f'  - {primary}',
            f'',
            f'features:',
        ]
        prev_name = None
        for i, feat in enumerate(features):
            name = feat.get("name", f"Feature{i+1}")
            ftype = feat.get("type", "feature")
            fdesc = feat.get("description", "")[:200].replace('"', "'")
            deps = f'["{prev_name}"]' if prev_name and i > 0 else "[]"
            spec_lines.extend([
                f'',
                f'  - name: "{name}"',
                f'    type: {ftype}',
                f'    priority: {feat.get("priority", 1)}',
                f'    description: "{fdesc}"',
                f'    depends_on: {deps}',
            ])
            prev_name = name
        (project_dir / "specs" / "build_spec.yaml").write_text("\n".join(spec_lines), encoding="utf-8")


        # iOS App Entry Point
        if primary == 'ios':
            app_name = product.title.replace(' ', '')
            views_dir = project_dir / 'Views'
            views_dir.mkdir(parents=True, exist_ok=True)
            app_swift = views_dir / (app_name + 'App.swift')
            if not app_swift.exists():
                parts = ['import SwiftUI', '', '@main',
                         'struct ' + app_name + 'App: App {',
                         '    var body: some Scene {',
                         '        WindowGroup {',
                         '            ContentView()',
                         '        }',
                         '    }',
                         '}']
                app_swift.write_text(chr(10).join(parts), encoding='utf-8')
                print(f'    @main entry point: {app_name}App.swift')

        # README
        (project_dir / "README.md").write_text(
            f"# {product.title}\n\n{product.idea}\n\nBuilt by DriveAI Swarm Factory.\n",
            encoding="utf-8",
        )

        print(f"  [ProjectCreator] Created: {project_dir}")
        print(f"    project.yaml, project_context.md, build_spec.yaml ({len(features)} features)")
        return str(project_dir)

    def _detect_platforms(self, pre_prod_dir):
        platforms = {"ios": {"status": "active"}, "android": {"status": "planned"}, "web": {"status": "planned"}}
        if not pre_prod_dir:
            return platforms
        concept = os.path.join(pre_prod_dir, "concept_brief.md")
        if os.path.exists(concept):
            content = open(concept, encoding="utf-8", errors="ignore").read().lower()
            if "nur ios" in content or "ios only" in content:
                platforms["android"]["status"] = "disabled"
                platforms["web"]["status"] = "disabled"
            if "web app" in content or "browser" in content:
                platforms["web"]["status"] = "active"
        return platforms

    def _extract_features(self, product, pre_prod_dir, mvp_scope_dir):
        """Extract features — MVP scope first, concept brief filtered, domain fallback."""
        # Try MVP scope JSON
        if mvp_scope_dir and os.path.isdir(mvp_scope_dir):
            for fn in os.listdir(mvp_scope_dir):
                if "feature" in fn.lower() and fn.endswith(".json"):
                    try:
                        data = json.load(open(os.path.join(mvp_scope_dir, fn), encoding="utf-8"))
                        if isinstance(data, list) and data:
                            return data[:20]
                        if isinstance(data, dict) and "features" in data:
                            return data["features"][:20]
                    except Exception:
                        pass

        # Try concept brief — filter for BUILDABLE features
        if pre_prod_dir:
            features = self._parse_buildable_features(pre_prod_dir)
            # Quality check: skip if features look like analytical garbage
            good = [f for f in features if len(f['name']) > 5 and not f['name'][0].isdigit()
                    and not any(c.isdigit() for c in f['name'][:3])]
            if len(good) >= 3:
                return good

        # Domain-specific fallback
        return self._generate_domain_features(product.idea, product.title)

    def _parse_buildable_features(self, pre_prod_dir):
        """Extract only buildable features from concept brief."""
        concept = os.path.join(pre_prod_dir, "concept_brief.md")
        if not os.path.exists(concept):
            return []
        content = open(concept, encoding="utf-8", errors="ignore").read()

        FEATURE_KW = [
            "screen", "view", "page", "button", "timer", "animation",
            "anzeige", "display", "liste", "list", "eingabe", "input",
            "auswahl", "selection", "navigation", "speichern", "save",
            "tracking", "statistik", "exercise", "mode", "modus",
            "setting", "profil", "verlauf", "history", "progress",
        ]
        SKIP_KW = [
            "studie", "prozent", "%", "markt", "market", "wettbewerb",
            "zielgruppe", "umsatz", "revenue", "trend", "analyse",
            "laut", "belegt", "zeigt", "mehrheit", "durchschnitt",
        ]

        features = []
        for line in content.split("\n"):
            s = line.strip()
            if not s or len(s) < 15 or len(s) > 200:
                continue
            if not (s[0].isdigit() or s.startswith("- ") or s.startswith("* ")):
                continue
            clean = s.lstrip("0123456789.-*) ").strip()
            cl = clean.lower()
            if any(kw in cl for kw in SKIP_KW):
                continue
            if any(kw in cl for kw in FEATURE_KW):
                words = clean.split()[:3]
                words = [w.strip("(),-:;.") for w in words if len(w.strip("(),-:;.")) > 2]
                name = "".join(w.capitalize() for w in words[:3])
                name = "".join(ch for ch in name if ch.isalnum())[:30]
                if name and len(name) > 3:
                    features.append({
                        "name": name, "type": "feature",
                        "description": clean, "priority": 1,
                    })

        seen = set()
        unique = []
        for f in features:
            k = f["name"].lower()
            if k not in seen:
                seen.add(k)
                unique.append(f)
        return unique[:15]

    def _generate_domain_features(self, idea, title):
        """Generate features based on app domain keywords."""
        il = idea.lower()

        if any(w in il for w in ["atem", "breath", "breathing", "meditation"]):
            return [
                {"name": "ExerciseSelection", "type": "feature", "priority": 1,
                 "description": "Main screen with exercise cards (4-7-8, Box Breathing, Calm)"},
                {"name": "BreathingAnimation", "type": "feature", "priority": 1,
                 "description": "Animated circle expanding/contracting with breath rhythm, timer"},
                {"name": "SessionComplete", "type": "screen", "priority": 2,
                 "description": "Session completion with duration and encouragement"},
                {"name": "WeeklyStats", "type": "screen", "priority": 2,
                 "description": "Weekly practice stats showing minutes per day"},
                {"name": "Settings", "type": "screen", "priority": 3,
                 "description": "App settings: sound, haptic feedback, theme"},
            ]

        if any(w in il for w in ["quiz", "learn", "exam", "training", "study"]):
            return [
                {"name": "QuestionPractice", "type": "feature", "priority": 1,
                 "description": "Core question practice with answer feedback"},
                {"name": "CategorySelection", "type": "screen", "priority": 1,
                 "description": "Topic/category selection screen"},
                {"name": "ProgressTracking", "type": "feature", "priority": 2,
                 "description": "Track answers and improvement"},
                {"name": "ResultsSummary", "type": "screen", "priority": 2,
                 "description": "Session results with score and weak areas"},
            ]

        if any(w in il for w in ["game", "puzzle", "match", "play"]):
            return [
                {"name": "GameBoard", "type": "feature", "priority": 1,
                 "description": "Main game board with core mechanics"},
                {"name": "ScoreSystem", "type": "feature", "priority": 1,
                 "description": "Score tracking and level progression"},
                {"name": "GameMenu", "type": "screen", "priority": 2,
                 "description": "Main menu with play and settings"},
                {"name": "GameOver", "type": "screen", "priority": 2,
                 "description": "Game over screen with score and retry"},
            ]

        # Generic fallback
        t = title
        return [
            {"name": f"{t}Core", "type": "feature", "priority": 1,
             "description": f"Core feature of {t}"},
            {"name": f"{t}Home", "type": "screen", "priority": 1,
             "description": f"Home screen for {t}"},
            {"name": f"{t}Stats", "type": "feature", "priority": 2,
             "description": f"Stats for {t}"},
            {"name": f"{t}Settings", "type": "screen", "priority": 3,
             "description": f"Settings for {t}"},
        ]