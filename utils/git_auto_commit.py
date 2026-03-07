# git_auto_commit.py
# Automatically stages, commits, and pushes changes after a successful pipeline run.

import subprocess
import os

PROJECT_ROOT = os.path.dirname(os.path.dirname(__file__))


def _run_git(args: list[str]) -> tuple[int, str, str]:
    """Run a git command in PROJECT_ROOT. Returns (returncode, stdout, stderr)."""
    result = subprocess.run(
        ["git"] + args,
        cwd=PROJECT_ROOT,
        capture_output=True,
        text=True,
    )
    return result.returncode, result.stdout.strip(), result.stderr.strip()


class GitAutoCommit:
    def is_git_repo(self) -> bool:
        code, _, _ = _run_git(["rev-parse", "--is-inside-work-tree"])
        return code == 0

    def stage_changes(self) -> bool:
        """Stage all changes. Returns True if anything was staged."""
        _run_git(["add", "."])
        code, stdout, _ = _run_git(["diff", "--cached", "--quiet"])
        # exit code 1 means there are staged changes
        return code == 1

    def commit_changes(self, message: str) -> bool:
        """Create a commit. Returns True on success."""
        code, _, stderr = _run_git(["commit", "-m", message])
        if code != 0:
            print(f"  [git] commit failed: {stderr}")
            return False
        return True

    def push_changes(self) -> bool:
        """Push to origin. Returns True on success."""
        code, _, stderr = _run_git(["push"])
        if code != 0:
            print(f"  [git] WARNING: push failed: {stderr}")
            return False
        return True

    def run_auto_commit(self, task: str, run_manifest_path: str = "") -> None:
        """
        Full auto-commit flow after a successful pipeline run.
        Skips gracefully if git is unavailable or nothing changed.
        """
        print()
        print("Git auto commit:")

        try:
            if not self.is_git_repo():
                print("  skipped (not a git repository)")
                return

            has_changes = self.stage_changes()
            if not has_changes:
                print("  skipped (no changes detected)")
                return

            print("  - changes staged")

            # Truncate long task names for the commit message
            task_short = task[:72] if len(task) > 72 else task
            message = f"AI run: {task_short}"

            if not self.commit_changes(message):
                return
            print("  - commit created")

            if self.push_changes():
                print("  - pushed to origin/main")
            else:
                print("  - push skipped (see warning above)")

        except FileNotFoundError:
            print("  skipped (git not found on PATH)")
        except Exception as e:
            print(f"  skipped (unexpected error: {e})")
