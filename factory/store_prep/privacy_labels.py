"""DriveAI Factory — Privacy Label Generator.

Scans project source code for privacy-relevant patterns and generates:
  - Apple Privacy Nutrition Labels (App Store Connect format)
  - Google Data Safety Sections (Play Console format)
  - Web privacy hints (for privacy policy pages)

All detection is deterministic (regex patterns, no LLM).
"""

import json
import re
from dataclasses import dataclass, field
from pathlib import Path

_ROOT = Path(__file__).resolve().parent.parent.parent


# ---------------------------------------------------------------------------
# Code Privacy Scan result
# ---------------------------------------------------------------------------

@dataclass
class CodePrivacyScan:
    """Result of scanning source code for privacy-relevant patterns."""

    networking: bool = False
    analytics: bool = False
    location: bool = False
    camera: bool = False
    microphone: bool = False
    photos: bool = False
    contacts: bool = False
    health: bool = False
    financial: bool = False
    advertising: bool = False
    push_notifications: bool = False
    biometrics: bool = False
    user_content: bool = False
    device_id: bool = False

    # Details: which files triggered each category
    details: dict = field(default_factory=dict)

    def to_dict(self) -> dict:
        return {
            "networking": self.networking,
            "analytics": self.analytics,
            "location": self.location,
            "camera": self.camera,
            "microphone": self.microphone,
            "photos": self.photos,
            "contacts": self.contacts,
            "health": self.health,
            "financial": self.financial,
            "advertising": self.advertising,
            "push_notifications": self.push_notifications,
            "biometrics": self.biometrics,
            "user_content": self.user_content,
            "device_id": self.device_id,
            "details": self.details,
        }

    @property
    def categories_detected(self) -> list[str]:
        """List of category names that were detected."""
        return [
            k for k in [
                "networking", "analytics", "location", "camera", "microphone",
                "photos", "contacts", "health", "financial", "advertising",
                "push_notifications", "biometrics", "user_content", "device_id",
            ]
            if getattr(self, k)
        ]


# ---------------------------------------------------------------------------
# Detection patterns per category (multi-platform)
# ---------------------------------------------------------------------------

_PATTERNS: dict[str, list[str]] = {
    "networking": [
        r"URLSession", r"Alamofire", r"fetch\s*\(", r"axios",
        r"HttpClient", r"OkHttp", r"Retrofit", r"http\.get",
        r"XMLHttpRequest", r"WebSocket", r"\.request\(",
        r"import\s+requests", r"aiohttp", r"urllib",
    ],
    "analytics": [
        r"Firebase(?:Analytics)?", r"Amplitude", r"Mixpanel", r"Segment",
        r"GoogleAnalytics", r"AppFlyer", r"Adjust(?:SDK)?",
        r"analytics\.track", r"analytics\.log", r"posthog",
        r"ga\s*\(\s*['\"]send", r"gtag\s*\(",
    ],
    "location": [
        r"CLLocationManager", r"CoreLocation", r"requestWhenInUseAuthorization",
        r"requestAlwaysAuthorization", r"LocationManager", r"FusedLocationProviderClient",
        r"navigator\.geolocation", r"ACCESS_FINE_LOCATION", r"ACCESS_COARSE_LOCATION",
        r"Geolocator", r"geolocator",
    ],
    "camera": [
        r"AVCaptureSession", r"UIImagePickerController", r"\.camera",
        r"CameraX", r"Camera2", r"CAMERA_PERMISSION",
        r"getUserMedia.*video", r"MediaDevices",
        r"NSCameraUsageDescription",
    ],
    "microphone": [
        r"AVAudioRecorder", r"AVAudioEngine", r"SFSpeechRecognizer",
        r"AudioRecord", r"MediaRecorder.*audio",
        r"getUserMedia.*audio", r"RECORD_AUDIO",
        r"NSMicrophoneUsageDescription",
    ],
    "photos": [
        r"PHPhotoLibrary", r"PHAsset", r"UIImagePickerController",
        r"READ_EXTERNAL_STORAGE", r"MediaStore\.Images",
        r"NSPhotoLibraryUsageDescription", r"photo_manager",
    ],
    "contacts": [
        r"CNContactStore", r"ContactsContract", r"READ_CONTACTS",
        r"NSContactsUsageDescription", r"contacts_service",
    ],
    "health": [
        r"HealthKit", r"HKHealthStore", r"GoogleFit", r"Health Connect",
        r"health_connect", r"NSHealthShareUsageDescription",
    ],
    "financial": [
        r"StoreKit", r"SKPayment", r"BillingClient", r"InAppPurchase",
        r"Stripe", r"PaymentSheet", r"ApplePay", r"GooglePay",
        r"com\.android\.vending\.billing", r"RevenueCat",
    ],
    "advertising": [
        r"AdMob", r"GADMobileAds", r"AppTrackingTransparency",
        r"ASIdentifierManager", r"IDFA", r"GAID",
        r"facebook.*pixel", r"FBAdView", r"UnityAds",
        r"requestTrackingAuthorization",
    ],
    "push_notifications": [
        r"UNUserNotificationCenter", r"APNs", r"FirebaseMessaging",
        r"FCM", r"OneSignal", r"registerForRemoteNotifications",
        r"Notification\.Name", r"NotificationManager",
    ],
    "biometrics": [
        r"LAContext", r"BiometricPrompt", r"FaceID", r"TouchID",
        r"NSFaceIDUsageDescription", r"USE_BIOMETRIC",
        r"local_auth", r"fingerprint",
    ],
    "user_content": [
        r"UITextView", r"UITextField", r"EditText", r"TextInput",
        r"<input", r"<textarea", r"ContentResolver",
        r"UserDefaults", r"SharedPreferences", r"localStorage",
    ],
    "device_id": [
        r"UIDevice\.current\.identifierForVendor",
        r"Settings\.Secure\.ANDROID_ID", r"getDeviceId",
        r"IDFV", r"advertisingIdentifier",
        r"navigator\.userAgent", r"fingerprint",
    ],
}

