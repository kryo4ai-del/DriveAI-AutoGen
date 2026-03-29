"""Git Tagger — Git-based tagging and rollback for Evolution Loop iterations.

Creates tags per iteration, enables rollback to last stable state.
All git operations via subprocess with timeout and graceful fallback.
"""

from __future__ import annotations

import subprocess
from pathlib import Path

_PREFIX = "[EVO-GIT]"
_TIMEOUT = 30


class GitTagger:
    """Git-based tagging and rollback for Evolution Loop iterations."""

    def __init__(self, project_id: str) -> None:
        self.project_id = project_id
        self._tag_prefix = f"evolution/{project_id}"
        self.git_available = self._check_git()

    # ------------------------------------------------------------------
    # Public API
    # ------------------------------------------------------------------

    def tag_iteration(self, iteration: int, message: str = "") -> bool:
        """Create a git tag for an iteration.

        Tag name: evolution/{project_id}/iteration-{iteration}
        Returns True on success, False on failure (never crashes).
        """
        if not self.git_available:
            return False

        tag_name = f"{self._tag_prefix}/iteration-{iteration}"
        msg = message or f"Evolution Loop iteration {iteration}"

        # Stage all changes
        ok, _, _ = self._run_git(["add", "-A"])
        if not ok:
            return False

        # Commit (allow empty in case nothing changed)
        ok, _, _ = self._run_git([
            "commit", "-m",
            f"Evolution Loop: {self.project_id} iteration {iteration}",
            "--allow-empty",
        ])
        # Commit may fail if nothing to commit (not staged) — that's fine

        # Create annotated tag
        ok, _, stderr = self._run_git(["tag", "-a", tag_name, "-m", msg])
        if not ok:
            # Tag might already exist
            if "already exists" in stderr:
                print(f"{_PREFIX} Tag {tag_name} already exists, skipping")
                return True
            print(f"{_PREFIX} Failed to create tag: {stderr}")
            return False

        print(f"{_PREFIX} Tagged iteration {iteration}: {tag_name}")
        return True

    def rollback_to(self, iteration: int) -> bool:
        """Roll back to a previous iteration by creating a new branch.

        Creates branch: evolution/{project_id}/rollback-to-{iteration}
        Never force-pushes or modifies main.
        """
        if not self.git_available:
            print(f"{_PREFIX} Git not available, cannot rollback")
            return False

        tag_name = f"{self._tag_prefix}/iteration-{iteration}"

        # Check tag exists
        ok, stdout, _ = self._run_git(["tag", "-l", tag_name])
        if not ok or tag_name not in stdout:
            print(f"{_PREFIX} Tag {tag_name} not found")
            return False

        # Create rollback branch
        branch = f"evolution/{self.project_id}/rollback-to-{iteration}"
        ok, _, stderr = self._run_git(["checkout", "-b", branch, tag_name])
        if not ok:
            print(f"{_PREFIX} Rollback failed: {stderr}")
            return False

        print(f"{_PREFIX} Rolled back to iteration {iteration} on branch {branch}")
        return True

    def list_tags(self) -> list[str]:
        """List all evolution tags for this project, sorted."""
        if not self.git_available:
            return []

        ok, stdout, _ = self._run_git(["tag", "-l", f"{self._tag_prefix}/*"])
        if not ok:
            return []

        tags = [t.strip() for t in stdout.strip().split("\n") if t.strip()]
        return sorted(tags)

    def get_last_stable_iteration(self, ldo_storage) -> int:
        """Find the last iteration where all hard scores met minimum targets.

        Hard Score Minimums: bug >= 90, roadbook >= 95, structural >= 85.
        Returns iteration number or -1 if none found.
        """
        history = ldo_storage.get_history()

        for ldo in reversed(history):
            bug = ldo.scores.bug_score.value
            roadbook = ldo.scores.roadbook_match_score.value
            structural = ldo.scores.structural_health_score.value
            if bug >= 90 and roadbook >= 95 and structural >= 85:
                return ldo.meta.iteration

        return -1

    # ------------------------------------------------------------------
    # Internal
    # ------------------------------------------------------------------

    def _check_git(self) -> bool:
        """Check if git is available and we're in a repo."""
        ok_version, _, _ = self._run_git(["--version"])
        if not ok_version:
            return False
        ok_repo, _, _ = self._run_git(["rev-parse", "--git-dir"])
        return ok_repo

    @staticmethod
    def _run_git(args: list[str]) -> tuple[bool, str, str]:
        """Run a git command. Returns (success, stdout, stderr)."""
        try:
            result = subprocess.run(
                ["git"] + args,
                capture_output=True,
                text=True,
                timeout=_TIMEOUT,
            )
            return (result.returncode == 0, result.stdout, result.stderr)
        except FileNotFoundError:
            return (False, "", "git not found")
        except subprocess.TimeoutExpired:
            return (False, "", "timeout")
        except Exception as e:
            return (False, "", str(e))
