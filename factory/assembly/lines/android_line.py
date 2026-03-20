"""Android Assembly Line — Gradle + Compose + Hilt."""

import os
import re
import shutil
import subprocess
from pathlib import Path

from factory.assembly.handoff_protocol import ProductionHandoff
from factory.assembly.lines.base_line import (
    BaseAssemblyLine, CompileResult, FixAction, AssemblyReport,
)

_PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent.parent


class AndroidAssemblyLine(BaseAssemblyLine):
    """Assembles Android apps from Kotlin/Compose production output."""

    def __init__(self):
        self.handoff: ProductionHandoff | None = None
        self.project_dir: Path | None = None
        self.app_dir: Path | None = None  # app/src/main/java/com/driveai/askfin/
        self.package = "com.driveai.askfin"

    def receive_handoff(self, handoff: ProductionHandoff) -> bool:
        if handoff.platform != "android" or handoff.language != "kotlin":
            print(f"  [Android] Rejected: expected android/kotlin, got {handoff.platform}/{handoff.language}")
            return False
        kt_files = [f for f in handoff.file_manifest if f.endswith(".kt")]
        if not kt_files:
            print("  [Android] Rejected: no .kt files in manifest")
            return False
        self.handoff = handoff
        self.project_dir = Path(handoff.source_directory)
        print(f"  [Android] Accepted: {len(kt_files)} .kt files from {handoff.project_name}")
        return True

    def create_build_system(self) -> dict:
        """Generate real Gradle build files for Compose + Hilt."""
        created = []

        # settings.gradle.kts
        settings_path = self.project_dir / "settings.gradle.kts"
        settings_path.write_text(
            'pluginManagement {\n'
            '    repositories {\n'
            '        google()\n'
            '        mavenCentral()\n'
            '        gradlePluginPortal()\n'
            '    }\n'
            '}\n'
            'dependencyResolutionManagement {\n'
            '    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)\n'
            '    repositories {\n'
            '        google()\n'
            '        mavenCentral()\n'
            '    }\n'
            '}\n'
            f'rootProject.name = "{self.handoff.project_name}"\n'
            'include(":app")\n',
            encoding="utf-8",
        )
        created.append("settings.gradle.kts")

        # gradle.properties
        props_path = self.project_dir / "gradle.properties"
        props_path.write_text(
            "org.gradle.jvmargs=-Xmx2048m -Dfile.encoding=UTF-8\n"
            "android.useAndroidX=true\n"
            "kotlin.code.style=official\n"
            "android.nonTransitiveRClass=true\n",
            encoding="utf-8",
        )
        created.append("gradle.properties")

        # Root build.gradle.kts
        root_build = self.project_dir / "build.gradle.kts"
        root_build.write_text(
            'plugins {\n'
            '    id("com.android.application") version "8.2.2" apply false\n'
            '    id("org.jetbrains.kotlin.android") version "1.9.22" apply false\n'
            '    id("com.google.dagger.hilt.android") version "2.50" apply false\n'
            '}\n',
            encoding="utf-8",
        )
        created.append("build.gradle.kts")

        # app/build.gradle.kts
        app_dir = self.project_dir / "app"
        app_dir.mkdir(exist_ok=True)
        app_build = app_dir / "build.gradle.kts"
        app_build.write_text(
            'plugins {\n'
            '    id("com.android.application")\n'
            '    id("org.jetbrains.kotlin.android")\n'
            '    id("com.google.dagger.hilt.android")\n'
            '    kotlin("kapt")\n'
            '}\n\n'
            'android {\n'
            '    namespace = "com.driveai.askfin"\n'
            '    compileSdk = 34\n\n'
            '    defaultConfig {\n'
            '        applicationId = "com.driveai.askfin"\n'
            '        minSdk = 26\n'
            '        targetSdk = 34\n'
            '        versionCode = 1\n'
            '        versionName = "1.0.0"\n'
            '        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"\n'
            '        vectorDrawables { useSupportLibrary = true }\n'
            '    }\n\n'
            '    buildTypes {\n'
            '        release {\n'
            '            isMinifyEnabled = false\n'
            '            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")\n'
            '        }\n'
            '    }\n\n'
            '    compileOptions {\n'
            '        sourceCompatibility = JavaVersion.VERSION_17\n'
            '        targetCompatibility = JavaVersion.VERSION_17\n'
            '    }\n\n'
            '    kotlinOptions { jvmTarget = "17" }\n\n'
            '    buildFeatures { compose = true }\n'
            '    composeOptions { kotlinCompilerExtensionVersion = "1.5.8" }\n\n'
            '    packaging { resources { excludes += "/META-INF/{AL2.0,LGPL2.1}" } }\n'
            '}\n\n'
            'dependencies {\n'
            '    // Compose BOM\n'
            '    val composeBom = platform("androidx.compose:compose-bom:2024.02.00")\n'
            '    implementation(composeBom)\n'
            '    implementation("androidx.compose.ui:ui")\n'
            '    implementation("androidx.compose.ui:ui-graphics")\n'
            '    implementation("androidx.compose.ui:ui-tooling-preview")\n'
            '    implementation("androidx.compose.material3:material3")\n'
            '    implementation("androidx.compose.material:material-icons-extended")\n'
            '    implementation("androidx.activity:activity-compose:1.8.2")\n'
            '    implementation("androidx.lifecycle:lifecycle-runtime-compose:2.7.0")\n'
            '    implementation("androidx.lifecycle:lifecycle-viewmodel-compose:2.7.0")\n'
            '    implementation("androidx.navigation:navigation-compose:2.7.7")\n\n'
            '    // Hilt\n'
            '    implementation("com.google.dagger:hilt-android:2.50")\n'
            '    kapt("com.google.dagger:hilt-android-compiler:2.50")\n'
            '    implementation("androidx.hilt:hilt-navigation-compose:1.1.0")\n\n'
            '    // Room\n'
            '    implementation("androidx.room:room-runtime:2.6.1")\n'
            '    implementation("androidx.room:room-ktx:2.6.1")\n'
            '    kapt("androidx.room:room-compiler:2.6.1")\n\n'
            '    // DataStore\n'
            '    implementation("androidx.datastore:datastore-preferences:1.0.0")\n\n'
            '    // Coroutines\n'
            '    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3")\n\n'
            '    // Testing\n'
            '    testImplementation("junit:junit:4.13.2")\n'
            '    testImplementation("io.mockk:mockk:1.13.9")\n'
            '    testImplementation("org.jetbrains.kotlinx:kotlinx-coroutines-test:1.7.3")\n'
            '    androidTestImplementation(composeBom)\n'
            '    androidTestImplementation("androidx.compose.ui:ui-test-junit4")\n'
            '    androidTestImplementation("androidx.test.ext:junit:1.1.5")\n'
            '    debugImplementation("androidx.compose.ui:ui-tooling")\n'
            '    debugImplementation("androidx.compose.ui:ui-test-manifest")\n'
            '}\n\n'
            'kapt { correctErrorTypes = true }\n',
            encoding="utf-8",
        )
        created.append("app/build.gradle.kts")

        # AndroidManifest.xml
        manifest_dir = app_dir / "src" / "main"
        manifest_dir.mkdir(parents=True, exist_ok=True)
        manifest_path = manifest_dir / "AndroidManifest.xml"
        manifest_path.write_text(
            '<?xml version="1.0" encoding="utf-8"?>\n'
            '<manifest xmlns:android="http://schemas.android.com/apk/res/android">\n\n'
            '    <application\n'
            '        android:name=".AskFinApplication"\n'
            '        android:allowBackup="true"\n'
            '        android:icon="@mipmap/ic_launcher"\n'
            '        android:label="AskFin"\n'
            '        android:roundIcon="@mipmap/ic_launcher_round"\n'
            '        android:supportsRtl="true"\n'
            '        android:theme="@style/Theme.AskFin">\n\n'
            '        <activity\n'
            '            android:name=".MainActivity"\n'
            '            android:exported="true"\n'
            '            android:theme="@style/Theme.AskFin">\n'
            '            <intent-filter>\n'
            '                <action android:name="android.intent.action.MAIN" />\n'
            '                <category android:name="android.intent.category.LAUNCHER" />\n'
            '            </intent-filter>\n'
            '        </activity>\n'
            '    </application>\n\n'
            '</manifest>\n',
            encoding="utf-8",
        )
        created.append("app/src/main/AndroidManifest.xml")

        # proguard-rules.pro
        (app_dir / "proguard-rules.pro").write_text(
            "# Add project specific ProGuard rules here.\n", encoding="utf-8"
        )
        created.append("app/proguard-rules.pro")

        print(f"  [Android] Build system: {len(created)} files created")
        return {"created": created, "status": "ok"}

    def organize_files(self) -> dict:
        """Move .kt files into proper Android package structure based on content analysis."""
        if not self.handoff:
            return {"status": "no_handoff"}

        pkg_path = os.path.join("com", "driveai", "askfin")
        src_root = self.project_dir / "app" / "src" / "main" / "java" / pkg_path
        self.app_dir = src_root

        moved = 0
        skipped = 0
        errors = 0

        for rel_path in self.handoff.file_manifest:
            if not rel_path.endswith(".kt"):
                continue
            src = self.project_dir / rel_path
            if not src.is_file():
                skipped += 1
                continue

            try:
                file_content = src.read_text(encoding="utf-8")
            except Exception:
                errors += 1
                continue

            target_sub = self._classify_file(file_content, src.name)
            target_dir = src_root / target_sub.replace("/", os.sep)
            target_dir.mkdir(parents=True, exist_ok=True)
            target_file = target_dir / src.name

            if target_file.exists():
                skipped += 1
                continue

            shutil.copy2(str(src), str(target_file))
            self._fix_package_declaration(str(target_file), target_sub)
            moved += 1

        print(f"  [Android] Organized: {moved} files, {skipped} skipped, {errors} errors")
        return {"moved": moved, "skipped": skipped, "errors": errors, "status": "ok"}

    def _classify_file(self, content: str, filename: str) -> str:
        """Classify a .kt file into the correct package subdirectory."""
        if "@Module" in content or "@InstallIn" in content:
            return "di"
        if "@Entity" in content or "@Dao" in content:
            return "data/local"
        if "@HiltViewModel" in content or ": ViewModel()" in content:
            return "ui/viewmodels"
        if "@Composable" in content:
            if "Screen" in filename or "View" in filename or "Page" in filename:
                return "ui/screens"
            return "ui/components"
        if "interface" in content and "Repository" in filename:
            return "data/repository"
        if ("Service" in filename or "UseCase" in filename) and ("class " in content or "interface " in content):
            return "domain"
        if "Theme" in filename or "Color" in filename or "Typography" in filename:
            return "ui/theme"
        if "Nav" in filename or "Route" in filename:
            return "ui/navigation"
        return "data/models"

    def _fix_package_declaration(self, filepath: str, subdir: str):
        """Update package declaration to match directory location."""
        package = "com.driveai.askfin." + subdir.replace("/", ".").replace(os.sep, ".")
        try:
            text = Path(filepath).read_text(encoding="utf-8")
            file_lines = text.splitlines()

            pkg_replaced = False
            for i, ln in enumerate(file_lines):
                if ln.strip().startswith("package "):
                    file_lines[i] = f"package {package}"
                    pkg_replaced = True
                    break

            if not pkg_replaced:
                file_lines.insert(0, f"package {package}")
                file_lines.insert(1, "")

            Path(filepath).write_text("\n".join(file_lines), encoding="utf-8")
        except Exception:
            pass

    def wire_app(self) -> dict:
        """Generate Application, MainActivity, NavHost, Hilt modules."""
        if not self.app_dir:
            return {"status": "no_app_dir"}

        created = []
        pkg = self.package

        # AskFinApplication.kt
        app_file = self.app_dir / "AskFinApplication.kt"
        app_file.parent.mkdir(parents=True, exist_ok=True)
        app_file.write_text(
            f"package {pkg}\n\n"
            f"import android.app.Application\n"
            f"import dagger.hilt.android.HiltAndroidApp\n\n"
            f"@HiltAndroidApp\n"
            f"class AskFinApplication : Application()\n",
            encoding="utf-8",
        )
        created.append("AskFinApplication.kt")

        # MainActivity.kt
        main_lines = [
            f"package {pkg}",
            "",
            "import android.os.Bundle",
            "import androidx.activity.ComponentActivity",
            "import androidx.activity.compose.setContent",
            "import androidx.compose.foundation.layout.fillMaxSize",
            "import androidx.compose.material3.MaterialTheme",
            "import androidx.compose.material3.Surface",
            "import androidx.compose.ui.Modifier",
            "import dagger.hilt.android.AndroidEntryPoint",
            f"import {pkg}.ui.navigation.AskFinNavHost",
            f"import {pkg}.ui.theme.AskFinTheme",
            "",
            "@AndroidEntryPoint",
            "class MainActivity : ComponentActivity() {",
            "    override fun onCreate(savedInstanceState: Bundle?) {",
            "        super.onCreate(savedInstanceState)",
            "        setContent {",
            "            AskFinTheme {",
            "                Surface(",
            "                    modifier = Modifier.fillMaxSize(),",
            "                    color = MaterialTheme.colorScheme.background",
            "                ) {",
            "                    AskFinNavHost()",
            "                }",
            "            }",
            "        }",
            "    }",
            "}",
        ]
        (self.app_dir / "MainActivity.kt").write_text("\n".join(main_lines), encoding="utf-8")
        created.append("MainActivity.kt")

        # NavHost
        nav_dir = self.app_dir / "ui" / "navigation"
        nav_dir.mkdir(parents=True, exist_ok=True)
        nav_lines = [
            f"package {pkg}.ui.navigation",
            "",
            "import androidx.compose.runtime.Composable",
            "import androidx.navigation.compose.NavHost",
            "import androidx.navigation.compose.composable",
            "import androidx.navigation.compose.rememberNavController",
            "",
            "sealed class Route(val route: String) {",
            '    data object Home : Route("home")',
            '    data object Training : Route("training")',
            '    data object Exam : Route("exam")',
            '    data object SkillMap : Route("skill_map")',
            '    data object Readiness : Route("readiness")',
            "}",
            "",
            "@Composable",
            "fun AskFinNavHost() {",
            "    val navController = rememberNavController()",
            "    NavHost(navController = navController, startDestination = Route.Home.route) {",
            "        composable(Route.Home.route) { /* TODO: HomeScreen */ }",
            "        composable(Route.Training.route) { /* TODO: TrainingScreen */ }",
            "        composable(Route.Exam.route) { /* TODO: ExamScreen */ }",
            "        composable(Route.SkillMap.route) { /* TODO: SkillMapScreen */ }",
            "        composable(Route.Readiness.route) { /* TODO: ReadinessScreen */ }",
            "    }",
            "}",
        ]
        (nav_dir / "AskFinNavHost.kt").write_text("\n".join(nav_lines), encoding="utf-8")
        created.append("ui/navigation/AskFinNavHost.kt")

        # Theme
        theme_dir = self.app_dir / "ui" / "theme"
        theme_dir.mkdir(parents=True, exist_ok=True)
        theme_lines = [
            f"package {pkg}.ui.theme",
            "",
            "import androidx.compose.foundation.isSystemInDarkTheme",
            "import androidx.compose.material3.MaterialTheme",
            "import androidx.compose.material3.darkColorScheme",
            "import androidx.compose.material3.lightColorScheme",
            "import androidx.compose.runtime.Composable",
            "",
            "private val DarkColorScheme = darkColorScheme()",
            "private val LightColorScheme = lightColorScheme()",
            "",
            "@Composable",
            "fun AskFinTheme(darkTheme: Boolean = isSystemInDarkTheme(), content: @Composable () -> Unit) {",
            "    MaterialTheme(colorScheme = if (darkTheme) DarkColorScheme else LightColorScheme, content = content)",
            "}",
        ]
        (theme_dir / "AskFinTheme.kt").write_text("\n".join(theme_lines), encoding="utf-8")
        created.append("ui/theme/AskFinTheme.kt")

        # Hilt AppModule
        di_dir = self.app_dir / "di"
        di_dir.mkdir(parents=True, exist_ok=True)
        di_lines = [
            f"package {pkg}.di",
            "",
            "import dagger.Module",
            "import dagger.hilt.InstallIn",
            "import dagger.hilt.components.SingletonComponent",
            "",
            "@Module",
            "@InstallIn(SingletonComponent::class)",
            "object AppModule {",
            "    // TODO: Provide dependencies",
            "}",
        ]
        (di_dir / "AppModule.kt").write_text("\n".join(di_lines), encoding="utf-8")
        created.append("di/AppModule.kt")

        print(f"  [Android] Wiring: {len(created)} files created")
        return {"created": created, "status": "ok"}

    def compile(self) -> CompileResult:
        """Attempt Gradle build. Returns SKIPPED if gradle not available."""
        gradle_cmd = "gradle" if os.name != "nt" else "gradle.bat"
        try:
            subprocess.run([gradle_cmd, "--version"], capture_output=True, timeout=10)
        except (FileNotFoundError, subprocess.TimeoutExpired):
            cmd = f"cd {self.project_dir} && {gradle_cmd} assembleDebug"
            return CompileResult(
                success=False, skipped=True,
                skip_reason=f"Gradle not available. Run manually: {cmd}",
                command=cmd,
            )
        try:
            result = subprocess.run(
                [gradle_cmd, "assembleDebug"],
                cwd=str(self.project_dir),
                capture_output=True, text=True, timeout=300,
            )
            out = result.stderr + result.stdout
            errs = [l.strip() for l in out.splitlines() if "error:" in l.lower()]
            warns = [l.strip() for l in out.splitlines() if "warning:" in l.lower()]
            return CompileResult(
                success=result.returncode == 0,
                errors=errs, warnings=warns,
                error_count=len(errs), warning_count=len(warns),
                command=f"gradle assembleDebug (in {self.project_dir})",
            )
        except subprocess.TimeoutExpired:
            return CompileResult(success=False, errors=["Build timed out (300s)"], error_count=1)

    def diagnose_errors(self, compile_result: CompileResult) -> list[FixAction]:
        fixes = []
        for error in compile_result.errors[:20]:
            m = re.search(r"Unresolved reference: (\w+)", error)
            if m:
                fixes.append(FixAction(
                    file_path="", action="add_import",
                    description=f"Add import for {m.group(1)}",
                ))
        return fixes

    def apply_fixes(self, fixes: list[FixAction]) -> dict:
        applied = 0
        for fix in fixes:
            if fix.action == "add_import" and fix.file_path and os.path.isfile(fix.file_path):
                content = Path(fix.file_path).read_text(encoding="utf-8")
                if fix.content and fix.content not in content:
                    content = fix.content + "\n" + content
                    Path(fix.file_path).write_text(content, encoding="utf-8")
                    applied += 1
        return {"applied": applied, "total": len(fixes)}

    def run_tests(self) -> dict:
        gradle_cmd = "gradle" if os.name != "nt" else "gradle.bat"
        try:
            subprocess.run([gradle_cmd, "--version"], capture_output=True, timeout=10)
        except (FileNotFoundError, subprocess.TimeoutExpired):
            return {"status": "skipped", "reason": "Gradle not available"}
        try:
            result = subprocess.run(
                [gradle_cmd, "test"], cwd=str(self.project_dir),
                capture_output=True, text=True, timeout=300,
            )
            return {"status": "passed" if result.returncode == 0 else "failed"}
        except subprocess.TimeoutExpired:
            return {"status": "timeout"}
