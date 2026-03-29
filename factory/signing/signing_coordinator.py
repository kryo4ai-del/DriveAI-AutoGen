"""DriveAI Factory -- Signing Coordinator.

Main orchestrator for the Signing & Packaging pipeline.
Runs per-platform: credential check -> version bump -> build/sign -> artifact storage.

iOS signing uses iOSSigner (requires Mac Bridge or Mac session for actual builds).

No external dependencies -- only stdlib + factory.signing.* imports.
External factory modules (gate_api, project_registry) are lazy-imported.
"""

import os
import time
from pathlib import Path

from factory.signing.artifact_registry import ArtifactRegistry
from factory.signing.config import SigningConfig
from factory.signing.credential_checker import CredentialChecker
from factory.signing.signing_result import SigningResult
from factory.signing.version_manager import VersionManager

_ROOT = Path(__file__).resolve().parent.parent.parent


class SigningCoordinator:
    """Orchestrates Signing & Packaging for one or more platforms.

    Usage::

        coordinator = SigningCoordinator("brainpuzzle", ["android", "web"])
        result = coordinator.run()
        print(result["status"])  # SUCCESS, PARTIAL, or FAILED
    """

    def __init__(
        self,
        project_name: str,
        platforms: list,
        config: SigningConfig | None = None,
    ) -> None:
        self.project_name = project_name
        self.platforms = platforms
        self.config = config or SigningConfig()
        self.version_manager = VersionManager(project_name)
        self.credential_checker = CredentialChecker(self.config)
        self.artifact_registry = ArtifactRegistry(self.config)

    # ------------------------------------------------------------------
    # Public API
    # ------------------------------------------------------------------

    def run(self, store_prep_path: str | None = None) -> dict:
        """Run Signing & Packaging for all specified platforms.

        Returns::

            {
                "status": "SUCCESS" | "PARTIAL" | "FAILED",
                "platforms": {platform: SigningResult, ...},
                "artifacts": [ArtifactEntry, ...],
                "duration_seconds": float,
            }
        """
        start = time.time()
        print(f"[Signing] Starting Signing & Packaging for {self.project_name}")
        print(f"[Signing] Platforms: {', '.join(self.platforms)}")

        results: dict[str, SigningResult] = {}
        artifacts = []

        for platform in self.platforms:
            print(f"\n[Signing] {'=' * 50}")
            print(f"[Signing] Processing: {platform}")
            print(f"[Signing] {'=' * 50}")

            result = self._process_platform(platform, store_prep_path)
            results[platform] = result

            # Store artifact if successful
            if result.status == "SUCCESS" and result.artifact_path:
                try:
                    version = self.version_manager.get_current(platform)
                    entry = self.artifact_registry.store(
                        self.project_name,
                        platform,
                        version,
                        result.artifact_path,
                        {
                            "store_prep_path": store_prep_path or "",
                            "signing_duration": result.duration_seconds,
                        },
                    )
                    artifacts.append(entry)
                    print(f"[Signing] Artifact stored: {entry.registry_dir}")
                except Exception as e:
                    print(f"[Signing] WARNING: Failed to store artifact: {e}")

        # Determine overall status
        statuses = [r.status for r in results.values()]
        if all(s == "SUCCESS" for s in statuses):
            overall = "SUCCESS"
        elif all(s in ("FAILED", "SKIPPED") for s in statuses):
            overall = "FAILED"
        else:
            overall = "PARTIAL"

        duration = round(time.time() - start, 1)

        # Print summary
        print(f"\n[Signing] {'=' * 50}")
        print(f"[Signing] SUMMARY: {overall}")
        print(f"[Signing] {'=' * 50}")
        for plat, res in results.items():
            if res.status == "SUCCESS":
                icon = "OK"
            elif res.status == "SKIPPED":
                icon = "SKIP"
            else:
                icon = "FAIL"
            extra = f" -- {res.artifact_type}" if res.artifact_path else ""
            if res.error:
                extra += f" -- {res.error[:80]}"
            print(f"[Signing]   {plat:10s} [{icon}]{extra}")
        if artifacts:
            print(f"[Signing] Artifacts stored: {len(artifacts)}")
        print(f"[Signing] Duration: {duration}s")

        return {
            "status": overall,
            "platforms": results,
            "artifacts": artifacts,
            "duration_seconds": duration,
        }

    # ------------------------------------------------------------------
    # Per-platform processing
    # ------------------------------------------------------------------

    def _process_platform(
        self, platform: str, store_prep_path: str | None = None
    ) -> SigningResult:
        """Process a single platform through the signing pipeline."""
        start = time.time()

        try:
            return self._process_platform_inner(platform, store_prep_path, start)
        except Exception as e:
            return SigningResult(
                status="FAILED",
                phase="unexpected",
                artifact_type=self._default_artifact_type(platform),
                error=f"Unexpected error: {e}",
                duration_seconds=round(time.time() - start, 1),
            )

    def _process_platform_inner(
        self, platform: str, store_prep_path: str | None, start: float
    ) -> SigningResult:
        """Inner processing logic (called from _process_platform with try/except)."""
        artifact_type = self._default_artifact_type(platform)

        # -- Unity: not implemented -----------------------------------------
        if platform == "unity":
            print("[Signing] Unity signing not yet implemented")
            return SigningResult(
                status="SKIPPED",
                phase="deferred",
                artifact_type="unknown",
                error="Unity signing not yet implemented",
                duration_seconds=round(time.time() - start, 1),
            )

        # -- Step 1: Credential check ---------------------------------------
        cred_status = self.credential_checker.check(platform, self.project_name)
        print(f"[Signing] Credentials: {cred_status.summary()}")

        if not cred_status.ready:
            result = self._handle_missing_credentials(
                platform, cred_status, artifact_type, start
            )
            if result is not None:
                return result
            # If None, credentials were resolved — continue

        # -- Step 2: Version bump -------------------------------------------
        version = self.version_manager.bump_build(platform)
        print(f"[Signing] Version: {version.full_version}")

        # Apply version to project files
        project_dir = self._resolve_project_dir(platform)
        if project_dir:
            self.version_manager.apply_to_project(platform, project_dir)
        else:
            print(
                f"[Signing] WARNING: Project directory not found, "
                f"version not applied to project files"
            )

        # -- Step 3: Build + Sign -------------------------------------------
        if not project_dir:
            return SigningResult(
                status="FAILED",
                phase="resolve_project",
                artifact_type=artifact_type,
                error=(
                    f"Project directory not found for {self.project_name}. "
                    f"Expected: projects/{self.project_name}/"
                ),
                duration_seconds=round(time.time() - start, 1),
            )

        if platform == "ios":
            from factory.signing.ios_signer import iOSSigner

            signer = iOSSigner(
                self.project_name, project_dir, version, self.config
            )
            return signer.build_and_sign()

        elif platform == "android":
            from factory.signing.android_signer import AndroidSigner

            signer = AndroidSigner(
                self.project_name, project_dir, version, self.config
            )
            return signer.build_and_sign()

        elif platform == "web":
            from factory.signing.web_builder import WebBuilder

            builder = WebBuilder(
                self.project_name, project_dir, version, self.config
            )
            return builder.build()

        else:
            return SigningResult(
                status="FAILED",
                phase="build",
                artifact_type=artifact_type,
                error=f"No builder available for platform: {platform}",
                duration_seconds=round(time.time() - start, 1),
            )

    # ------------------------------------------------------------------
    # Credential gate handling
    # ------------------------------------------------------------------

    def _handle_missing_credentials(
        self,
        platform: str,
        cred_status,
        artifact_type: str,
        start: float,
    ) -> SigningResult | None:
        """Handle missing credentials.

        Returns SigningResult to abort, or None to continue (credentials resolved).
        """
        if not self.config.require_credential_gate:
            # No gate system -- just fail
            missing_str = ", ".join(cred_status.missing)
            return SigningResult(
                status="FAILED",
                phase="credentials",
                artifact_type=artifact_type,
                error=f"Missing credentials: {missing_str}",
                duration_seconds=round(time.time() - start, 1),
                details={"missing": cred_status.missing},
            )

        # Try to create a CEO gate (blocking)
        try:
            from factory.hq.gate_api import create_gate, wait_for_decision

            missing_str = "\n".join(f"- {m}" for m in cred_status.missing)
            instructions = cred_status.instructions or "See missing items above."

            gate_id = create_gate(
                project=self.project_name,
                gate_type="credentials_missing",
                category="signing",
                title=f"Signing Credentials fehlen -- {platform}",
                description=(
                    f"Fuer {platform}-Signing fehlen Voraussetzungen:\n\n"
                    f"{missing_str}\n\n"
                    f"Anleitung:\n{instructions}"
                ),
                severity="blocking",
                options=[
                    {
                        "id": "setup_done",
                        "label": "Eingerichtet, weiter",
                        "color": "green",
                    },
                    {
                        "id": "skip_platform",
                        "label": "Plattform ueberspringen",
                        "color": "orange",
                    },
                    {
                        "id": "abort",
                        "label": "Abbrechen",
                        "color": "red",
                    },
                ],
                source_department="factory/signing",
                source_agent="signing_coordinator",
                platform=platform,
            )

            print(f"[Signing] CEO Gate created: {gate_id}")
            print("[Signing] Waiting for CEO decision...")

            decision = wait_for_decision(gate_id, poll_interval=10, timeout=3600)
            chosen = decision.get("decision", "abort")
            print(f"[Signing] CEO decision: {chosen}")

            if chosen == "skip_platform":
                return SigningResult(
                    status="SKIPPED",
                    phase="credentials",
                    artifact_type=artifact_type,
                    error="Skipped by CEO decision",
                    duration_seconds=round(time.time() - start, 1),
                )
            elif chosen == "abort":
                return SigningResult(
                    status="FAILED",
                    phase="credentials",
                    artifact_type=artifact_type,
                    error="Aborted by CEO decision",
                    duration_seconds=round(time.time() - start, 1),
                )
            else:
                # "setup_done" -- re-check
                cred_recheck = self.credential_checker.check(
                    platform, self.project_name
                )
                if not cred_recheck.ready:
                    missing_str = ", ".join(cred_recheck.missing)
                    return SigningResult(
                        status="FAILED",
                        phase="credentials",
                        artifact_type=artifact_type,
                        error=f"Still missing after setup: {missing_str}",
                        duration_seconds=round(time.time() - start, 1),
                    )
                # Credentials resolved
                print("[Signing] Credentials verified after setup")
                return None

        except ImportError:
            # gate_api not available -- fall back to simple failure
            missing_str = ", ".join(cred_status.missing)
            return SigningResult(
                status="FAILED",
                phase="credentials",
                artifact_type=artifact_type,
                error=f"Missing credentials (no gate system): {missing_str}",
                duration_seconds=round(time.time() - start, 1),
            )
        except Exception as e:
            # Gate timeout or other error
            return SigningResult(
                status="FAILED",
                phase="credentials",
                artifact_type=artifact_type,
                error=f"Credential gate error: {e}",
                duration_seconds=round(time.time() - start, 1),
            )

    # ------------------------------------------------------------------
    # Project directory resolution
    # ------------------------------------------------------------------

    def _resolve_project_dir(self, platform: str) -> str | None:
        """Resolve the project directory for a platform.

        Try order:
          1. Project registry (factory/projects/{project}/project.json)
          2. Convention: projects/{project}/
          3. None
        """
        # Try project registry
        try:
            from factory.project_registry import get_project

            project_data = get_project(self.project_name)
            if project_data:
                # Check for platform-specific source_dir
                platforms = project_data.get("platforms", {})
                plat_data = platforms.get(platform, {})
                source_dir = plat_data.get("source_dir", "")
                if source_dir:
                    full_path = str(_ROOT / source_dir)
                    if os.path.isdir(full_path):
                        return full_path

                # Fallback: project-level source_dir
                source_dir = project_data.get("source_dir", "")
                if source_dir:
                    full_path = str(_ROOT / source_dir)
                    if os.path.isdir(full_path):
                        return full_path
        except (ImportError, Exception):
            pass

        # Convention: projects/{project}/
        convention_dir = _ROOT / "projects" / self.project_name
        if convention_dir.is_dir():
            return str(convention_dir)

        return None

    # ------------------------------------------------------------------
    # Helpers
    # ------------------------------------------------------------------

    @staticmethod
    def _default_artifact_type(platform: str) -> str:
        """Return default artifact type for a platform."""
        return {
            "ios": "ipa",
            "android": "aab",
            "web": "web_bundle",
        }.get(platform, "unknown")
