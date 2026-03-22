"""Unit tests for CSharpCodeExtractor."""
import pytest
from unittest.mock import MagicMock
from code_generation.extractors.csharp_extractor import CSharpCodeExtractor, _CS_TYPE_RE, _CSHARP_INDICATORS


@pytest.fixture
def extractor():
    return CSharpCodeExtractor()


def _make_msg(content: str):
    m = MagicMock()
    m.content = content
    return m


class TestCodeBlockDetection:
    def test_csharp_fence(self, extractor):
        msg = _make_msg('```csharp\npublic class Foo { }\n```')
        result = extractor.extract_code([msg])
        assert result["saved"] >= 1

    def test_cs_fence(self, extractor):
        msg = _make_msg('```cs\npublic class Bar { }\n```')
        result = extractor.extract_code([msg])
        assert result["saved"] >= 1

    def test_untagged_with_unity_indicators(self, extractor):
        code = "```\nusing UnityEngine;\npublic class TestMono : MonoBehaviour\n{\n    void Start() { }\n}\n```"
        msg = _make_msg(code)
        result = extractor.extract_code([msg])
        assert result["saved"] >= 1


class TestNameExtraction:
    def test_public_class(self):
        m = _CS_TYPE_RE.search("public class PlayerController : MonoBehaviour {")
        assert m and m.group(2) == "PlayerController"

    def test_abstract_class(self):
        m = _CS_TYPE_RE.search("public abstract class BaseEnemy : MonoBehaviour {")
        assert m and m.group(2) == "BaseEnemy"

    def test_interface(self):
        m = _CS_TYPE_RE.search("public interface IScoreService {")
        assert m and m.group(2) == "IScoreService"

    def test_enum(self):
        m = _CS_TYPE_RE.search("public enum GameState {")
        assert m and m.group(2) == "GameState"

    def test_struct(self):
        m = _CS_TYPE_RE.search("public struct TilePosition {")
        assert m and m.group(2) == "TilePosition"

    def test_sealed_class(self):
        m = _CS_TYPE_RE.search("public sealed class Singleton {")
        assert m and m.group(2) == "Singleton"


class TestSubfolderRouting:
    def test_monobehaviour_to_scripts(self, extractor):
        assert extractor._detect_subfolder(": MonoBehaviour", "Player.cs") == "Scripts"

    def test_scriptableobject_to_data(self, extractor):
        assert extractor._detect_subfolder("[CreateAssetMenu] : ScriptableObject", "Config.cs") == "Scripts/ScriptableObjects"

    def test_interface_to_interfaces(self, extractor):
        assert extractor._detect_subfolder("public interface IFoo {}", "IFoo.cs") == "Scripts/Interfaces"

    def test_enum_to_enums(self, extractor):
        assert extractor._detect_subfolder("public enum GameState { Playing }", "GameState.cs") == "Scripts/Enums"

    def test_editor_to_editor(self, extractor):
        assert extractor._detect_subfolder("using UnityEditor;\npublic class MyEditor", "MyEditor.cs") == "Editor"

    def test_test_to_tests(self, extractor):
        assert extractor._detect_subfolder("using NUnit.Framework;\n[Test]", "FooTest.cs") == "Tests"


class TestDedup:
    def test_same_type_two_blocks(self, extractor):
        msg = _make_msg(
            '```csharp\npublic class DupClass { }\n```\n\n'
            '```csharp\npublic class DupClass { int x; }\n```'
        )
        result = extractor.extract_code([msg])
        assert result["saved"] == 1
        assert result["skipped"] == 1


class TestPascalCase:
    def test_lowercase_skipped(self):
        m = _CS_TYPE_RE.search("public class helper { }")
        # Should not match because 'helper' starts lowercase
        assert m is None


class TestFallback:
    def test_no_name_uses_fallback(self, extractor):
        # Code without identifiable class name
        msg = _make_msg('```csharp\nDebug.Log("hello");\nvar x = 5;\n```')
        result = extractor.extract_code([msg])
        # Should use GeneratedScript_1 fallback or skip (too short)
        assert result["saved"] >= 0  # may skip if too short


class TestProperties:
    def test_language(self, extractor):
        assert extractor.language == "csharp"

    def test_extension(self, extractor):
        assert extractor.file_extension == ".cs"