# File extensions to scan
_SOURCE_EXTENSIONS = {
    ".swift", ".kt", ".kts", ".java",
    ".ts", ".tsx", ".js", ".jsx",
    ".cs",  # Unity
    ".py",
    ".xml",  # AndroidManifest
    ".plist",  # Info.plist
}

# Directories to skip
_SKIP_DIRS = {
    "node_modules", ".git", "build", "dist", ".next",
    "Pods", "DerivedData", ".gradle", "__pycache__",
    "venv", ".venv",
}


class PrivacyLabelGenerator:
    """Scans project code and generates privacy labels for all platforms.

    Usage:
        gen = PrivacyLabelGenerator("echomatch")
        labels = gen.generate()
        # labels = {
        #   "scan": CodePrivacyScan(...),
        #   "apple": {...},   # Apple Privacy Nutrition Label
        #   "google": {...},  # Google Data Safety Section
        #   "web": {...},     # Web privacy hints
        # }
        gen.save(labels)
    """

    def __init__(self, project_name: str) -> None:
        self.project_name = project_name
        self.project_dir = _ROOT / "projects" / project_name

    # ------------------------------------------------------------------
    # Public API
    # ------------------------------------------------------------------

    def generate(self) -> dict:
        """Scan code and generate privacy labels for all platforms."""
        scan = self._scan_code()
        return {
            "scan": scan,
            "apple": self._generate_apple_label(scan),
            "google": self._generate_google_safety(scan),
            "web": self._generate_web_privacy(scan),
        }

    def save(self, labels: dict, output_dir: str | None = None) -> Path:
        """Save privacy labels to JSON files.

        Returns the output directory path.
        """
        if output_dir:
            out = Path(output_dir)
        else:
            out = (
                Path(_ROOT)
                / "factory"
                / "store_prep"
                / "output"
                / self.project_name
                / "privacy"
            )
        out.mkdir(parents=True, exist_ok=True)

        # Scan result
        scan: CodePrivacyScan = labels["scan"]
        (out / "code_scan.json").write_text(
            json.dumps(scan.to_dict(), indent=2, ensure_ascii=False),
            encoding="utf-8",
        )

        # Apple
        (out / "apple_privacy_label.json").write_text(
            json.dumps(labels["apple"], indent=2, ensure_ascii=False),
            encoding="utf-8",
        )

        # Google
        (out / "google_data_safety.json").write_text(
            json.dumps(labels["google"], indent=2, ensure_ascii=False),
            encoding="utf-8",
        )

        # Web
        (out / "web_privacy_hints.json").write_text(
            json.dumps(labels["web"], indent=2, ensure_ascii=False),
            encoding="utf-8",
        )

        print(f"[Privacy Labels] Saved to {out}")
        return out

    # ------------------------------------------------------------------
    # Code scanning
    # ------------------------------------------------------------------

    def _scan_code(self) -> CodePrivacyScan:
        """Scan all source files for privacy-relevant patterns."""
        scan = CodePrivacyScan()

        if not self.project_dir.is_dir():
            print(f"[Privacy Labels] Project dir not found: {self.project_dir}")
            return scan

        source_files = self._collect_source_files()
        if not source_files:
            print(f"[Privacy Labels] No source files found in {self.project_dir}")
            return scan

        for filepath in source_files:
            try:
                content = filepath.read_text(encoding="utf-8", errors="ignore")
            except (PermissionError, OSError):
                continue

            for category, patterns in _PATTERNS.items():
                if self._check_patterns(content, patterns):
                    setattr(scan, category, True)
                    detail_list = scan.details.setdefault(category, [])
                    rel = str(filepath.relative_to(self.project_dir))
                    if rel not in detail_list:
                        detail_list.append(rel)

        detected = scan.categories_detected
        print(f"[Privacy Labels] Scanned {len(source_files)} files, "
              f"detected {len(detected)} categories: {', '.join(detected) or 'none'}")
        return scan

    def _collect_source_files(self) -> list[Path]:
        """Collect all scannable source files from the project directory."""
        files = []
        for path in self.project_dir.rglob("*"):
            if path.is_file() and path.suffix in _SOURCE_EXTENSIONS:
                # Skip excluded directories
                if not any(skip in path.parts for skip in _SKIP_DIRS):
                    files.append(path)
        return files

    @staticmethod
    def _check_patterns(content: str, patterns: list[str]) -> bool:
        """Check if any pattern matches in the content."""
        for pattern in patterns:
            if re.search(pattern, content, re.IGNORECASE):
                return True
        return False

    # ------------------------------------------------------------------
    # Apple Privacy Nutrition Labels
    # ------------------------------------------------------------------

    @staticmethod
    def _generate_apple_label(scan: CodePrivacyScan) -> dict:
        """Generate Apple App Store Privacy Nutrition Label format.

        Apple requires disclosure of data types collected and their purposes.
        Format matches App Store Connect privacy questions.
        """
        data_types = []

        if scan.analytics:
            data_types.append({
                "type": "Analytics",
                "purpose": "App Functionality, Analytics",
                "linked_to_identity": False,
                "used_for_tracking": False,
            })

        if scan.location:
            data_types.append({
                "type": "Precise Location",
                "purpose": "App Functionality",
                "linked_to_identity": True,
                "used_for_tracking": False,
            })

        if scan.contacts:
            data_types.append({
                "type": "Contacts",
                "purpose": "App Functionality",
                "linked_to_identity": True,
                "used_for_tracking": False,
            })

        if scan.health:
            data_types.append({
                "type": "Health & Fitness",
                "purpose": "App Functionality",
                "linked_to_identity": True,
                "used_for_tracking": False,
            })

        if scan.financial:
            data_types.append({
                "type": "Purchase History",
                "purpose": "App Functionality",
                "linked_to_identity": True,
                "used_for_tracking": False,
            })

        if scan.photos or scan.camera:
            data_types.append({
                "type": "Photos or Videos",
                "purpose": "App Functionality",
                "linked_to_identity": False,
                "used_for_tracking": False,
            })

        if scan.user_content:
            data_types.append({
                "type": "Other User Content",
                "purpose": "App Functionality",
                "linked_to_identity": True,
                "used_for_tracking": False,
            })

        if scan.device_id:
            data_types.append({
                "type": "Device ID",
                "purpose": "App Functionality, Analytics",
                "linked_to_identity": False,
                "used_for_tracking": scan.advertising,
            })

        if scan.advertising:
            data_types.append({
                "type": "Advertising Data",
                "purpose": "Third-Party Advertising",
                "linked_to_identity": False,
                "used_for_tracking": True,
            })

        # Determine privacy tier
        if not data_types:
            privacy_tier = "Data Not Collected"
        elif any(d["used_for_tracking"] for d in data_types):
            privacy_tier = "Data Used to Track You"
        elif any(d["linked_to_identity"] for d in data_types):
            privacy_tier = "Data Linked to You"
        else:
            privacy_tier = "Data Not Linked to You"

        return {
            "privacy_tier": privacy_tier,
            "data_types": data_types,
            "data_collection_count": len(data_types),
            "tracking_domains": scan.advertising,
            "third_party_sdks_detected": _detect_third_party_sdks(scan),
        }

    # ------------------------------------------------------------------
    # Google Data Safety Sections
    # ------------------------------------------------------------------

    @staticmethod
    def _generate_google_safety(scan: CodePrivacyScan) -> dict:
        """Generate Google Play Data Safety Section format.

        Google requires disclosure of data shared and collected,
        security practices, and deletion options.
        """
        data_collected = []
        data_shared = []

        if scan.location:
            data_collected.append({
                "category": "Location",
                "type": "Approximate location" if not scan.location else "Precise location",
                "purpose": "App functionality",
                "required": True,
            })

        if scan.contacts:
            data_collected.append({
                "category": "Personal info",
                "type": "Name, Email address",
                "purpose": "App functionality, Account management",
                "required": True,
            })

        if scan.photos or scan.camera:
            data_collected.append({
                "category": "Photos and videos",
                "type": "Photos",
                "purpose": "App functionality",
                "required": False,
            })

        if scan.financial:
            data_collected.append({
                "category": "Financial info",
                "type": "Purchase history",
                "purpose": "App functionality",
                "required": True,
            })

        if scan.health:
            data_collected.append({
                "category": "Health and fitness",
                "type": "Health info",
                "purpose": "App functionality",
                "required": True,
            })

        if scan.user_content:
            data_collected.append({
                "category": "App activity",
                "type": "Other user-generated content",
                "purpose": "App functionality",
                "required": False,
            })

        if scan.device_id:
            data_collected.append({
                "category": "Device or other IDs",
                "type": "Device or other IDs",
                "purpose": "Analytics",
                "required": False,
            })

        if scan.analytics:
            data_collected.append({
                "category": "App activity",
                "type": "App interactions",
                "purpose": "Analytics",
                "required": False,
            })
            data_shared.append({
                "category": "App activity",
                "type": "App interactions",
                "purpose": "Analytics",
                "shared_with": "Analytics providers",
            })

        if scan.advertising:
            data_shared.append({
                "category": "Device or other IDs",
                "type": "Device or other IDs",
                "purpose": "Advertising",
                "shared_with": "Advertising networks",
            })

        return {
            "data_collected": data_collected,
            "data_shared": data_shared,
            "security_practices": {
                "data_encrypted_in_transit": scan.networking,
                "data_deletion_available": True,  # Conservative default
                "independent_security_review": False,
            },
            "data_collected_count": len(data_collected),
            "data_shared_count": len(data_shared),
        }

    # ------------------------------------------------------------------
    # Web Privacy
    # ------------------------------------------------------------------

    @staticmethod
    def _generate_web_privacy(scan: CodePrivacyScan) -> dict:
        """Generate privacy hints for web privacy policy generation."""
        sections = []

        if scan.networking:
            sections.append({
                "section": "Data Transmission",
                "description": "This app transmits data over the internet.",
                "gdpr_relevant": True,
            })

        if scan.analytics:
            sections.append({
                "section": "Analytics",
                "description": "This app uses analytics services to track usage patterns.",
                "gdpr_relevant": True,
                "consent_required": True,
            })

        if scan.location:
            sections.append({
                "section": "Location Data",
                "description": "This app accesses your device location.",
                "gdpr_relevant": True,
                "consent_required": True,
            })

        if scan.camera or scan.microphone:
            sections.append({
                "section": "Camera / Microphone",
                "description": "This app may access your camera or microphone.",
                "gdpr_relevant": True,
                "consent_required": True,
            })

        if scan.advertising:
            sections.append({
                "section": "Advertising & Tracking",
                "description": "This app uses advertising SDKs that may track users across apps.",
                "gdpr_relevant": True,
                "consent_required": True,
            })

        if scan.financial:
            sections.append({
                "section": "In-App Purchases",
                "description": "This app offers in-app purchases processed by the platform store.",
                "gdpr_relevant": True,
            })

        if scan.push_notifications:
            sections.append({
                "section": "Push Notifications",
                "description": "This app sends push notifications using a token-based system.",
                "gdpr_relevant": False,
            })

        if scan.user_content:
            sections.append({
                "section": "User-Generated Content",
                "description": "This app collects and stores user-generated content.",
                "gdpr_relevant": True,
            })

        if scan.biometrics:
            sections.append({
                "section": "Biometric Data",
                "description": "This app uses biometric authentication (Face ID, fingerprint).",
                "gdpr_relevant": True,
                "consent_required": True,
            })

        return {
            "sections": sections,
            "gdpr_sections_count": sum(1 for s in sections if s.get("gdpr_relevant")),
            "consent_required_count": sum(1 for s in sections if s.get("consent_required")),
            "cookie_banner_needed": scan.analytics or scan.advertising,
        }


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _detect_third_party_sdks(scan: CodePrivacyScan) -> list[str]:
    """List third-party SDKs detected based on scan results."""
    sdks = []
    details = scan.details

    # Map common SDK names from file paths / pattern matches
    sdk_indicators = {
        "Firebase": ["analytics", "push_notifications"],
        "AdMob": ["advertising"],
        "Facebook SDK": ["advertising"],
        "StoreKit / IAP": ["financial"],
        "HealthKit": ["health"],
        "CoreLocation": ["location"],
    }

    for sdk_name, categories in sdk_indicators.items():
        if any(cat in details for cat in categories):
            sdks.append(sdk_name)

    return sdks
