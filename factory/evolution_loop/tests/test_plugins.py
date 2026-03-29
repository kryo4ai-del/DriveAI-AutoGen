"""Tests for P-EVO-021 -- Plugin System.

6 Tests:
  1. PluginLoader laed Game-Plugins
  2. PluginLoader laed Business-Plugin
  3. PluginLoader gibt [] fuer unbekannten Typ
  4. GameSystemsValidator mit Game-Code
  5. MechanicsConsistencyChecker mit Konstanten
  6. DataFlowValidator mit Business-Code
"""

import os
import shutil
import sys
import tempfile
import time
from pathlib import Path

_PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent.parent
if str(_PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(_PROJECT_ROOT))

from factory.evolution_loop.plugins.plugin_loader import PluginLoader
from factory.evolution_loop.plugins.base_plugin import EvaluationPlugin
from factory.evolution_loop.ldo.schema import LoopDataObject, ScoreEntry

_TMP_DIR = None


def _make_tmp_dir():
    global _TMP_DIR
    _TMP_DIR = tempfile.mkdtemp(prefix="evo_plugin_test_")
    return _TMP_DIR


def _cleanup():
    global _TMP_DIR
    if _TMP_DIR and os.path.exists(_TMP_DIR):
        shutil.rmtree(_TMP_DIR, ignore_errors=True)
    _TMP_DIR = None


def _write_file(name: str, content: str) -> str:
    """Write a temp file and return its path."""
    path = os.path.join(_TMP_DIR, name)
    with open(path, "w", encoding="utf-8") as f:
        f.write(content)
    return path


def _make_ldo(project_type: str, paths: list[str] | None = None) -> LoopDataObject:
    """Create a test LDO."""
    ldo = LoopDataObject.create_initial("plugin_test", project_type, "custom")
    if paths:
        ldo.build_artifacts.paths = paths
    return ldo


# ======================================================================
# Test 1: PluginLoader laed Game-Plugins
# ======================================================================

def test_1_loader_game():
    """PluginLoader loads 2 game plugins."""
    loader = PluginLoader()
    plugins = loader.load_plugins("game")

    assert len(plugins) == 2, f"Expected 2 game plugins, got {len(plugins)}"
    names = sorted([p.name for p in plugins])
    assert "game_systems_validator" in names, f"Missing game_systems_validator: {names}"
    assert "mechanics_consistency_checker" in names, f"Missing mechanics_consistency_checker: {names}"

    for p in plugins:
        assert isinstance(p, EvaluationPlugin), f"{p.name} is not EvaluationPlugin"

    print(f"  Loaded: {names}")
    print("  [PASS] Test 1: Game plugins loaded")


# ======================================================================
# Test 2: PluginLoader laed Business-Plugin
# ======================================================================

def test_2_loader_business():
    """PluginLoader loads 1 business plugin."""
    loader = PluginLoader()
    plugins = loader.load_plugins("business_app")

    assert len(plugins) == 1, f"Expected 1 business plugin, got {len(plugins)}"
    assert plugins[0].name == "data_flow_validator"

    print(f"  Loaded: {plugins[0].name}")
    print("  [PASS] Test 2: Business plugin loaded")


# ======================================================================
# Test 3: PluginLoader gibt [] fuer unbekannten Typ
# ======================================================================

def test_3_loader_unknown():
    """PluginLoader returns [] for unknown type."""
    loader = PluginLoader()
    plugins = loader.load_plugins("nonexistent_type_xyz")

    assert plugins == [], f"Expected [], got {plugins}"

    print("  [PASS] Test 3: Unknown type returns []")


# ======================================================================
# Test 4: GameSystemsValidator mit Game-Code
# ======================================================================

def test_4_game_systems():
    """GameSystemsValidator scores game code with known systems."""
    _cleanup()
    _make_tmp_dir()

    game_code = """
    class GameLoop {
        func update(deltaTime: Float) {
            // Game loop tick
            stateMachine.update()
        }
    }

    class StateMachine {
        var gameState: GameState = .menu
        func transition(to state: GameState) {}
    }

    func saveGame(data: SaveData) {
        let encoder = JSONEncoder()
        let encoded = try encoder.encode(data)
        UserDefaults.standard.set(encoded, forKey: "save")
    }

    func loadScene(name: String) {
        let scene = Scene(named: name)
        scene.level = currentLevel
    }

    class InputHandler {
        func handleKeyPress(_ key: KeyCode) {}
        func handleTouch(_ touch: UITouch) {}
    }
    """

    path = _write_file("game.swift", game_code)
    ldo = _make_ldo("game", [path])

    from factory.evolution_loop.plugins.game.game_systems_validator import GameSystemsValidator
    plugin = GameSystemsValidator()
    result = plugin.evaluate(ldo)

    score = result["score"]
    issues = result["issues"]
    assert isinstance(score, ScoreEntry)
    assert score.value == 100, f"Expected 100 (all 5 systems), got {score.value}"
    assert len(issues) == 0, f"Expected 0 issues, got {issues}"

    print(f"  Score: {score.value}, Issues: {len(issues)}")
    print("  [PASS] Test 4: All 5 game systems detected")
    _cleanup()


