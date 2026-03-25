"""DriveAI Factory — Signing Result Dataclass.

Shared result type returned by WebBuilder, AndroidSigner, and (future) iOSSigner.
No external dependencies — only stdlib.
"""

from dataclasses import dataclass, field


@dataclass
class SigningResult:
    """Result of a build/sign operation."""

    status: str = "PENDING"  # SUCCESS, FAILED, SKIPPED
    phase: str = ""  # Which phase failed: "install", "build", "sign", "keystore", etc.
    artifact_path: str = ""  # Path to the output artifact
    artifact_type: str = ""  # "ipa", "aab", "apk", "web_bundle"
    version: str = ""  # Full version string
    error: str = ""  # Error message on failure
    duration_seconds: float = 0.0
    details: dict = field(default_factory=dict)  # Extra info

    def summary(self) -> str:
        """One-line summary."""
        if self.status == "SUCCESS":
            return (
                f"{self.artifact_type}: {self.status} "
                f"({self.duration_seconds}s) -> {self.artifact_path}"
            )
        return f"{self.artifact_type or 'build'}: {self.status} at {self.phase} -- {self.error}"
