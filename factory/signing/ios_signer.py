"""
DriveAI Factory — iOS Signer

Handles iOS archive, export, and IPA creation via Mac Bridge commands.
Designed to work as soon as Apple Developer credentials are set up.

Flow:
1. Check signing credentials (certificates + profiles)
2. Archive: xcodebuild archive -configuration Release
3. Export: xcodebuild -exportArchive -> IPA
4. Return SigningResult with IPA path
"""

import os
import json
import uuid
import time
from pathlib import Path
from datetime import datetime, timezone
from factory.signing.config import SigningConfig
from factory.signing.signing_result import SigningResult


class iOSSigner:
    def __init__(self, project_name, project_dir, version_info=None, config=None):
        self.project_name = project_name
        self.project_dir = project_dir
        self.version_info = version_info
        self.config = config or SigningConfig()
        self.commands_dir = self._find_commands_dir()

    def build_and_sign(self):
        """Full iOS signing flow."""
        start = time.time()
        print(f"[Signing iOS] Starting iOS signing for {self.project_name}")

        # Step 1: Verify Mac Bridge
        if not self.commands_dir:
            return SigningResult(
                status="FAILED", phase="verify",
                error="Mac Bridge not available (_commands/ directory not found). "
                      "Ensure you are running on the Mac with DriveAI-AutoGen.",
                duration_seconds=round(time.time() - start, 1))

        # Step 2: Check signing credentials
        print(f"[Signing iOS] Checking signing credentials...")
        cred_result = self._send_command("check_signing", {})
        if not cred_result:
            return SigningResult(
                status="FAILED", phase="credentials",
                error="Mac Bridge check_signing command timed out",
                duration_seconds=round(time.time() - start, 1))

        has_cert = cred_result.get("result", {}).get("has_distribution_cert", False)
        has_dev_cert = cred_result.get("result", {}).get("has_development_cert", False)
        has_profiles = cred_result.get("result", {}).get("has_provisioning_profiles", False)

        if not has_cert and not has_dev_cert:
            instructions = (
                "No code signing certificate found on this Mac.\n\n"
                "Setup steps:\n"
                "1. Enroll in Apple Developer Program (99 USD/year): https://developer.apple.com/programs/enroll/\n"
                "2. Open Xcode -> Settings -> Accounts -> Add your Apple ID\n"
                "3. Select your team -> Manage Certificates -> '+' -> Apple Distribution\n"
                "4. Go to https://developer.apple.com/account/resources/profiles/list\n"
                "5. Create an App Store provisioning profile for your app\n"
                "6. Download and double-click the profile to install it\n"
                "7. Update factory/signing/templates/ExportOptions.plist with your Team ID\n"
                "8. Run --sign again"
            )
            return SigningResult(
                status="FAILED", phase="credentials",
                error=f"No signing certificate found.\n\n{instructions}",
                duration_seconds=round(time.time() - start, 1),
                details=cred_result.get("result", {}))

        cert_type = "distribution" if has_cert else "development"
        print(f"[Signing iOS] Found {cert_type} certificate")

        if not has_profiles:
            print(f"[Signing iOS] WARNING: No provisioning profiles found. Export may fail.")

        # Step 3: Archive
        print(f"[Signing iOS] Archiving (Release configuration)...")
        archive_result = self._send_command("archive", {
            "project": self.project_name
        }, timeout=self.config.ios_archive_timeout)

        if not archive_result or archive_result.get("status") != "success":
            error = "Archive timed out"
            if archive_result:
                error = archive_result.get("error", archive_result.get("result", {}).get("error", "Archive failed"))
            return SigningResult(
                status="FAILED", phase="archive", error=str(error),
                duration_seconds=round(time.time() - start, 1))

        archive_path = archive_result.get("result", {}).get("archive_path", "")
        print(f"[Signing iOS] Archive successful: {archive_path}")

        # Step 4: Export IPA
        print(f"[Signing iOS] Exporting IPA...")
        export_options_path = self._ensure_export_options()

        export_result = self._send_command("export_ipa", {
            "project": self.project_name,
            "archive_path": archive_path,
            "export_options_path": export_options_path
        }, timeout=self.config.ios_export_timeout)

        if not export_result or export_result.get("status") != "success":
            error = "Export timed out"
            if export_result:
                error = export_result.get("error", export_result.get("result", {}).get("error", "Export failed"))
            return SigningResult(
                status="FAILED", phase="export", error=str(error),
                duration_seconds=round(time.time() - start, 1),
                details={"archive_path": archive_path})

        ipa_path = export_result.get("result", {}).get("ipa_path", "")
        print(f"[Signing iOS] Export successful: {ipa_path}")

        duration = round(time.time() - start, 1)
        version_str = getattr(self.version_info, 'full_version', '') if self.version_info else ''

        return SigningResult(
            status="SUCCESS",
            artifact_path=ipa_path,
            artifact_type="ipa",
            version=version_str,
            duration_seconds=duration,
            details={
                "archive_path": archive_path,
                "export_options": export_options_path,
                "cert_type": cert_type
            })

    def _find_commands_dir(self):
        """Finds the _commands/ directory."""
        candidates = [
            "_commands",
            "/Users/andreasott/DriveAI-AutoGen/_commands",
            os.path.join(self.project_dir, "..", "..", "_commands") if self.project_dir else None
        ]
        for c in candidates:
            if c and os.path.isdir(c):
                return c
        return None

    def _send_command(self, command, params, timeout=300):
        """Sends a command to the Mac Build Agent via file-based queue."""
        cmd_id = str(uuid.uuid4())[:8]
        cmd_data = {
            "type": command,
            "project": params.get("project", self.project_name),
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "id": cmd_id,
            "params": {k: v for k, v in params.items() if k != "project"}
        }

        pending_path = os.path.join(self.commands_dir, "pending", f"{cmd_id}.json")
        completed_path = os.path.join(self.commands_dir, "completed", f"{cmd_id}.json")

        # Write command
        os.makedirs(os.path.dirname(pending_path), exist_ok=True)
        with open(pending_path, "w") as f:
            json.dump(cmd_data, f, indent=2)
        print(f"[Signing iOS] Command sent: {command} (id: {cmd_id})")

        # Poll for result
        start = time.time()
        while time.time() - start < timeout:
            if os.path.exists(completed_path):
                try:
                    with open(completed_path) as f:
                        result = json.load(f)
                    try:
                        os.remove(completed_path)
                    except OSError:
                        pass
                    return result
                except (json.JSONDecodeError, IOError) as e:
                    print(f"[Signing iOS] Error reading result: {e}")
                    return None
            time.sleep(5)

        print(f"[Signing iOS] Command timed out after {timeout}s: {command}")
        try:
            if os.path.exists(pending_path):
                os.remove(pending_path)
        except OSError:
            pass
        return None

    def _ensure_export_options(self):
        """Ensures ExportOptions.plist exists."""
        template_path = self.config.export_options_template
        if os.path.exists(template_path):
            return template_path

        # Create default template
        os.makedirs(os.path.dirname(template_path), exist_ok=True)
        default_plist = '''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>{method}</string>
    <key>signingStyle</key>
    <string>automatic</string>
    <key>uploadBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <true/>
    <key>destination</key>
    <string>export</string>
</dict>
</plist>'''.format(method=self.config.ios_export_method)

        with open(template_path, "w") as f:
            f.write(default_plist)
        print(f"[Signing iOS] Created ExportOptions.plist template at {template_path}")
        print(f"[Signing iOS] NOTE: Add <key>teamID</key><string>YOUR_TEAM_ID</string> after setting up Apple Developer Account")
        return template_path
