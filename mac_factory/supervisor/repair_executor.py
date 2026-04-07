"""
DriveAI Mac Factory — Repair Executor

Translates ErrorAnalyzer strategies into actual file operations.
"""

import os
import re
import shutil
from pathlib import Path
from dataclasses import dataclass, field
from typing import Optional


@dataclass
class RepairResult:
    action: str = ""
    file_path: str = ""
    success: bool = False
    errors_before: int = 0
    errors_after: int = 0
    cost: float = 0.0
    detail: str = ""


class RepairExecutor:
    SWIFT_STARTERS = (
        'import ', '//', '/*', '@', 'struct ', 'class ', 'enum ',
        'protocol ', 'extension ', 'public ', 'private ', 'internal ',
        'final ', 'open ', '#if', 'func ', 'let ', 'var ', 'actor ',
        'fileprivate ', 'typealias '
    )

    def __init__(self, project_dir: str, safety_guard=None, llm_client=None):
        self.project_dir = project_dir
        self.safety_guard = safety_guard
        self.llm_client = llm_client
        self.total_cost = 0.0
        self.actions_taken = []

    def execute(self, cluster) -> RepairResult:
        action = cluster.recommended_action
        filepath = cluster.file_path

        if action in ("repair_tier2", "deep_repair") and self.safety_guard:
            if not self.safety_guard.check():
                return RepairResult(
                    action=action, file_path=filepath, success=False,
                    detail=f"Safety guard stopped: {self.safety_guard.stop_reason}"
                )

        print(f"[Repair] {action} -> {filepath or 'multiple files'} ({cluster.error_count} errors)")

        dispatch = {
            "deduplicate": self._empty_file,
            "empty_file": self._empty_file,
            "quarantine": self._quarantine_file,
            "repair_tier1": self._repair_tier1,
            "repair_tier2": self._repair_tier2,
            "deep_repair": self._deep_repair,
            "iterative_stub": self._stub_file,
        }

        handler = dispatch.get(action, self._repair_tier2)
        result = handler(filepath, cluster)

        self.actions_taken.append(result)
        if result.cost > 0:
            self.total_cost += result.cost

        return result

    def _empty_file(self, filepath: str, cluster) -> RepairResult:
        full_path = self._resolve(filepath)
        if not full_path:
            return RepairResult(action="empty_file", file_path=filepath, success=False, detail="File not found")
        try:
            Path(full_path).write_text("import Foundation\n")
            return RepairResult(
                action="empty_file", file_path=filepath, success=True,
                detail=f"Emptied to import Foundation ({cluster.root_cause})"
            )
        except Exception as e:
            return RepairResult(action="empty_file", file_path=filepath, success=False, detail=str(e))

    def _quarantine_file(self, filepath: str, cluster) -> RepairResult:
        full_path = self._resolve(filepath)
        if not full_path:
            return RepairResult(action="quarantine", file_path=filepath, success=False, detail="File not found")
        try:
            quarantine_dir = os.path.join(self.project_dir, "quarantine")
            os.makedirs(quarantine_dir, exist_ok=True)
            filename = os.path.basename(full_path)
            dest = os.path.join(quarantine_dir, filename)
            shutil.copy2(full_path, dest)

            type_name = Path(filepath).stem
            stub = self._generate_stub(type_name, filepath)
            Path(full_path).write_text(stub)

            return RepairResult(
                action="quarantine", file_path=filepath, success=True,
                detail="Quarantined, replaced with stub"
            )
        except Exception as e:
            return RepairResult(action="quarantine", file_path=filepath, success=False, detail=str(e))

    def _repair_tier1(self, filepath: str, cluster) -> RepairResult:
        try:
            from mac_factory.supervisor.pre_build_cleanup import PreBuildCleanup
            cleanup = PreBuildCleanup(self.project_dir)
            added = cleanup.run_import_mapping(cluster.errors)
            return RepairResult(
                action="repair_tier1", file_path=filepath, success=added > 0,
                cost=0.0, detail=f"Added {added} imports"
            )
        except Exception as e:
            return RepairResult(
                action="repair_tier1", file_path=filepath, success=False,
                cost=0.0, detail=f"Tier1 failed: {e}"
            )

    def _repair_tier2(self, filepath: str, cluster) -> RepairResult:
        if not filepath:
            return RepairResult(action="repair_tier2", success=False, detail="No file path")
        full_path = self._resolve(filepath)
        if not full_path:
            return RepairResult(action="repair_tier2", file_path=filepath, success=False, detail="File not found")
        try:
            content = Path(full_path).read_text(errors='ignore')
        except Exception:
            return RepairResult(action="repair_tier2", file_path=filepath, success=False, detail="Cannot read file")

        error_desc = "\n".join(
            f"Line {e.get('line', '?')}: {e.get('message', '?')}"
            for e in cluster.errors[:10]
        )
        prompt = (
            f"Fix the following Swift file. It has {cluster.error_count} compile errors.\n\n"
            f"ERRORS:\n{error_desc}\n\n"
            f"CURRENT FILE CONTENT:\n```swift\n{content[:3000]}\n```\n\n"
            f"Write the COMPLETE fixed file. Output ONLY valid Swift code. "
            f"No markdown, no explanations, no code fences."
        )

        try:
            import litellm
            if self.safety_guard and not self.safety_guard.check():
                return RepairResult(action="repair_tier2", file_path=filepath, success=False,
                                    detail=f"Safety stopped: {self.safety_guard.stop_reason}")

            response = litellm.completion(
                model="claude-sonnet-4-6",
                messages=[{"role": "user", "content": prompt}],
                max_tokens=4000,
                temperature=0
            )
            cost = litellm.completion_cost(response) or 0.0
            if self.safety_guard:
                self.safety_guard.record_llm_call(
                    "claude-sonnet-4-6",
                    response.usage.prompt_tokens,
                    response.usage.completion_tokens,
                    cost
                )

            new_content = self._sanitize_llm_output(response.choices[0].message.content)
            if not new_content:
                return RepairResult(action="repair_tier2", file_path=filepath, success=False,
                                    cost=cost, detail="LLM output was empty after sanitization")
            Path(full_path).write_text(new_content)
            return RepairResult(
                action="repair_tier2", file_path=filepath, success=True,
                cost=cost, detail=f"LLM repair applied (${cost:.4f})"
            )
        except Exception as e:
            return RepairResult(action="repair_tier2", file_path=filepath, success=False,
                                detail=f"LLM error: {e}")

    def _deep_repair(self, filepath: str, cluster) -> RepairResult:
        full_path = self._resolve(filepath)
        if not full_path:
            return RepairResult(action="deep_repair", file_path=filepath, success=False, detail="File not found")
        try:
            content = Path(full_path).read_text(errors='ignore')
        except Exception:
            return RepairResult(action="deep_repair", file_path=filepath, success=False, detail="Cannot read file")

        type_name = Path(filepath).stem
        context = self._find_context(type_name, filepath)
        error_desc = "\n".join(
            f"Line {e.get('line', '?')}: {e.get('message', '?')}"
            for e in cluster.errors[:15]
        )

        prompt = (
            f"Rewrite this Swift file completely. It has {cluster.error_count} errors.\n\n"
            f"FILE: {filepath}\n"
            f"ERRORS:\n{error_desc}\n\n"
            f"CURRENT CONTENT:\n```swift\n{content[:2000]}\n```\n\n"
            f"CONTEXT - other files that reference '{type_name}':\n{context}\n\n"
            f"Write the COMPLETE rewritten file. Define '{type_name}' to satisfy "
            f"all references from context files. Output ONLY valid Swift code. "
            f"No markdown, no explanations."
        )

        try:
            import litellm
            if self.safety_guard and not self.safety_guard.check():
                return RepairResult(action="deep_repair", file_path=filepath, success=False,
                                    detail=f"Safety stopped: {self.safety_guard.stop_reason}")
            response = litellm.completion(
                model="claude-sonnet-4-6",
                messages=[{"role": "user", "content": prompt}],
                max_tokens=8000,
                temperature=0
            )
            cost = litellm.completion_cost(response) or 0.0
            if self.safety_guard:
                self.safety_guard.record_llm_call(
                    "claude-sonnet-4-6",
                    response.usage.prompt_tokens,
                    response.usage.completion_tokens,
                    cost
                )
            new_content = self._sanitize_llm_output(response.choices[0].message.content)
            if not new_content:
                return RepairResult(action="deep_repair", file_path=filepath, success=False,
                                    cost=cost, detail="LLM output empty after sanitization")
            Path(full_path).write_text(new_content)
            return RepairResult(
                action="deep_repair", file_path=filepath, success=True,
                cost=cost, detail=f"Deep repair applied (${cost:.4f})"
            )
        except Exception as e:
            return RepairResult(action="deep_repair", file_path=filepath, success=False,
                                detail=f"Deep repair error: {e}")

    def _stub_file(self, filepath: str, cluster) -> RepairResult:
        full_path = self._resolve(filepath)
        if not full_path:
            return RepairResult(action="iterative_stub", file_path=filepath, success=False, detail="File not found")
        type_name = Path(filepath).stem
        stub = self._generate_stub(type_name, filepath)
        try:
            Path(full_path).write_text(stub)
            return RepairResult(
                action="iterative_stub", file_path=filepath, success=True,
                detail=f"Stubbed to minimal {type_name}"
            )
        except Exception as e:
            return RepairResult(action="iterative_stub", file_path=filepath, success=False, detail=str(e))

    def _generate_stub(self, type_name: str, filepath: str) -> str:
        if "View" in type_name and "Model" not in type_name:
            return (f"import SwiftUI\n\nstruct {type_name}: View {{\n"
                    f"    var body: some View {{\n        EmptyView()\n    }}\n}}\n")
        elif "Protocol" in type_name:
            return f"import Foundation\n\nprotocol {type_name} {{}}\n"
        elif "Error" in type_name:
            return f"import Foundation\n\nenum {type_name}: Error {{\n    case unknown\n}}\n"
        elif "ViewModel" in type_name:
            return (f"import Foundation\nimport Combine\n\n"
                    f"class {type_name}: ObservableObject {{\n    init() {{}}\n}}\n")
        else:
            return f"import Foundation\n\nstruct {type_name} {{}}\n"

    def _sanitize_llm_output(self, output: str) -> Optional[str]:
        if not output:
            return None
        content = output.strip()
        content = re.sub(r'```swift\s*\n?', '', content)
        content = re.sub(r'```\s*\n?', '', content)

        lines = content.split('\n')
        start_idx = 0
        for i, line in enumerate(lines):
            stripped = line.strip()
            if stripped and any(stripped.startswith(s) for s in self.SWIFT_STARTERS):
                start_idx = i
                break

        if start_idx > 0:
            lines = lines[start_idx:]

        # Remove trailing explanation
        end_idx = len(lines)
        for i in range(len(lines) - 1, -1, -1):
            stripped = lines[i].strip()
            if not stripped:
                continue
            if (any(stripped.startswith(s) for s in self.SWIFT_STARTERS) or
                    stripped.startswith('}') or stripped.startswith(')')):
                end_idx = i + 1
                break
            # Long line that looks like English explanation
            if len(stripped) > 50 and ' ' in stripped and not stripped.endswith(('{', '}', ')', ']', ',')):
                continue
            end_idx = i + 1
            break

        result = '\n'.join(lines[:end_idx]).strip()
        if not result or len(result) < 10:
            return None
        return result + '\n'

    def _find_context(self, type_name: str, exclude_path: str, max_files: int = 5) -> str:
        context_parts = []
        exclude_name = os.path.basename(exclude_path)
        found = 0
        for swift_file in Path(self.project_dir).rglob("*.swift"):
            if swift_file.name == exclude_name:
                continue
            if any(part in {'build', 'quarantine', '.git', 'DerivedData'} for part in swift_file.parts):
                continue
            try:
                content = swift_file.read_text(errors='ignore')
                if type_name in content:
                    excerpt = '\n'.join(content.split('\n')[:50])
                    context_parts.append(f"--- {swift_file.name} ---\n{excerpt}")
                    found += 1
                    if found >= max_files:
                        break
            except Exception:
                continue
        return '\n\n'.join(context_parts) if context_parts else "No context files found."

    def _resolve(self, filepath: str) -> Optional[str]:
        if not filepath:
            return None
        if os.path.isabs(filepath) and os.path.exists(filepath):
            return filepath
        candidate = os.path.join(self.project_dir, filepath)
        if os.path.exists(candidate):
            return candidate
        filename = os.path.basename(filepath)
        for f in Path(self.project_dir).rglob(filename):
            if f.is_file():
                return str(f)
        return None

    def get_summary(self) -> dict:
        by_action = {}
        for r in self.actions_taken:
            if r.action not in by_action:
                by_action[r.action] = {"count": 0, "success": 0, "cost": 0.0}
            by_action[r.action]["count"] += 1
            if r.success:
                by_action[r.action]["success"] += 1
            by_action[r.action]["cost"] += r.cost
        return {
            "total_actions": len(self.actions_taken),
            "total_cost": round(self.total_cost, 4),
            "by_action": by_action
        }
