"""Fix missing imports by scanning project for exported symbols."""

import os
import re
from pathlib import Path
from factory.assembly.repair.error_parser import CompilerError
from factory.assembly.repair.fix_strategies.base_strategy import BaseFixStrategy


# Patterns to find exported symbols per language
_TS_EXPORT_RE = re.compile(
    r"export\s+(?:default\s+)?(?:function|const|class|interface|type|enum)\s+(\w+)"
)
_KT_DECL_RE = re.compile(
    r"(?:data\s+|sealed\s+|enum\s+|abstract\s+|open\s+)?(?:class|object|interface)\s+(\w+)"
)

# Known Kotlin/Compose imports for auto-fix
KOTLIN_COMPOSE_IMPORTS = {
    # Compose Foundation Layout
    "Modifier": "import androidx.compose.ui.Modifier",
    "Column": "import androidx.compose.foundation.layout.Column",
    "Row": "import androidx.compose.foundation.layout.Row",
    "Box": "import androidx.compose.foundation.layout.Box",
    "Spacer": "import androidx.compose.foundation.layout.Spacer",
    "fillMaxWidth": "import androidx.compose.foundation.layout.fillMaxWidth",
    "fillMaxSize": "import androidx.compose.foundation.layout.fillMaxSize",
    "padding": "import androidx.compose.foundation.layout.padding",
    "height": "import androidx.compose.foundation.layout.height",
    "width": "import androidx.compose.foundation.layout.width",
    "size": "import androidx.compose.foundation.layout.size",
    "Arrangement": "import androidx.compose.foundation.layout.Arrangement",
    "dp": "import androidx.compose.ui.unit.dp",
    "sp": "import androidx.compose.ui.unit.sp",
    # Compose Material3
    "MaterialTheme": "import androidx.compose.material3.MaterialTheme",
    "Text": "import androidx.compose.material3.Text",
    "Button": "import androidx.compose.material3.Button",
    "Card": "import androidx.compose.material3.Card",
    "Surface": "import androidx.compose.material3.Surface",
    "Icon": "import androidx.compose.material3.Icon",
    "IconButton": "import androidx.compose.material3.IconButton",
    "TopAppBar": "import androidx.compose.material3.TopAppBar",
    "Scaffold": "import androidx.compose.material3.Scaffold",
    "CircularProgressIndicator": "import androidx.compose.material3.CircularProgressIndicator",
    "LinearProgressIndicator": "import androidx.compose.material3.LinearProgressIndicator",
    "AlertDialog": "import androidx.compose.material3.AlertDialog",
    "TextButton": "import androidx.compose.material3.TextButton",
    "OutlinedTextField": "import androidx.compose.material3.OutlinedTextField",
    "Divider": "import androidx.compose.material3.Divider",
    "FloatingActionButton": "import androidx.compose.material3.FloatingActionButton",
    "NavigationBar": "import androidx.compose.material3.NavigationBar",
    "NavigationBarItem": "import androidx.compose.material3.NavigationBarItem",
    "ExperimentalMaterial3Api": "import androidx.compose.material3.ExperimentalMaterial3Api",
    "ElevatedCard": "import androidx.compose.material3.ElevatedCard",
    "OutlinedCard": "import androidx.compose.material3.OutlinedCard",
    "CardDefaults": "import androidx.compose.material3.CardDefaults",
    "ButtonDefaults": "import androidx.compose.material3.ButtonDefaults",
    # Compose Runtime
    "Composable": "import androidx.compose.runtime.Composable",
    "remember": "import androidx.compose.runtime.remember",
    "mutableStateOf": "import androidx.compose.runtime.mutableStateOf",
    "getValue": "import androidx.compose.runtime.getValue",
    "setValue": "import androidx.compose.runtime.setValue",
    "collectAsState": "import androidx.compose.runtime.collectAsState",
    "LaunchedEffect": "import androidx.compose.runtime.LaunchedEffect",
    "rememberCoroutineScope": "import androidx.compose.runtime.rememberCoroutineScope",
    "derivedStateOf": "import androidx.compose.runtime.derivedStateOf",
    "mutableIntStateOf": "import androidx.compose.runtime.mutableIntStateOf",
    "mutableFloatStateOf": "import androidx.compose.runtime.mutableFloatStateOf",
    "State": "import androidx.compose.runtime.State",
    "MutableState": "import androidx.compose.runtime.MutableState",
    # Compose UI
    "Alignment": "import androidx.compose.ui.Alignment",
    "Color": "import androidx.compose.ui.graphics.Color",
    "FontWeight": "import androidx.compose.ui.text.font.FontWeight",
    "TextAlign": "import androidx.compose.ui.text.style.TextAlign",
    "ContentScale": "import androidx.compose.ui.layout.ContentScale",
    "clip": "import androidx.compose.ui.draw.clip",
    "RoundedCornerShape": "import androidx.compose.foundation.shape.RoundedCornerShape",
    "CircleShape": "import androidx.compose.foundation.shape.CircleShape",
    "Canvas": "import androidx.compose.foundation.Canvas",
    "drawBehind": "import androidx.compose.ui.draw.drawBehind",
    "graphicsLayer": "import androidx.compose.ui.graphics.graphicsLayer",
    "Brush": "import androidx.compose.ui.graphics.Brush",
    "Shadow": "import androidx.compose.ui.draw.shadow",
    # Compose Animation
    "AnimatedVisibility": "import androidx.compose.animation.AnimatedVisibility",
    "animateContentSize": "import androidx.compose.animation.animateContentSize",
    "animateFloatAsState": "import androidx.compose.animation.core.animateFloatAsState",
    "animateColorAsState": "import androidx.compose.animation.animateColorAsState",
    "tween": "import androidx.compose.animation.core.tween",
    "spring": "import androidx.compose.animation.core.spring",
    "Crossfade": "import androidx.compose.animation.Crossfade",
    "fadeIn": "import androidx.compose.animation.fadeIn",
    "fadeOut": "import androidx.compose.animation.fadeOut",
    # Compose Foundation
    "LazyColumn": "import androidx.compose.foundation.lazy.LazyColumn",
    "LazyRow": "import androidx.compose.foundation.lazy.LazyRow",
    "LazyVerticalGrid": "import androidx.compose.foundation.lazy.grid.LazyVerticalGrid",
    "GridCells": "import androidx.compose.foundation.lazy.grid.GridCells",
    "items": "import androidx.compose.foundation.lazy.items",
    "clickable": "import androidx.compose.foundation.clickable",
    "background": "import androidx.compose.foundation.background",
    "border": "import androidx.compose.foundation.border",
    "Image": "import androidx.compose.foundation.Image",
    "rememberScrollState": "import androidx.compose.foundation.rememberScrollState",
    "verticalScroll": "import androidx.compose.foundation.verticalScroll",
    "horizontalScroll": "import androidx.compose.foundation.horizontalScroll",
    # Navigation
    "NavController": "import androidx.navigation.NavController",
    "NavHostController": "import androidx.navigation.NavHostController",
    # Hilt / DI
    "hiltViewModel": "import androidx.hilt.navigation.compose.hiltViewModel",
    "HiltViewModel": "import dagger.hilt.android.lifecycle.HiltViewModel",
    "Inject": "import javax.inject.Inject",
    "AndroidEntryPoint": "import dagger.hilt.android.AndroidEntryPoint",
    "HiltAndroidApp": "import dagger.hilt.android.HiltAndroidApp",
    "Module": "import dagger.Module",
    "InstallIn": "import dagger.hilt.InstallIn",
    "SingletonComponent": "import dagger.hilt.components.SingletonComponent",
    "Provides": "import dagger.Provides",
    "Singleton": "import javax.inject.Singleton",
    # ViewModel / Lifecycle
    "ViewModel": "import androidx.lifecycle.ViewModel",
    "viewModelScope": "import androidx.lifecycle.viewModelScope",
    "StateFlow": "import kotlinx.coroutines.flow.StateFlow",
    "MutableStateFlow": "import kotlinx.coroutines.flow.MutableStateFlow",
    "asStateFlow": "import kotlinx.coroutines.flow.asStateFlow",
    "SharedFlow": "import kotlinx.coroutines.flow.SharedFlow",
    "MutableSharedFlow": "import kotlinx.coroutines.flow.MutableSharedFlow",
    # Coroutines
    "launch": "import kotlinx.coroutines.launch",
    "Dispatchers": "import kotlinx.coroutines.Dispatchers",
    "withContext": "import kotlinx.coroutines.withContext",
    "delay": "import kotlinx.coroutines.delay",
    "CoroutineScope": "import kotlinx.coroutines.CoroutineScope",
    "Job": "import kotlinx.coroutines.Job",
    "SupervisorJob": "import kotlinx.coroutines.SupervisorJob",
    # Room
    "Entity": "import androidx.room.Entity",
    "PrimaryKey": "import androidx.room.PrimaryKey",
    "Dao": "import androidx.room.Dao",
    "Database": "import androidx.room.Database",
    "RoomDatabase": "import androidx.room.RoomDatabase",
    "Insert": "import androidx.room.Insert",
    "Query": "import androidx.room.Query",
    "Delete": "import androidx.room.Delete",
    "Update": "import androidx.room.Update",
    "OnConflictStrategy": "import androidx.room.OnConflictStrategy",
    # Android
    "Context": "import android.content.Context",
    "Bundle": "import android.os.Bundle",
    "ComponentActivity": "import androidx.activity.ComponentActivity",
    "setContent": "import androidx.activity.compose.setContent",
    "Log": "import android.util.Log",
    "Toast": "import android.widget.Toast",
    # Preview
    "Preview": "import androidx.compose.ui.tooling.preview.Preview",
    # --- Step 32 additions ---
    "semantics": "import androidx.compose.ui.semantics.semantics",
    "contentDescription": "import androidx.compose.ui.semantics.contentDescription",
    "testTag": "import androidx.compose.ui.platform.testTag",
    "Role": "import androidx.compose.ui.semantics.Role",
    "painterResource": "import androidx.compose.ui.res.painterResource",
    "stringResource": "import androidx.compose.ui.res.stringResource",
    "alpha": "import androidx.compose.ui.draw.alpha",
    "scale": "import androidx.compose.ui.draw.scale",
    "rotate": "import androidx.compose.ui.draw.rotate",
    "shadow": "import androidx.compose.ui.draw.shadow",
    "ScrollState": "import androidx.compose.foundation.ScrollState",
    "BasicTextField": "import androidx.compose.foundation.text.BasicTextField",
    "KeyboardOptions": "import androidx.compose.foundation.text.KeyboardOptions",
    "TextFieldDefaults": "import androidx.compose.material3.TextFieldDefaults",
    "TopAppBarDefaults": "import androidx.compose.material3.TopAppBarDefaults",
    "SnackbarHost": "import androidx.compose.material3.SnackbarHost",
    "SnackbarHostState": "import androidx.compose.material3.SnackbarHostState",
    "Tab": "import androidx.compose.material3.Tab",
    "TabRow": "import androidx.compose.material3.TabRow",
    "Badge": "import androidx.compose.material3.Badge",
    "Checkbox": "import androidx.compose.material3.Checkbox",
    "RadioButton": "import androidx.compose.material3.RadioButton",
    "Switch": "import androidx.compose.material3.Switch",
    "Slider": "import androidx.compose.material3.Slider",
    "DropdownMenu": "import androidx.compose.material3.DropdownMenu",
    "DropdownMenuItem": "import androidx.compose.material3.DropdownMenuItem",
    "FilledTonalButton": "import androidx.compose.material3.FilledTonalButton",
    "OutlinedButton": "import androidx.compose.material3.OutlinedButton",
    "slideInVertically": "import androidx.compose.animation.slideInVertically",
    "slideOutVertically": "import androidx.compose.animation.slideOutVertically",
    "updateTransition": "import androidx.compose.animation.core.updateTransition",
    "infiniteRepeatable": "import androidx.compose.animation.core.infiniteRepeatable",
    "rememberInfiniteTransition": "import androidx.compose.animation.core.rememberInfiniteTransition",
    "collectAsStateWithLifecycle": "import androidx.lifecycle.compose.collectAsStateWithLifecycle",
    "UUID": "import java.util.UUID",
    "Instant": "import java.time.Instant",
    "LocalDateTime": "import java.time.LocalDateTime",
    "Duration": "import java.time.Duration",
    "Locale": "import java.util.Locale",
    "Date": "import java.util.Date",
    "Calendar": "import java.util.Calendar",
    "TimeUnit": "import java.util.concurrent.TimeUnit",
    "Serializable": "import java.io.Serializable",
    "IOException": "import java.io.IOException",
    "CountDownTimer": "import android.os.CountDownTimer",
    "ColumnInfo": "import androidx.room.ColumnInfo",
    "ForeignKey": "import androidx.room.ForeignKey",
    "TypeConverter": "import androidx.room.TypeConverter",
    "TypeConverters": "import androidx.room.TypeConverters",
    "Icons": "import androidx.compose.material.icons.Icons",
    "HapticFeedback": "import android.view.HapticFeedbackConstants",
    "exp": "import kotlin.math.exp",
    "sqrt": "import kotlin.math.sqrt",
    "abs": "import kotlin.math.abs",
    "min": "import kotlin.math.min",
    "max": "import kotlin.math.max",
    "roundToInt": "import kotlin.math.roundToInt",
    "ceil": "import kotlin.math.ceil",
    "floor": "import kotlin.math.floor",
}


