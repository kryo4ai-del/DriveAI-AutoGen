# project_integrator.py
# Copies generated Swift files into the real Xcode project structure.

import os
import shutil

SUBFOLDER_MAP = {
    "ViewModel": "ViewModels",
    "View": "Views",
    "Service": "Services",
    "Model": "Models",
}

# --- Guard 4: Protected existing files ---
# These files must never be overwritten by the pipeline when they already exist.
_PROTECTED_FILES: frozenset[str] = frozenset({
    # ── Core app ──
    "DriveAIApp.swift",
    "AppNavigationView.swift",
    # ── Views ──
    "HomeDashboardView.swift",
    "OnboardingView.swift",
    "ScannerView.swift",
    "ImageImportView.swift",
    "QuestionView.swift",
    "ResultView.swift",
    "SettingsView.swift",
    "AnswerExplanationView.swift",
    "TrafficSignHistoryView.swift",
    "TrafficSignHistoryDetailView.swift",
    "ScannedDocumentView.swift",
    "LearningStatisticsView.swift",
    "TrafficSignStatisticsView.swift",
    "AnalysisDebugPanel.swift",
    "LaunchScreenView.swift",
    "TrafficSignRecognitionView.swift",
    "TrafficSignWeaknessView.swift",
    "SampleValidationView.swift",
    "RealQuestionTestView.swift",
    "UserInfoView.swift",
    "QuestionHistoryView.swift",
    "LearningInsightsView.swift",
    # ── ViewModels ──
    "HomeDashboardViewModel.swift",
    "OnboardingViewModel.swift",
    "ScannerViewModel.swift",
    "QuestionViewModel.swift",
    "AnswerExplanationViewModel.swift",
    "AnalysisDebugPanelViewModel.swift",
    "LearningStatsViewModel.swift",
    "LearningInsightsViewModel.swift",
    "SampleValidationViewModel.swift",
    "RealQuestionTestViewModel.swift",
    # ── Models (AskFin domain) ──
    "QuestionCategory.swift",
    "CategoryDetectionResult.swift",
    "AnalysisResult.swift",
    "QuestionHistoryEntry.swift",
    "Question.swift",
    "Answer.swift",
    "ButtonState.swift",
    "FeedbackType.swift",
    "AppTheme.swift",
    "User.swift",
    "TrafficSignHistoryEntry.swift",
    "TrafficSignRecognitionResult.swift",
    "AnswerConfidence.swift",
    "LearningStats.swift",
    "TrafficSignStats.swift",
    "WeaknessCategory.swift",
    "TrafficSignWeaknessCategory.swift",
    "ValidationSample.swift",
    # ── Services ──
    "QuestionCategoryDetectionService.swift",
    "QuestionAnalysisService.swift",
    "QuestionHistoryService.swift",
    "TrafficSignHistoryService.swift",
    "TrafficSignRecognitionService.swift",
    "OCRRecognitionService.swift",
    "ImageAnalysisService.swift",
    "LLMQuestionSolverService.swift",
    "LocalDataService.swift",
    "SampleValidationService.swift",
    "WeaknessAnalysisService.swift",
})


def _detect_target_folder(filename: str) -> str:
    name = filename.replace(".swift", "")
    for suffix, folder in SUBFOLDER_MAP.items():
        if name.endswith(suffix):
            return folder
    return "Models"


def _file_unchanged(dest: str, src: str) -> bool:
    try:
        with open(dest, encoding="utf-8") as f:
            dest_content = f.read()
        with open(src, encoding="utf-8") as f:
            src_content = f.read()
        return dest_content == src_content
    except FileNotFoundError:
        return False


GENERATED_DIR = os.path.join(os.path.dirname(os.path.dirname(__file__)), "generated_code")


class ProjectIntegrator:
    def __init__(self, xcode_project_path: str):
        # Resolve relative to the project root (same level as main.py)
        project_root = os.path.dirname(os.path.dirname(__file__))
        self.xcode_root = os.path.join(project_root, xcode_project_path)

    def integrate_generated_code(self, approval: str = "auto") -> dict:
        """
        approval: "auto" | "ask" | "off"
        Returns {"status": "integrated"|"skipped", "integrated": n, "unchanged": n, "protected": n}
        """
        if approval == "off":
            print()
            print("Xcode integration skipped (approval=off)")
            return {"status": "skipped", "integrated": 0, "unchanged": 0, "protected": 0}

        if approval == "ask":
            answer = input("\nIntegrate generated code into the Xcode project? [y/N] ").strip().lower()
            if answer not in ("y", "yes"):
                print("Xcode integration skipped.")
                return {"status": "skipped", "integrated": 0, "unchanged": 0, "protected": 0}

        integrated = []
        unchanged = 0
        protected_skipped = []

        if not os.path.isdir(GENERATED_DIR):
            return {"status": "integrated", "integrated": 0, "unchanged": 0, "protected": 0}

        for subfolder in os.listdir(GENERATED_DIR):
            src_dir = os.path.join(GENERATED_DIR, subfolder)
            if not os.path.isdir(src_dir):
                continue

            for filename in os.listdir(src_dir):
                if not filename.endswith(".swift"):
                    continue

                # --- Guard 4: Protect existing views ---
                target_folder = _detect_target_folder(filename)
                dest_dir = os.path.join(self.xcode_root, target_folder)
                dest_path = os.path.join(dest_dir, filename)

                if filename in _PROTECTED_FILES and os.path.exists(dest_path):
                    protected_skipped.append(filename)
                    continue

                src_path = os.path.join(src_dir, filename)

                os.makedirs(dest_dir, exist_ok=True)

                if _file_unchanged(dest_path, src_path):
                    unchanged += 1
                    continue

                shutil.copy2(src_path, dest_path)
                integrated.append(filename)

        print()
        print("Xcode integration completed")
        if integrated:
            print("Files integrated:")
            for name in integrated:
                print(f"  - {name}")
        else:
            print("  (no new or changed files)")

        if protected_skipped:
            print(f"Protected files skipped ({len(protected_skipped)}):")
            for name in protected_skipped:
                print(f"  - {name} (existing, protected)")

        return {
            "status": "integrated",
            "integrated": len(integrated),
            "unchanged": unchanged,
            "protected": len(protected_skipped),
        }
