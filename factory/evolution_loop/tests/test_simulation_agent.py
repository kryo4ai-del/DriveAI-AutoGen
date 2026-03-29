"""Tests for the Simulation Agent — P-EVO-014 Validation.

6 Tests:
  1. Static analysis with mock files
  2. Roadbook coverage (features + screens)
  3. Synthetic flow check
  4. Full simulate() integration
  5. Empty paths (no crash)
  6. Non-existent files (no crash)
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

from factory.evolution_loop.simulation_agent import SimulationAgent
from factory.evolution_loop.ldo.schema import LoopDataObject

_SWIFT_GAME_VIEW = """\
import SwiftUI

struct GameView: View {
    // TODO: Add game logic
    let apiUrl = "http://api.example.com/v1"

    var body: some View {
        VStack {
            if condition {
                if nested {
                    if deepNested {
                        if veryDeep {
                            Text("Too deep")
                        }
                    }
                }
            }
        }
    }

    func saveGame() {
        // TODO: implement
        fatalError("Not implemented")
    }

    func loadLevel() throws {
        try doSomething()
        return
        print("dead code")
    }
}
"""

_SWIFT_SAVE_SYSTEM = """\
class SaveSystem {
    func save() { }
    func load() { }
}
"""

_SWIFT_MAIN_MENU = """\
struct MainMenuView: View {
    var body: some View {
        NavigationLink(destination: GameView()) {
            Text("Start Game")
        }
    }
}
"""


def _setup_test_dir():
    """Create temp dir with mock Swift files. Returns (dir, paths)."""
    test_dir = tempfile.mkdtemp(prefix="evo_sim_test_")

    files = {
        "GameView.swift": _SWIFT_GAME_VIEW,
        "SaveSystem.swift": _SWIFT_SAVE_SYSTEM,
        "MainMenuView.swift": _SWIFT_MAIN_MENU,
    }
    paths = []
    for name, content in files.items():
        fpath = os.path.join(test_dir, name)
        with open(fpath, "w", encoding="utf-8") as f:
            f.write(content)
        paths.append(fpath)

    return test_dir, paths


# ======================================================================
# Test 1: Static Analysis
# ======================================================================

def test_1_static_analysis():
    """Static analysis detects TODOs, stubs, hardcoded values, nesting."""
    test_dir, paths = _setup_test_dir()
    agent = SimulationAgent()

    result = agent._static_analysis(paths)

    print(f"  Files: {result['total_files']}, LOC: {result['total_loc']}")
    print(f"  TODOs: {result['todos']}, FIXMEs: {result['fixmes']}, Stubs: {result['stubs']}")
    print(f"  Hardcoded: {result['hardcoded_values']}, Deep nesting: {result['deep_nesting']}")
    print(f"  Error handling ratio: {result['error_handling_ratio']:.2f}")
    print(f"  Dead code: {result['dead_code_indicators']}")
    print(f"  Languages: {result['language_distribution']}")

    assert result["total_files"] == 3, f"Expected 3 files, got {result['total_files']}"
    assert result["todos"] >= 2, f"Expected >= 2 TODOs, got {result['todos']}"
    assert result["stubs"] >= 1, f"Expected >= 1 stubs, got {result['stubs']}"
    assert result["hardcoded_values"] >= 1, f"Expected >= 1 hardcoded, got {result['hardcoded_values']}"
    assert result["deep_nesting"] >= 1, f"Expected >= 1 deep nesting, got {result['deep_nesting']}"
    assert result["language_distribution"].get("swift", 0) == 3

    print("  [PASS] Test 1: Static Analysis")
    shutil.rmtree(test_dir)
    return result


# ======================================================================
# Test 2: Roadbook Coverage
# ======================================================================

def test_2_roadbook_coverage():
    """Roadbook coverage detects features and screens by name matching."""
    test_dir, paths = _setup_test_dir()
    agent = SimulationAgent()

    ldo = LoopDataObject.create_initial("sim_test", "game", "ios")
    ldo.build_artifacts.paths = paths
    ldo.roadbook_targets.features = ["save_system", "combat", "inventory"]
    ldo.roadbook_targets.screens = ["main_menu", "game_view", "settings"]
    ldo.roadbook_targets.user_flows = ["flow_start_game"]

    coverage = agent._roadbook_coverage(ldo)

    print(f"  Features covered: {coverage['features_covered']}")
    print(f"  Features missing: {coverage['features_missing']}")
    print(f"  Screens covered: {coverage['screens_covered']}")
    print(f"  Screens missing: {coverage['screens_missing']}")
    print(f"  Coverage: {coverage['coverage_percent']:.1f}%")

    assert "save_system" in coverage["features_covered"], "save_system should be covered"
    assert len(coverage["screens_covered"]) >= 2, f"Expected >= 2 screens, got {len(coverage['screens_covered'])}"
    assert "settings" in coverage["screens_missing"] or "settings" in coverage["features_missing"], \
        "settings should be missing"
    assert coverage["coverage_percent"] > 0, "Coverage should be > 0"

    print("  [PASS] Test 2: Roadbook Coverage")
    shutil.rmtree(test_dir)
    return coverage


# ======================================================================
# Test 3: Synthetic Flows
# ======================================================================

def test_3_synthetic_flows():
    """Synthetic flow check detects navigation patterns."""
    test_dir, paths = _setup_test_dir()
    agent = SimulationAgent()

    ldo = LoopDataObject.create_initial("sim_test", "game", "ios")
    ldo.build_artifacts.paths = paths
    ldo.roadbook_targets.user_flows = ["flow_start_game"]

    flows = agent._synthetic_flow_check(ldo)

    print(f"  Flows: {len(flows)}")
    for flow in flows:
        print(f"    {flow['flow_name']}: complete={flow['is_complete']}, "
              f"screens_ref={flow['screens_referenced']}, "
              f"nav_patterns={flow['navigation_patterns_found']}")

    assert len(flows) == 1, f"Expected 1 flow, got {len(flows)}"
    assert flows[0]["flow_name"] == "flow_start_game"
    assert flows[0]["navigation_patterns_found"] >= 1, "Should find NavigationLink"

    print("  [PASS] Test 3: Synthetic Flows")
    shutil.rmtree(test_dir)
    return flows


# ======================================================================
# Test 4: Full simulate()
# ======================================================================

def test_4_full_simulate():
    """Full simulate() fills all simulation_results fields."""
    test_dir, paths = _setup_test_dir()
    agent = SimulationAgent()

    ldo = LoopDataObject.create_initial("sim_full_test", "game", "ios")
    ldo.build_artifacts.paths = paths
    ldo.roadbook_targets.features = ["save_system", "combat"]
    ldo.roadbook_targets.screens = ["main_menu", "game_view"]
    ldo.roadbook_targets.user_flows = ["flow_start"]

    ldo = agent.simulate(ldo)

    assert ldo.simulation_results.static_analysis != {}, "static_analysis empty"
    assert ldo.simulation_results.static_analysis["total_files"] == 3
    assert ldo.simulation_results.roadbook_coverage != {}, "roadbook_coverage empty"
    assert len(ldo.simulation_results.roadbook_coverage.get("features_covered", [])) >= 1
    assert isinstance(ldo.simulation_results.synthetic_flows, list)

    print(f"  static_analysis: {ldo.simulation_results.static_analysis['total_files']} files")
    print(f"  roadbook_coverage: {ldo.simulation_results.roadbook_coverage['coverage_percent']:.1f}%")
    print(f"  synthetic_flows: {len(ldo.simulation_results.synthetic_flows)} flows")
    print("  [PASS] Test 4: Full simulate()")

    shutil.rmtree(test_dir)
    return True


# ======================================================================
# Test 5: Empty paths
# ======================================================================

def test_5_empty_paths():
    """Empty paths produce default results without crash."""
    agent = SimulationAgent()
    ldo = LoopDataObject.create_initial("sim_empty", "game", "unity")

    ldo = agent.simulate(ldo)

    assert ldo.simulation_results.static_analysis.get("total_files", 0) == 0
    assert ldo.simulation_results.roadbook_coverage.get("coverage_percent", 0) == 0
    assert ldo.simulation_results.synthetic_flows == []

    print("  [PASS] Test 5: Empty paths (no crash)")
    return True


# ======================================================================
# Test 6: Non-existent files
# ======================================================================

def test_6_missing_files():
    """Non-existent file paths are handled gracefully."""
    agent = SimulationAgent()
    ldo = LoopDataObject.create_initial("sim_missing", "game", "unity")
    ldo.build_artifacts.paths = ["/nonexistent/file.swift", "/also/missing.kt"]

    ldo = agent.simulate(ldo)

    assert ldo.simulation_results.static_analysis.get("total_files", 0) == 0

    print("  [PASS] Test 6: Missing files (no crash)")
    return True


# ======================================================================
# Runner
# ======================================================================

def main():
    print("\n=== P-EVO-014 Validation: Simulation Agent ===\n")

    scenarios = [
        ("Test 1: Static Analysis", test_1_static_analysis),
        ("Test 2: Roadbook Coverage", test_2_roadbook_coverage),
        ("Test 3: Synthetic Flows", test_3_synthetic_flows),
        ("Test 4: Full simulate()", test_4_full_simulate),
        ("Test 5: Empty paths", test_5_empty_paths),
        ("Test 6: Missing files", test_6_missing_files),
    ]

    start = time.time()
    passed = 0
    failed = 0

    for name, fn in scenarios:
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

    print(f"\n{'='*50}")
    print(f"Result: {passed}/{len(scenarios)} passed, {failed} failed")
    print(f"Duration: {elapsed:.2f}s")
    print(f"{'='*50}")

    if failed:
        sys.exit(1)
    print("ALL TESTS PASSED")


if __name__ == "__main__":
    main()
