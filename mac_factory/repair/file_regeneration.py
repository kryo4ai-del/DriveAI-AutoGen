"""Tier 4: File Regeneration Agent — regenerates Swift files completely when Repair Loop fails.

Unlike LLM Repair (Tier 2) which patches small errors, this agent regenerates
entire files with full feature context, related file analysis, and the
no-third-party-deps constraint.
"""
import os
import re
import litellm
from dotenv import load_dotenv

load_dotenv(os.path.join(os.path.dirname(os.path.dirname(__file__)), ".env"))

NO_THIRD_PARTY_RULE = """WICHTIGE REGELN:
1. Verwende KEINE Third-Party Libraries (kein GRDB, kein Realm, kein Alamofire,
   kein Kingfisher, kein SnapKit, kein SwiftyJSON, etc.). Nutze NUR Swift-Standard:
   - UserDefaults fuer einfache Key-Value-Persistenz
   - FileManager + Codable/JSONEncoder fuer komplexere Daten
   - URLSession fuer Netzwerk-Requests
   - Core Data NUR wenn es im Projekt bereits konfiguriert ist
2. Halte die Loesung so SIMPEL wie moeglich.
3. Die Datei muss SOFORT kompilieren — keine TODOs, keine Platzhalter, kein '...'.
4. Behalte die gleichen public Interfaces (Struct/Class-Namen, Method-Signaturen)
   damit andere Dateien die diese Datei importieren weiterhin funktionieren.
5. Wenn die Datei einen Error-Type definiert, stelle sicher dass er
   Error/LocalizedError konform ist.
6. Jede Datei MUSS mit import Foundation oder import SwiftUI beginnen.
7. KEIN Pseudocode, KEINE Kommentar-Beispiele als Code."""