class MissingImportFixer(BaseFixStrategy):
    """Fix 'Cannot find name X' by adding the correct import."""

    def can_fix(self, error: CompilerError) -> bool:
        return error.category == "missing_import"

    def apply(self, error: CompilerError, project_files: dict | None = None, project_dir: str = "") -> bool:
        if not project_dir or not error.file_path:
            return False

        # Extract the missing symbol name
        symbol = self._extract_symbol(error)
        if not symbol:
            return False

        # Find which file exports this symbol
        source_file = self._find_export(symbol, project_dir, error.language)
        if not source_file:
            return False

        # For Kotlin known imports, directly add
        if source_file == "KNOWN_IMPORT" and error.language == "kotlin":
            error_file = os.path.join(project_dir, error.file_path)
            return self._add_import(error_file, symbol, "", error.language)

        # Build relative import path
        error_file = os.path.join(project_dir, error.file_path)
        import_path = self._build_import_path(error_file, source_file, error.language)
        if not import_path:
            return False

        # Add import to the file
        return self._add_import(error_file, symbol, import_path, error.language)

    def _extract_symbol(self, error: CompilerError) -> str:
        # TS2304: Cannot find name 'AnswerResult'.
        m = re.search(r"Cannot find name '(\w+)'", error.message)
        if m:
            return m.group(1)
        # TS2305: Module has no exported member 'X'
        m = re.search(r"no exported member '(\w+)'", error.message)
        if m:
            return m.group(1)
        # Kotlin: Unresolved reference: X
        m = re.search(r"Unresolved reference:\s*(\w+)", error.message)
        if m:
            return m.group(1)
        return ""

    def _find_export(self, symbol: str, project_dir: str, language: str) -> str:
        # Kotlin: check known framework imports first
        if language == "kotlin" and symbol in KOTLIN_COMPOSE_IMPORTS:
            return "KNOWN_IMPORT"  # Signal to use the known import

        """Scan project for a file that exports the symbol."""
        exts = {
            "typescript": (".ts", ".tsx"),
            "kotlin": (".kt",),
            "swift": (".swift",),
        }.get(language, (".ts", ".tsx"))

        for root, _, files in os.walk(project_dir):
            if any(skip in root for skip in ("node_modules", "quarantine", ".git", "__pycache__")):
                continue
            for fname in files:
                if not fname.endswith(exts):
                    continue
                fpath = os.path.join(root, fname)
                try:
                    content = Path(fpath).read_text(encoding="utf-8", errors="ignore")
                except Exception:
                    continue

                if language == "typescript":
                    for m in _TS_EXPORT_RE.finditer(content):
                        if m.group(1) == symbol:
                            return fpath
                elif language == "kotlin":
                    for m in _KT_DECL_RE.finditer(content):
                        if m.group(1) == symbol:
                            return fpath
                elif language == "swift":
                    if re.search(rf"\b(?:struct|class|enum|protocol)\s+{re.escape(symbol)}\b", content):
                        return fpath
        return ""

    def _build_import_path(self, from_file: str, to_file: str, language: str) -> str:
        if language == "typescript":
            from_dir = os.path.dirname(from_file)
            rel = os.path.relpath(to_file, from_dir).replace("\\", "/")
            # Remove extension
            for ext in (".tsx", ".ts"):
                if rel.endswith(ext):
                    rel = rel[:-len(ext)]
                    break
            if not rel.startswith("."):
                rel = "./" + rel
            return rel
        return ""

    def _add_import(self, file_path: str, symbol: str, import_path: str, language: str) -> bool:
        # For Kotlin: check known Compose imports first
        if language == "kotlin" and symbol in KOTLIN_COMPOSE_IMPORTS:
            import_line = KOTLIN_COMPOSE_IMPORTS[symbol]
            try:
                content = Path(file_path).read_text(encoding="utf-8")
                if import_line in content:
                    return False  # already imported
                lines = content.splitlines()
                insert_idx = 0
                for i, line in enumerate(lines):
                    if line.strip().startswith("import "):
                        insert_idx = i + 1
                    elif line.strip().startswith("package "):
                        insert_idx = i + 1
                lines.insert(insert_idx, import_line)
                Path(file_path).write_text("\n".join(lines), encoding="utf-8")
                return True
            except Exception:
                return False

        try:
            content = Path(file_path).read_text(encoding="utf-8")
        except Exception:
            return False

        if language == "typescript":
            import_line = f"import {{ {symbol} }} from '{import_path}';"
            # Check if already imported
            if symbol in content and "import" in content and import_path in content:
                return False
            # Add after last import or at top
            lines = content.splitlines()
            insert_idx = 0
            for i, line in enumerate(lines):
                if line.strip().startswith("import "):
                    insert_idx = i + 1
                elif line.strip().startswith("'use client'") or line.strip().startswith('"use client"'):
                    insert_idx = i + 1
            lines.insert(insert_idx, import_line)
            Path(file_path).write_text("\n".join(lines), encoding="utf-8")
            return True
        return False
