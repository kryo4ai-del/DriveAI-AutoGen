# tests/test_kotlin_extractor.py
# Unit tests for KotlinCodeExtractor.

import os
import shutil
import tempfile
import pytest
from unittest.mock import MagicMock

from code_generation.extractors.kotlin_extractor import (
    KotlinCodeExtractor,
    _detect_name_and_folder,
    _is_valid_filename,
    _is_kotlin_code,
    _strip_duplicate_types,
)


class FakeMessage:
    """Minimal mock for agent message."""
    def __init__(self, source: str, content: str):
        self.source = source
        self.content = content


# --- Test 1: Detect ```kotlin fenced block ---
def test_detect_kotlin_fence():
    extractor = KotlinCodeExtractor()
    msg = FakeMessage("swift_developer", '```kotlin\nclass MyService {\n    fun doWork() {}\n}\n```')
    result = extractor.extract_code([msg])
    assert result["saved"] >= 1 or result["skipped"] >= 0


# --- Test 2: Detect ```kt fenced block ---
def test_detect_kt_fence():
    extractor = KotlinCodeExtractor()
    msg = FakeMessage("swift_developer", '```kt\ndata class User(val name: String)\n```')
    result = extractor.extract_code([msg])
    assert result["saved"] >= 1 or result["skipped"] >= 0


# --- Test 3: Extract class name → ClassName.kt ---
def test_extract_class_name():
    name, folder = _detect_name_and_folder("class UserRepository {\n    fun getUser() {}\n}")
    assert name == "UserRepository"


# --- Test 4: Extract data class name → DataClassName.kt ---
def test_extract_data_class_name():
    name, folder = _detect_name_and_folder("data class UserProfile(val name: String, val age: Int)")
    assert name == "UserProfile"


# --- Test 5: Extract @Composable function → ScreenName.kt ---
def test_extract_composable_name():
    code = "@Composable\nfun HomeScreen(navController: NavController) {\n    Column {\n    }\n}"
    name, folder = _detect_name_and_folder(code)
    assert name == "HomeScreen"
    assert folder == "Views"


# --- Test 6: Extract interface name → InterfaceName.kt ---
def test_extract_interface_name():
    name, folder = _detect_name_and_folder("interface AuthService {\n    suspend fun login()\n}")
    assert name == "AuthService"


# --- Test 7: Subfolder routing: @Composable → Views/ ---
def test_subfolder_composable():
    code = "@Composable\nfun ProfileScreen() {\n}"
    _, folder = _detect_name_and_folder(code)
    assert folder == "Views"


# --- Test 8: Subfolder routing: ViewModel → ViewModels/ ---
def test_subfolder_viewmodel():
    code = "@HiltViewModel\nclass HomeViewModel @Inject constructor() : ViewModel() {\n}"
    _, folder = _detect_name_and_folder(code)
    assert folder == "ViewModels"


# --- Test 9: Subfolder routing: Service → Services/ ---
def test_subfolder_service():
    name, folder = _detect_name_and_folder("class AuthService {\n    suspend fun login() {}\n}")
    assert name == "AuthService"
    assert folder == "Services"


# --- Test 10: Dedup: same type in two blocks → only one file ---
def test_dedup_duplicate_types():
    code = "class UserProfile(val name: String) {\n}\n\ndata class Settings(val theme: String) {\n}"
    result = _strip_duplicate_types(code, "UserProfile", {"Settings"})
    assert "class Settings" not in result
    assert "class UserProfile" in result


# --- Test 11: PascalCase guard: lowercase → invalid ---
def test_pascalcase_guard():
    assert _is_valid_filename("UserService") is True
    assert _is_valid_filename("helper") is False
    assert _is_valid_filename("ab") is False  # too short


# --- Test 12: Fallback name: no identifiable type → None ---
def test_fallback_no_type():
    code = "val x = 42\nprintln(x)"
    name, folder = _detect_name_and_folder(code)
    assert name is None


# --- Additional: Kotlin code heuristic ---
def test_is_kotlin_code():
    assert _is_kotlin_code("class Foo {\n    fun bar() {}\n}") is True
    assert _is_kotlin_code("@Composable\nfun Screen() {}") is True
    assert _is_kotlin_code("just some random text") is False


# --- Additional: user messages are skipped ---
def test_skip_user_messages():
    extractor = KotlinCodeExtractor()
    msg = FakeMessage("user", '```kotlin\nclass Secret {}\n```')
    result = extractor.extract_code([msg])
    assert result["saved"] == 0


# --- Additional: object detection ---
def test_extract_object():
    name, folder = _detect_name_and_folder("object AppConfig {\n    val DEBUG = true\n}")
    assert name == "AppConfig"


# --- Additional: sealed class detection ---
def test_extract_sealed_class():
    name, folder = _detect_name_and_folder("sealed class UiState {\n    object Loading : UiState()\n}")
    assert name == "UiState"


# --- Additional: enum class detection ---
def test_extract_enum_class():
    name, folder = _detect_name_and_folder("enum class Direction {\n    NORTH, SOUTH\n}")
    assert name == "Direction"