# ======================================================================
# Test 5: MechanicsConsistencyChecker mit Konstanten
# ======================================================================

def test_5_mechanics():
    """MechanicsConsistencyChecker detects bad constants."""
    _cleanup()
    _make_tmp_dir()

    code_with_issues = """
    let health = -10
    let damage = 0
    let speed = -5.0
    let scale = 1.0
    let maxLevel = 99
    let bigNumber = 99999999
    """

    path = _write_file("constants.swift", code_with_issues)
    ldo = _make_ldo("game", [path])

    from factory.evolution_loop.plugins.game.mechanics_consistency_checker import MechanicsConsistencyChecker
    plugin = MechanicsConsistencyChecker()
    result = plugin.evaluate(ldo)

    score = result["score"]
    issues = result["issues"]
    assert isinstance(score, ScoreEntry)
    assert score.value < 100, f"Expected deductions, got {score.value}"
    assert len(issues) > 0, f"Expected issues for bad constants"

    print(f"  Score: {score.value}, Issues: {len(issues)}")
    for i in issues:
        print(f"    - {i}")
    print("  [PASS] Test 5: Bad constants detected")
    _cleanup()


# ======================================================================
# Test 6: DataFlowValidator mit Business-Code
# ======================================================================

def test_6_data_flow():
    """DataFlowValidator scores business code."""
    _cleanup()
    _make_tmp_dir()

    biz_code = """
    import axios from 'axios';

    async function fetchUser(id) {
        try {
            const response = await axios.get('/api/users/' + id);
            return response.data;
        } catch (error) {
            console.error('API Error:', error);
            throw error;
        }
    }

    function validateForm(data) {
        if (!data.email || !data.email.includes('@')) {
            return { isValid: false, error: 'Invalid email' };
        }
        if (data.name.length < 2 || data.name.length > 100) {
            return { isValid: false, error: 'Name must be 2-100 chars' };
        }
        return { isValid: true };
    }

    function sanitizeInput(html) {
        return DOMPurify.sanitize(html);
    }
    """

    path = _write_file("api.js", biz_code)
    ldo = _make_ldo("business_app", [path])

    from factory.evolution_loop.plugins.business.data_flow_validator import DataFlowValidator
    plugin = DataFlowValidator()
    result = plugin.evaluate(ldo)

    score = result["score"]
    issues = result["issues"]
    assert isinstance(score, ScoreEntry)
    assert score.value >= 80, f"Expected >= 80 for good biz code, got {score.value}"

    print(f"  Score: {score.value}, Issues: {len(issues)}")
    print("  [PASS] Test 6: Business data flow validated")
    _cleanup()


# ======================================================================
# Runner
# ======================================================================

def main():
    print("\n=== P-EVO-021 Validation: Plugin System ===\n")

    tests = [
        ("Test 1: Loader (game)", test_1_loader_game),
        ("Test 2: Loader (business)", test_2_loader_business),
        ("Test 3: Loader (unknown)", test_3_loader_unknown),
        ("Test 4: GameSystemsValidator", test_4_game_systems),
        ("Test 5: MechanicsConsistencyChecker", test_5_mechanics),
        ("Test 6: DataFlowValidator", test_6_data_flow),
    ]

    start = time.time()
    passed = 0
    failed = 0

    for name, fn in tests:
        print(f"\n--- {name} ---")
        try:
            fn()
            passed += 1
        except Exception as e:
            failed += 1
            print(f"  [FAIL] {name}: {e}")
            import traceback
            traceback.print_exc()

    elapsed = time.time() - start
    _cleanup()

    print(f"\n{'='*50}")
    print(f"Result: {passed}/{len(tests)} passed, {failed} failed")
    print(f"Duration: {elapsed:.2f}s")
    print(f"{'='*50}")

    if failed:
        sys.exit(1)
    print("ALL PLUGIN TESTS PASSED")


if __name__ == "__main__":
    main()
