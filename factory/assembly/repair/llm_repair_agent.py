"""LLM-powered code repair agent. Fixes structural problems
that deterministic fixers cannot handle.

Central service — works for Swift, Kotlin, and TypeScript.
Uses Anthropic Claude API directly (not AutoGen pipeline).
"""

import json
import os
import re
import urllib.request
from dataclasses import dataclass, field
from datetime import datetime
from pathlib import Path

from factory.assembly.repair.error_parser import CompilerError
from config.model_router import get_fallback_model


@dataclass
class RepairResult:
    success: bool = False
    original_content: str = ""
    fixed_content: str = ""
    errors_addressed: int = 0
    reason: str = ""
    model_used: str = ""
    tokens_in: int = 0
    tokens_out: int = 0


@dataclass
class BatchRepairResult:
    files_attempted: int = 0
    files_fixed: int = 0
    files_failed: int = 0
    total_errors_addressed: int = 0
    total_tokens_in: int = 0
    total_tokens_out: int = 0
    results: list = field(default_factory=list)

    def estimated_cost(self) -> float:
        """Rough cost estimate (Haiku: $0.25/MTok in, $1.25/MTok out)."""
        return (self.total_tokens_in * 0.25 + self.total_tokens_out * 1.25) / 1_000_000

    def summary(self) -> str:
        cost = self.estimated_cost()
        return (
            f"  LLM Repair: {self.files_fixed}/{self.files_attempted} files fixed, "
            f"{self.total_errors_addressed} errors addressed\n"
            f"  Tokens: ~{self.total_tokens_in + self.total_tokens_out:,} "
            f"(in: {self.total_tokens_in:,}, out: {self.total_tokens_out:,})\n"
            f"  Estimated cost: ${cost:.4f}"
        )


class LLMRepairAgent:
    """LLM-powered code repair agent."""

    def __init__(self, model: str = None,
                 api_key_env: str = "ANTHROPIC_API_KEY"):
        self.model = model or get_fallback_model("dev")
        self.api_key = os.environ.get(api_key_env, "")
        # Try loading from .env if not in environment
        if not self.api_key:
            env_path = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))), ".env")
            if os.path.isfile(env_path):
                for line in open(env_path):
                    if line.startswith(f"{api_key_env}="):
                        self.api_key = line.split("=", 1)[1].strip()
                        break

    def fix_file(self, file_path: str, file_content: str,
                 errors: list[CompilerError], language: str,
                 context: str = "") -> RepairResult:
        """Send a broken file to the LLM for repair."""
        if not self.api_key:
            return RepairResult(success=False, reason="No API key")

        prompt = self._build_repair_prompt(file_content, errors, language, context)
        response, tokens_in, tokens_out = self._call_api(prompt)
        fixed_content = self._extract_code(response, language)

        result = RepairResult(
            model_used=self.model,
            tokens_in=tokens_in,
            tokens_out=tokens_out,
        )

        if fixed_content and fixed_content != file_content:
            result.success = True
            result.original_content = file_content
            result.fixed_content = fixed_content
            result.errors_addressed = len(errors)
        else:
            result.success = False
            result.reason = "LLM returned unchanged or unparseable content"

        return result

    def fix_batch(self, file_errors: dict[str, list[CompilerError]],
                  project_dir: str, language: str,
                  max_files: int = 20, context: str = "") -> BatchRepairResult:
        """Fix multiple files, prioritizing files with most errors."""
        sorted_files = sorted(file_errors.items(), key=lambda x: len(x[1]), reverse=True)

        batch = BatchRepairResult()
        for file_path, errors in sorted_files[:max_files]:
            abs_path = os.path.join(project_dir, file_path) if not os.path.isabs(file_path) else file_path
            try:
                content = Path(abs_path).read_text(encoding="utf-8")
            except Exception:
                continue

            print(f"    [{batch.files_attempted + 1}/{min(len(sorted_files), max_files)}] "
                  f"{os.path.basename(file_path)} ({len(errors)} errors)...", end=" ")

            result = self.fix_file(file_path, content, errors, language, context)
            batch.files_attempted += 1
            batch.total_tokens_in += result.tokens_in
            batch.total_tokens_out += result.tokens_out

            if result.success:
                # Write fixed file back
                try:
                    Path(abs_path).write_text(result.fixed_content, encoding="utf-8")
                    batch.files_fixed += 1
                    batch.total_errors_addressed += result.errors_addressed
                    print("FIXED")
                except Exception:
                    batch.files_failed += 1
                    print("WRITE FAILED")
            else:
                batch.files_failed += 1
                print(f"SKIP ({result.reason[:40]})")

            batch.results.append((file_path, result))

        return batch

    def _build_repair_prompt(self, content: str, errors: list,
                             language: str, context: str) -> str:
        error_text = "\n".join(
            f"Line {e.line_number}: {e.message}" for e in errors[:20]
        )
        lang_name = {"kotlin": "Kotlin", "typescript": "TypeScript", "swift": "Swift"}.get(language, language)

        parts = [
            f"Fix the following {lang_name} file. It has compiler errors.",
            "",
            "COMPILER ERRORS:",
            error_text,
            "",
            f"CURRENT FILE CONTENT:",
            f"```{language}",
            content,
            "```",
        ]
        if context:
            parts.extend(["", "CONTEXT (related declarations):", context])

        parts.extend([
            "",
            "RULES:",
            "- Fix ONLY the compiler errors listed above",
            "- Do NOT change logic or behavior",
            "- Do NOT remove functionality",
            "- Add missing imports if needed",
            "- Fix type errors, missing parameters, incorrect syntax",
            "- If a type is referenced but undefined, create a minimal placeholder",
            f"- Return the COMPLETE fixed file inside a single ```{language} code block",
            "- No explanations, just the fixed code",
        ])

        return "\n".join(parts)

    def _call_api(self, prompt: str) -> tuple[str, int, int]:
        """Call Anthropic API. Returns (response_text, tokens_in, tokens_out)."""
        headers = {
            "Content-Type": "application/json",
            "x-api-key": self.api_key,
            "anthropic-version": "2023-06-01",
        }
        data = json.dumps({
            "model": self.model,
            "max_tokens": 4096,
            "messages": [{"role": "user", "content": prompt}],
        }).encode("utf-8")

        req = urllib.request.Request(
            "https://api.anthropic.com/v1/messages",
            data=data, headers=headers, method="POST",
        )

        try:
            with urllib.request.urlopen(req, timeout=120) as resp:
                result = json.loads(resp.read().decode("utf-8"))
        except Exception as e:
            return f"API error: {e}", 0, 0

        tokens_in = result.get("usage", {}).get("input_tokens", 0)
        tokens_out = result.get("usage", {}).get("output_tokens", 0)

        text = ""
        for block in result.get("content", []):
            if block.get("type") == "text":
                text += block["text"]

        return text, tokens_in, tokens_out

    def _extract_code(self, response: str, language: str) -> str | None:
        """Extract code block from LLM response."""
        # Try language-specific fence first
        pattern = rf"```(?:{language}|kt|ts|tsx|swift)\s*\n(.*?)```"
        match = re.search(pattern, response, re.DOTALL)
        if match:
            return match.group(1).strip()
        # Fallback: any code block
        match = re.search(r"```\s*\n(.*?)```", response, re.DOTALL)
        if match:
            return match.group(1).strip()
        return None
