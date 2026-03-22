"""Unity/C# assembly line."""
import os
import re
import shutil
import subprocess
from dataclasses import dataclass
from pathlib import Path

from .base_line import BaseAssemblyLine, CompileResult, FixAction


class UnityAssemblyLine(BaseAssemblyLine):
    """Unity game assembly line.

    Organizes C# scripts into Unity project structure,
    generates project files, and attempts Unity CLI build.
    """

    def __init__(self, project_name: str = "", project_dir: str | Path = ""):
        self.project_name = project_name
        self.project_dir = Path(project_dir) if project_dir else Path(".")
        self.handoff = None
        self.assets_dir = None
        self.package = "EchoMatch"

    def receive_handoff(self, handoff) -> bool:
        cs_files = [f for f in handoff.file_manifest if f.endswith(".cs")]
        if not cs_files:
            print("  [Unity] No .cs files in handoff")
            return False
        self.handoff = handoff
        print(f"  [Unity] Accepted: {len(cs_files)} .cs files from {handoff.project_name}")
        return True

    def create_build_system(self) -> dict:
        created = []

        # Packages/manifest.json
        pkg_dir = self.project_dir / "Packages"
        pkg_dir.mkdir(parents=True, exist_ok=True)
        (pkg_dir / "manifest.json").write_text(
            '{\n'
            '  "dependencies": {\n'
            '    "com.unity.render-pipelines.universal": "14.0.11",\n'
            '    "com.unity.textmeshpro": "3.0.9",\n'
            '    "com.unity.inputsystem": "1.7.0",\n'
            '    "com.unity.test-framework": "1.3.9",\n'
            '    "com.unity.2d.sprite": "1.0.0",\n'
            '    "com.unity.2d.animation": "9.1.1"\n'
            '  }\n'
            '}\n',
            encoding="utf-8",
        )
        created.append("Packages/manifest.json")

        # ProjectSettings (minimal)
        ps_dir = self.project_dir / "ProjectSettings"
        ps_dir.mkdir(parents=True, exist_ok=True)
        (ps_dir / "ProjectVersion.txt").write_text(
            "m_EditorVersion: 2022.3.50f1\n"
            "m_EditorVersionWithRevision: 2022.3.50f1 (00000000000)\n",
            encoding="utf-8",
        )
        created.append("ProjectSettings/ProjectVersion.txt")

        # Assets directories
        assets = self.project_dir / "Assets"
        for d in ["Scripts/Core", "Scripts/Gameplay", "Scripts/UI", "Scripts/Data",
                   "Scripts/Services", "Scripts/Audio", "Scripts/VFX", "Scripts/Utilities",
                   "Scripts/Core/Interfaces", "Scripts/Core/Enums",
                   "Scripts/Data/Models", "Scripts/Data/ScriptableObjects",
                   "Scenes", "Prefabs", "Resources", "StreamingAssets",
                   "Editor", "Tests"]:
            (assets / d).mkdir(parents=True, exist_ok=True)
        created.append("Assets/ directory structure")

        # Assembly definition
        (assets / "Scripts" / "Assembly-CSharp.asmdef").write_text(
            '{\n'
            '    "name": "Assembly-CSharp",\n'
            '    "rootNamespace": "",\n'
            '    "references": [],\n'
            '    "includePlatforms": [],\n'
            '    "excludePlatforms": [],\n'
            '    "allowUnsafeCode": false\n'
            '}\n',
            encoding="utf-8",
        )
        created.append("Assets/Scripts/Assembly-CSharp.asmdef")

        # .gitignore
        (self.project_dir / ".gitignore").write_text(
            "[Ll]ibrary/\n[Tt]emp/\n[Oo]bj/\n[Bb]uild/\n[Bb]uilds/\n"
            "[Ll]ogs/\n[Uu]ser[Ss]ettings/\n*.csproj\n*.sln\n*.suo\n"
            "*.tmp\n*.user\n*.userprefs\n*.pidb\n*.booproj\n*.svd\n"
            "*.pdb\n*.mdb\n*.opendb\n*.VC.db\n*.pidb.meta\n"
            "*.pdb.meta\n*.mdb.meta\ncrashlyticsReport.txt\n",
            encoding="utf-8",
        )
        created.append(".gitignore")

        self.assets_dir = assets
        print(f"  [Unity] Build system: {len(created)} items created")
        return {"created": created, "status": "ok"}

    def organize_files(self) -> dict:
        if not self.handoff:
            return {"status": "no_handoff"}

        assets = self.project_dir / "Assets"
        self.assets_dir = assets
        moved = 0
        skipped = 0

        for rel_path in self.handoff.file_manifest:
            if not rel_path.endswith(".cs"):
                continue
            src = self.project_dir / rel_path
            if not src.is_file():
                skipped += 1
                continue

            try:
                content = src.read_text(encoding="utf-8", errors="ignore")
            except Exception:
                skipped += 1
                continue

            target_sub = self._classify_file(content, src.name)
            target_dir = assets / target_sub
            target_dir.mkdir(parents=True, exist_ok=True)
            target_file = target_dir / src.name

            if target_file.exists():
                skipped += 1
                continue

            shutil.copy2(str(src), str(target_file))
            moved += 1

        print(f"  [Unity] Organized: {moved} files, {skipped} skipped")
        return {"moved": moved, "skipped": skipped, "status": "ok"}

    def _classify_file(self, content: str, filename: str) -> str:
        if "using UnityEditor" in content:
            return "Editor"
        if "using NUnit" in content or "[Test]" in content or "[UnityTest]" in content:
            return "Tests"
        if "[CreateAssetMenu" in content or ": ScriptableObject" in content:
            return "Scripts/Data/ScriptableObjects"
        stem = Path(filename).stem
        if stem.startswith("I") and len(stem) > 1 and stem[1].isupper() and "interface " in content:
            return "Scripts/Core/Interfaces"
        if re.search(r"\benum\s+\w+", content) and "class " not in content:
            return "Scripts/Core/Enums"
        if "Manager" in filename or "Controller" in filename:
            return "Scripts/Core"
        if "Service" in filename:
            return "Scripts/Services"
        if "UI" in filename or "Screen" in filename or "Panel" in filename or "View" in filename:
            return "Scripts/UI"
        if ": MonoBehaviour" in content:
            if "Game" in filename or "Match" in filename or "Board" in filename or "Tile" in filename:
                return "Scripts/Gameplay"
            return "Scripts"
        if "static class" in content:
            return "Scripts/Utilities"
        return "Scripts/Data/Models"

    def wire_app(self) -> dict:
        if not self.assets_dir:
            return {"status": "no_assets_dir"}

        created = []
        core = self.assets_dir / "Scripts" / "Core"
        core.mkdir(parents=True, exist_ok=True)

        # GameManager
        (core / "GameManager.cs").write_text(
            "using UnityEngine;\n\n"
            "public class GameManager : MonoBehaviour\n{\n"
            "    public static GameManager Instance { get; private set; }\n\n"
            "    private void Awake()\n    {\n"
            "        if (Instance != null && Instance != this) { Destroy(gameObject); return; }\n"
            "        Instance = this;\n"
            "        DontDestroyOnLoad(gameObject);\n"
            "    }\n}\n",
            encoding="utf-8",
        )
        created.append("Scripts/Core/GameManager.cs")

        # SceneLoader
        (core / "SceneLoader.cs").write_text(
            "using UnityEngine;\nusing UnityEngine.SceneManagement;\n"
            "using System.Collections;\n\n"
            "public class SceneLoader : MonoBehaviour\n{\n"
            "    public static SceneLoader Instance { get; private set; }\n\n"
            "    private void Awake()\n    {\n"
            "        if (Instance != null) { Destroy(gameObject); return; }\n"
            "        Instance = this;\n    }\n\n"
            "    public void LoadScene(string sceneName)\n    {\n"
            "        StartCoroutine(LoadSceneAsync(sceneName));\n    }\n\n"
            "    private IEnumerator LoadSceneAsync(string sceneName)\n    {\n"
            "        var op = SceneManager.LoadSceneAsync(sceneName);\n"
            "        while (!op.isDone) yield return null;\n    }\n}\n",
            encoding="utf-8",
        )
        created.append("Scripts/Core/SceneLoader.cs")

        # AudioManager
        (core / "AudioManager.cs").write_text(
            "using UnityEngine;\n\n"
            "public class AudioManager : MonoBehaviour\n{\n"
            "    public static AudioManager Instance { get; private set; }\n"
            "    [SerializeField] private AudioSource _musicSource;\n"
            "    [SerializeField] private AudioSource _sfxSource;\n\n"
            "    private void Awake()\n    {\n"
            "        if (Instance != null) { Destroy(gameObject); return; }\n"
            "        Instance = this;\n"
            "        DontDestroyOnLoad(gameObject);\n    }\n\n"
            "    public void PlaySFX(AudioClip clip) { _sfxSource.PlayOneShot(clip); }\n"
            "    public void PlayMusic(AudioClip clip) { _musicSource.clip = clip; _musicSource.Play(); }\n"
            "}\n",
            encoding="utf-8",
        )
        created.append("Scripts/Core/AudioManager.cs")

        # ServiceLocator
        (core / "ServiceLocator.cs").write_text(
            "using System;\nusing System.Collections.Generic;\n\n"
            "public static class ServiceLocator\n{\n"
            "    private static readonly Dictionary<Type, object> _services = new();\n\n"
            "    public static void Register<T>(T service) where T : class\n    {\n"
            "        _services[typeof(T)] = service;\n    }\n\n"
            "    public static T Get<T>() where T : class\n    {\n"
            "        return _services.TryGetValue(typeof(T), out var s) ? (T)s : null;\n    }\n}\n",
            encoding="utf-8",
        )
        created.append("Scripts/Core/ServiceLocator.cs")

        # UIManager
        ui_dir = self.assets_dir / "Scripts" / "UI"
        ui_dir.mkdir(parents=True, exist_ok=True)
        (ui_dir / "UIManager.cs").write_text(
            "using UnityEngine;\n\n"
            "public class UIManager : MonoBehaviour\n{\n"
            "    public static UIManager Instance { get; private set; }\n\n"
            "    private void Awake()\n    {\n"
            "        if (Instance != null) { Destroy(gameObject); return; }\n"
            "        Instance = this;\n    }\n}\n",
            encoding="utf-8",
        )
        created.append("Scripts/UI/UIManager.cs")

        print(f"  [Unity] Wiring: {len(created)} files created")
        return {"created": created, "status": "ok"}

    def compile(self) -> CompileResult:
        # Try to find Unity Editor
        unity_paths = [
            r"C:\Program Files\Unity\Hub\Editor",
            r"C:\Program Files (x86)\Unity\Hub\Editor",
        ]
        unity_exe = None
        for base in unity_paths:
            if os.path.isdir(base):
                for ver in sorted(os.listdir(base), reverse=True):
                    candidate = os.path.join(base, ver, "Editor", "Unity.exe")
                    if os.path.isfile(candidate):
                        unity_exe = candidate
                        break
            if unity_exe:
                break

        if not unity_exe:
            cmd = f'Unity.exe -batchmode -nographics -projectPath "{self.project_dir}" -buildTarget StandaloneWindows64 -quit -logFile build.log'
            return CompileResult(
                success=False, skipped=True,
                skip_reason=f"Unity Editor not found. Run manually: {cmd}",
                command=cmd,
            )

        try:
            result = subprocess.run(
                [unity_exe, "-batchmode", "-nographics",
                 "-projectPath", str(self.project_dir),
                 "-buildTarget", "StandaloneWindows64",
                 "-quit", "-logFile", str(self.project_dir / "build.log")],
                capture_output=True, text=True, timeout=600,
            )
            log = ""
            log_file = self.project_dir / "build.log"
            if log_file.exists():
                log = log_file.read_text(encoding="utf-8", errors="ignore")
            errs = [l for l in log.splitlines() if "error CS" in l]
            warns = [l for l in log.splitlines() if "warning CS" in l]
            return CompileResult(
                success=result.returncode == 0 and not errs,
                errors=errs, warnings=warns,
                error_count=len(errs), warning_count=len(warns),
            )
        except Exception as e:
            return CompileResult(success=False, errors=[str(e)], error_count=1)

    def diagnose_errors(self, compile_result) -> list[FixAction]:
        fixes = []
        for err in (compile_result.errors or [])[:20]:
            m = re.search(r"error CS0246.*?'(\w+)'", err)
            if m:
                fixes.append(FixAction(file_path="", action="add_using",
                                       description=f"Add using for {m.group(1)}"))
        return fixes

    def apply_fixes(self, fixes: list[FixAction]) -> dict:
        return {"applied": 0, "total": len(fixes)}

    def run_tests(self) -> dict:
        return {"status": "skipped", "reason": "Unity Test Runner requires Unity Editor"}
