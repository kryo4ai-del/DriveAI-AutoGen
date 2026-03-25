"""DriveAI Factory — Signing & Packaging Configuration.

Central configuration for version management, code signing,
and artifact storage. No external dependencies — only stdlib.
"""

from dataclasses import dataclass, field


@dataclass
class SigningConfig:
    """Configuration for the Signing & Packaging layer."""

    # Version Management
    versions_file: str = "factory/signing/versions.json"

    # Artifact Registry
    artifacts_dir: str = "factory/signing/artifacts"

    # Keystore Storage
    keystores_dir: str = "factory/signing/keystores"

    # Build Timeouts (seconds)
    android_build_timeout: int = 600
    web_build_timeout: int = 300
    ios_archive_timeout: int = 600
    ios_export_timeout: int = 600

    # Android Signing
    default_keystore_validity: int = 10000  # Days (~27 years)
    default_keystore_keyalg: str = "RSA"
    default_keystore_keysize: int = 2048
    default_dname: str = (
        "CN=DriveAI, OU=Development, O=DriveAI, "
        "L=Stadtoldendorf, ST=Niedersachsen, C=DE"
    )

    # iOS (prepared for Mac session)
    export_options_template: str = "factory/signing/templates/ExportOptions.plist"
    ios_export_method: str = "app-store"  # app-store, ad-hoc, development

    # CEO Gates
    require_keystore_backup_confirmation: bool = True
    require_credential_gate: bool = True

    # Web
    web_build_command: str = "npm run build"
    web_output_dirs: list = field(
        default_factory=lambda: [".next", "dist", "build", "out"]
    )