class FileRegenerationAgent:
    def __init__(self, config: dict):
        regen_cfg = config.get("regeneration", {})
        self.model = regen_cfg.get("model", "claude-sonnet-4-6")
        self.max_tokens = regen_cfg.get("max_tokens", 8000)
        self.max_context_files = regen_cfg.get("max_context_files", 10)
        self.max_context_escalated = regen_cfg.get("max_context_files_escalated", 15)
        self.max_files_per_cycle = regen_cfg.get("max_files_per_cycle", 20)

        self.total_cost = 0.0
        self.total_calls = 0
        self.total_input_tokens = 0
        self.total_output_tokens = 0
        self.attempt_counts = {}  # filepath → number of regeneration attempts
        self.file_results = []  # per-file tracking

    def regenerate_files(self, failed_files: list, error_details: list,
                        project_dir: str) -> dict:
        """Regenerate failed Swift files with full context."""
        # Group errors by file
        errors_by_file = {}
        for e in error_details:
            fp = e.get("file", "")
            if fp:
                errors_by_file.setdefault(fp, []).append(e)

        # Limit to max files per cycle
        files_to_regen = failed_files[:self.max_files_per_cycle]
        regenerated = 0
        failed = 0

        print(f"    [Regen] {len(files_to_regen)} files to regenerate")

        for filepath in files_to_regen:
            if not os.path.isfile(filepath):
                continue

            # Track attempts
            self.attempt_counts[filepath] = self.attempt_counts.get(filepath, 0) + 1
            attempt = self.attempt_counts[filepath]

            file_errors = errors_by_file.get(filepath, [])
            success = self._regenerate_single_file(filepath, file_errors, project_dir, attempt)

            self.file_results.append({
                "file": os.path.basename(filepath),
                "path": filepath,
                "attempt": attempt,
                "success": success,
                "errors_before": len(file_errors),
            })

            if success:
                regenerated += 1
            else:
                failed += 1

        print(f"    [Regen] Done: {regenerated} regenerated, {failed} failed, cost: ${self.total_cost:.4f}")

        return {
            "any_regenerated": regenerated > 0,
            "regenerated": regenerated,
            "failed": failed,
            "cost": self.total_cost,
            "file_results": self.file_results[-len(files_to_regen):],
        }

    def _regenerate_single_file(self, filepath: str, errors: list,
                                project_dir: str, attempt: int) -> bool:
        """Regenerate a single Swift file."""
        filename = os.path.basename(filepath)
        print(f"      [Regen] {filename} (attempt {attempt})...")

        # Step 1: Collect context
        current_content = ""
        try:
            current_content = open(filepath, encoding="utf-8").read()
        except Exception:
            pass

        # Escalate context for stubborn files
        max_ctx = self.max_context_escalated if attempt >= 2 else self.max_context_files
        related_files = self._collect_context(filepath, project_dir, max_ctx)

        # Read build_spec if available
        feature_desc = self._read_build_spec(project_dir)

        # Format errors
        error_text = "\n".join(
            f"Line {e.get('line', '?')}: {e.get('message', '?')}" for e in errors
        ) if errors else "Unknown compile errors"

        # Format related files
        related_text = ""
        for rp, rc in related_files:
            related_text += f"\n--- {rp} ---\n{rc[:3000]}\n"

        # Step 2: Build prompt
        system_prompt = f"""Du bist ein erfahrener Swift/iOS-Entwickler. Eine Datei kompiliert nicht.
Generiere die Datei KOMPLETT NEU so dass sie sofort kompiliert.

{NO_THIRD_PARTY_RULE}

Antworte NUR mit dem kompletten Swift-Code. Keine Erklaerungen, kein Markdown."""

        user_prompt = f"""## Kaputte Datei:
Pfad: {filepath}
Aktueller Inhalt:
```swift
{current_content[:4000]}
```

## Build-Fehler:
{error_text}

{"## Feature-Beschreibung:" + chr(10) + feature_desc if feature_desc else ""}

## Verwandte Dateien die kompilieren:
{related_text if related_text else "(keine verwandten Dateien gefunden)"}

Generiere die komplette Datei {filename} neu. Beginne mit den import-Statements."""

        # Step 3: LLM call
        llm_model = self.model if "/" in self.model else f"anthropic/{self.model}"

        try:
            response = litellm.completion(
                model=llm_model,
                messages=[
                    {"role": "system", "content": system_prompt},
                    {"role": "user", "content": user_prompt},
                ],
                max_tokens=self.max_tokens,
                temperature=0.0,
            )

            output = response.choices[0].message.content.strip()
            cost = litellm.completion_cost(response)
            self.total_cost += cost
            self.total_calls += 1
            self.total_input_tokens += response.usage.prompt_tokens
            self.total_output_tokens += response.usage.completion_tokens

        except Exception as e:
            print(f"        LLM Error: {e}")
            return False

        # Strip markdown fences if present
        if output.startswith("```"):
            output = re.sub(r'^```\w*\n', '', output)
            output = re.sub(r'\n```$', '', output)
            output = output.strip()

        # Step 4: Validate
        if not self._validate_output(output, filename):
            print(f"        Validation failed for {filename}")
            return False

        # Write
        with open(filepath, "w", encoding="utf-8") as f:
            f.write(output)
        print(f"        Regenerated: {filename} — ${cost:.4f}")
        return True

    def _validate_output(self, output: str, filename: str) -> bool:
        """Basic validation that output looks like valid Swift."""
        if not output or len(output) < 30:
            return False
        if "import " not in output:
            return False
        # Must contain at least one type declaration
        has_type = any(kw in output for kw in ("struct ", "class ", "enum ", "protocol ", "extension "))
        if not has_type:
            return False
        # Reject if it contains placeholder patterns
        if "{ ... }" in output or "\n    ...\n" in output:
            return False
        return True

    def _collect_context(self, filepath: str, project_dir: str,
                        max_files: int) -> list:
        """Collect related files for context. Returns [(relative_path, content)]."""
        filename = os.path.basename(filepath)
        name_stem = os.path.splitext(filename)[0]
        file_dir = os.path.dirname(filepath)
        related = []
        seen = {os.path.abspath(filepath)}

        # Strategy 1: Same name prefix (e.g., Performance* for PerformanceStorageError)
        # Find common prefix (at least 4 chars)
        prefix = ""
        for i in range(len(name_stem), 3, -1):
            candidate = name_stem[:i]
            if candidate[0].isupper() and len(candidate) >= 4:
                prefix = candidate
                break

        # Strategy 2: Files in same directory
        if os.path.isdir(file_dir):
            for f in sorted(os.listdir(file_dir)):
                if len(related) >= max_files:
                    break
                if not f.endswith(".swift"):
                    continue
                fp = os.path.join(file_dir, f)
                if os.path.abspath(fp) in seen:
                    continue
                # Prioritize prefix matches
                if prefix and f.startswith(prefix):
                    content = self._safe_read(fp)
                    if content:
                        related.insert(0, (os.path.relpath(fp, project_dir), content))
                        seen.add(os.path.abspath(fp))

        # Strategy 3: Files that reference or are referenced by this file
        if os.path.isdir(file_dir):
            for f in sorted(os.listdir(file_dir)):
                if len(related) >= max_files:
                    break
                if not f.endswith(".swift"):
                    continue
                fp = os.path.join(file_dir, f)
                if os.path.abspath(fp) in seen:
                    continue
                content = self._safe_read(fp)
                if content:
                    related.append((os.path.relpath(fp, project_dir), content))
                    seen.add(os.path.abspath(fp))

        # Strategy 4 (escalated): Search other directories too
        if len(related) < max_files:
            for subdir in ("Models", "Services", "ViewModels", "Views", "App"):
                d = os.path.join(project_dir, subdir)
                if not os.path.isdir(d) or d == file_dir:
                    continue
                for f in sorted(os.listdir(d)):
                    if len(related) >= max_files:
                        break
                    if not f.endswith(".swift"):
                        continue
                    fp = os.path.join(d, f)
                    if os.path.abspath(fp) in seen:
                        continue
                    # Only include if name-related
                    if prefix and prefix.lower() in f.lower():
                        content = self._safe_read(fp)
                        if content:
                            related.append((os.path.relpath(fp, project_dir), content))
                            seen.add(os.path.abspath(fp))

        return related[:max_files]

    def _safe_read(self, filepath: str) -> str:
        """Read file, return empty string on error."""
        try:
            return open(filepath, encoding="utf-8").read()
        except Exception:
            return ""

    def _read_build_spec(self, project_dir: str) -> str:
        """Read build_spec.yaml if it exists."""
        for name in ("build_spec.yaml", "build_spec.yml", "project_context.md"):
            path = os.path.join(project_dir, name)
            if os.path.isfile(path):
                try:
                    content = open(path, encoding="utf-8").read()
                    return content[:2000]  # Cap at 2k tokens
                except Exception:
                    pass
        return ""

    def get_stubborn_files(self) -> list:
        """Return files that needed 2+ regeneration attempts."""
        return [fp for fp, count in self.attempt_counts.items() if count >= 2]

    def get_cost_summary(self) -> dict:
        return {
            "total_cost": round(self.total_cost, 4),
            "total_calls": self.total_calls,
            "total_input_tokens": self.total_input_tokens,
            "total_output_tokens": self.total_output_tokens,
        }
