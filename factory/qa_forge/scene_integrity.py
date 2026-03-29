"""Scene Integrity -- validates Scene Forge outputs.

Checks levels (JSON), scenes (.unity YAML), shaders (.shader HLSL),
and prefabs (.prefab YAML) for structural integrity.
"""

import json
import logging
import re
from collections import deque
from pathlib import Path

from .config import QA_CONFIG

logger = logging.getLogger(__name__)


class SceneIntegrity:
    """Checks scene-related files for structural integrity."""

    def check_level(self, level_path: str) -> dict:
        """Check level layout JSON."""
        result = {
            "item_id": Path(level_path).stem,
            "file": str(level_path),
            "item_type": "level",
            "checks": {},
            "overall": "pass",
            "warnings": [],
            "errors": [],
        }

        path = Path(level_path)
        if not path.exists():
            result["overall"] = "fail"
            result["errors"].append(f"File not found: {level_path}")
            return result

        # 1. Valid JSON
        try:
            data = json.loads(path.read_text(encoding="utf-8"))
        except Exception as e:
            result["overall"] = "fail"
            result["errors"].append(f"Invalid JSON: {e}")
            return result
        result["checks"]["valid_json"] = {"pass": True, "details": "OK"}

        # 2. Grid dimensions match cells
        grid = data.get("grid", data.get("cells", []))
        rows = len(grid) if isinstance(grid, list) else 0
        cols = len(grid[0]) if rows > 0 and isinstance(grid[0], list) else 0
        meta_rows = data.get("rows", data.get("height", rows))
        meta_cols = data.get("cols", data.get("width", cols))

        dim_ok = rows == meta_rows and cols == meta_cols and rows > 0 and cols > 0
        result["checks"]["grid_dimensions"] = {
            "pass": dim_ok,
            "details": (f"{rows}x{cols} matches metadata" if dim_ok else
                        f"Grid {rows}x{cols} vs metadata {meta_rows}x{meta_cols}"),
        }
        if not dim_ok:
            result["errors"].append(f"Grid dimension mismatch: "
                                    f"{rows}x{cols} vs {meta_rows}x{meta_cols}")

        # 3. Grid size in range
        min_g = QA_CONFIG["min_grid_size"]
        max_g = QA_CONFIG["max_grid_size"]
        size_ok = min_g <= rows <= max_g and min_g <= cols <= max_g
        if not size_ok:
            result["warnings"].append(
                f"Grid size {rows}x{cols} outside [{min_g}, {max_g}]")

        # 4. BFS reachability (no isolated cells)
        if rows > 0 and cols > 0:
            reachable = self._bfs_reachability(grid, rows, cols)
            total = sum(1 for r in grid for c in r if c != 0 and c != -1)
            reach_ok = reachable >= total if total > 0 else True
            result["checks"]["reachability"] = {
                "pass": reach_ok,
                "details": (f"All {total} cells reachable" if reach_ok else
                            f"Only {reachable}/{total} cells reachable"),
            }
            if not reach_ok:
                result["warnings"].append(
                    f"Isolated cells: {total - reachable} unreachable")

        # 5. Difficulty score 0.0-1.0
        diff = data.get("difficulty", data.get("difficulty_score"))
        if diff is not None:
            diff_ok = 0.0 <= float(diff) <= 1.0
            result["checks"]["difficulty"] = {
                "pass": diff_ok,
                "details": (f"difficulty={diff}" if diff_ok else
                            f"difficulty={diff} outside [0, 1]"),
            }
            if not diff_ok:
                result["errors"].append(f"Difficulty {diff} outside [0, 1]")
        else:
            result["checks"]["difficulty"] = {
                "pass": "warn", "severity": "warning",
                "details": "No difficulty score found",
            }
            result["warnings"].append("No difficulty score")

        # 6. Has objectives
        objectives = data.get("objectives", data.get("goals", []))
        has_obj = bool(objectives)
        result["checks"]["objectives"] = {
            "pass": has_obj,
            "details": (f"{len(objectives)} objectives" if has_obj else
                        "No objectives defined"),
        }
        if not has_obj:
            result["warnings"].append("No objectives defined")

        # 7. Min stone types
        stone_types = set()
        for row in grid:
            if isinstance(row, list):
                for cell in row:
                    if isinstance(cell, int) and cell > 0:
                        stone_types.add(cell)
        min_st = QA_CONFIG["min_stone_types"]
        enough = len(stone_types) >= min_st
        result["checks"]["stone_types"] = {
            "pass": enough,
            "details": (f"{len(stone_types)} types (min {min_st})" if enough
                        else f"Only {len(stone_types)} types (need {min_st})"),
        }
        if not enough:
            result["warnings"].append(
                f"Only {len(stone_types)} stone types (need {min_st})")

        # Aggregate
        if result["errors"]:
            result["overall"] = "fail"
        elif result["warnings"]:
            result["overall"] = "warn"

        return result

    def check_scene(self, scene_path: str) -> dict:
        """Check Unity scene YAML."""
        result = {
            "item_id": Path(scene_path).stem,
            "file": str(scene_path),
            "item_type": "scene",
            "checks": {},
            "overall": "pass",
            "warnings": [],
            "errors": [],
        }

        path = Path(scene_path)
        if not path.exists():
            result["overall"] = "fail"
            result["errors"].append(f"File not found: {scene_path}")
            return result

        text = path.read_text(encoding="utf-8", errors="replace")

        # 1. YAML header
        has_yaml = text.startswith("%YAML")
        has_tag = "%TAG !u!" in text[:200]
        result["checks"]["yaml_header"] = {
            "pass": has_yaml and has_tag,
            "details": ("YAML header + TAG OK" if has_yaml and has_tag else
                        f"Missing: {'%YAML' if not has_yaml else ''} "
                        f"{'%TAG' if not has_tag else ''}").strip(),
        }
        if not (has_yaml and has_tag):
            result["errors"].append("Missing YAML header or TAG")

        # 2. FileID consistency (no broken refs)
        file_ids = set(re.findall(r"&(\d+)", text))
        refs = set(re.findall(r"\{fileID:\s*(\d+)\}", text))
        # Filter out 0 (null ref)
        refs.discard("0")
        broken = refs - file_ids
        result["checks"]["fileid_refs"] = {
            "pass": len(broken) == 0,
            "details": (f"{len(file_ids)} IDs, {len(refs)} refs, 0 broken"
                        if not broken else
                        f"{len(broken)} broken refs: {list(broken)[:5]}"),
        }
        if broken:
            result["warnings"].append(f"{len(broken)} broken FileID references")

        # 3. No duplicate FileIDs
        all_ids = re.findall(r"&(\d+)", text)
        dupes = set(x for x in all_ids if all_ids.count(x) > 1)
        result["checks"]["no_dupe_fileids"] = {
            "pass": len(dupes) == 0,
            "details": ("No duplicate FileIDs" if not dupes else
                        f"Duplicate FileIDs: {list(dupes)[:5]}"),
        }
        if dupes:
            result["errors"].append(f"Duplicate FileIDs: {list(dupes)[:5]}")

        # 4. Has Camera
        has_camera = "Camera:" in text or "m_Component:" in text and "Camera" in text
        result["checks"]["has_camera"] = {
            "pass": has_camera,
            "details": "Camera present" if has_camera else "No Camera found",
        }
        if not has_camera:
            result["warnings"].append("No Camera in scene")

        # 5. Has EventSystem if Canvas present
        has_canvas = "Canvas:" in text
        has_event_system = "EventSystem:" in text
        if has_canvas:
            result["checks"]["canvas_eventsystem"] = {
                "pass": has_event_system,
                "details": ("Canvas + EventSystem OK" if has_event_system else
                            "Canvas found but no EventSystem"),
            }
            if not has_event_system:
                result["warnings"].append("Canvas without EventSystem")

        # Aggregate
        if result["errors"]:
            result["overall"] = "fail"
        elif result["warnings"]:
            result["overall"] = "warn"

        return result

    def check_shader(self, shader_path: str) -> dict:
        """Check URP shader code."""
        result = {
            "item_id": Path(shader_path).stem,
            "file": str(shader_path),
            "item_type": "shader",
            "checks": {},
            "overall": "pass",
            "warnings": [],
            "errors": [],
        }

        path = Path(shader_path)
        if not path.exists():
            result["overall"] = "fail"
            result["errors"].append(f"File not found: {shader_path}")
            return result

        text = path.read_text(encoding="utf-8", errors="replace")

        # 1. Shader declaration
        has_shader = bool(re.search(r'Shader\s+"', text))
        result["checks"]["shader_decl"] = {
            "pass": has_shader,
            "details": "Shader declaration found" if has_shader else "Missing Shader declaration",
        }
        if not has_shader:
            result["errors"].append("Missing Shader declaration")

        # 2. SubShader + Pass
        has_subshader = "SubShader" in text
        has_pass = re.search(r"\bPass\s*\{", text) is not None
        result["checks"]["subshader_pass"] = {
            "pass": has_subshader and has_pass,
            "details": ("SubShader + Pass OK" if has_subshader and has_pass else
                        f"Missing: {'SubShader' if not has_subshader else ''} "
                        f"{'Pass' if not has_pass else ''}").strip(),
        }
        if not (has_subshader and has_pass):
            result["errors"].append("Missing SubShader or Pass block")

        # 3. vertex + fragment pragmas
        has_vert = "#pragma vertex" in text
        has_frag = "#pragma fragment" in text
        result["checks"]["pragmas"] = {
            "pass": has_vert and has_frag,
            "details": ("vertex + fragment pragmas OK" if has_vert and has_frag else
                        f"Missing: {'vertex' if not has_vert else ''} "
                        f"{'fragment' if not has_frag else ''}").strip(),
        }
        if not (has_vert and has_frag):
            result["errors"].append("Missing vertex/fragment pragmas")

        # 4. URP includes (not Built-in)
        has_urp = ("Packages/com.unity.render-pipelines" in text
                   or "UnityCG.cginc" not in text)
        has_builtin = "UnityCG.cginc" in text
        result["checks"]["urp_includes"] = {
            "pass": not has_builtin,
            "details": ("URP includes OK" if not has_builtin else
                        "Uses Built-in UnityCG.cginc instead of URP"),
        }
        if has_builtin:
            result["warnings"].append("Built-in shader includes detected")

        # 5. CBUFFER_START (SRP Batcher)
        has_cbuffer = "CBUFFER_START" in text
        result["checks"]["srp_batcher"] = {
            "pass": has_cbuffer,
            "details": ("SRP Batcher compatible" if has_cbuffer else
                        "Missing CBUFFER_START (SRP Batcher incompatible)"),
        }
        if not has_cbuffer:
            result["warnings"].append("Not SRP Batcher compatible")

        # Aggregate
        if result["errors"]:
            result["overall"] = "fail"
        elif result["warnings"]:
            result["overall"] = "warn"

        return result

    def check_prefab(self, prefab_path: str) -> dict:
        """Check prefab YAML."""
        result = {
            "item_id": Path(prefab_path).stem,
            "file": str(prefab_path),
            "item_type": "prefab",
            "checks": {},
            "overall": "pass",
            "warnings": [],
            "errors": [],
        }

        path = Path(prefab_path)
        if not path.exists():
            result["overall"] = "fail"
            result["errors"].append(f"File not found: {prefab_path}")
            return result

        text = path.read_text(encoding="utf-8", errors="replace")

        # 1. YAML header
        has_yaml = text.startswith("%YAML")
        result["checks"]["yaml_header"] = {
            "pass": has_yaml,
            "details": "YAML header OK" if has_yaml else "Missing YAML header",
        }
        if not has_yaml:
            result["errors"].append("Missing YAML header")

        # 2. Has root GameObject
        has_go = "GameObject:" in text
        result["checks"]["root_gameobject"] = {
            "pass": has_go,
            "details": "Root GameObject found" if has_go else "No GameObject found",
        }
        if not has_go:
            result["errors"].append("No root GameObject")

        # 3. FileID refs consistent
        file_ids = set(re.findall(r"&(\d+)", text))
        refs = set(re.findall(r"\{fileID:\s*(\d+)\}", text))
        refs.discard("0")
        broken = refs - file_ids
        result["checks"]["fileid_refs"] = {
            "pass": len(broken) == 0,
            "details": (f"{len(file_ids)} IDs, 0 broken" if not broken else
                        f"{len(broken)} broken refs"),
        }
        if broken:
            result["warnings"].append(f"{len(broken)} broken FileID refs")

        # 4. .meta file exists
        meta_path = Path(str(prefab_path) + ".meta")
        has_meta = meta_path.exists()
        result["checks"]["meta_file"] = {
            "pass": has_meta,
            "details": ".meta file present" if has_meta else "Missing .meta file",
        }
        if not has_meta:
            result["warnings"].append("Missing .meta file")

        # Aggregate
        if result["errors"]:
            result["overall"] = "fail"
        elif result["warnings"]:
            result["overall"] = "warn"

        return result

    def check_difficulty_curve(self, level_paths: list) -> dict:
        """Check difficulty progression across all levels."""
        result = {
            "item_id": "difficulty_curve",
            "item_type": "curve",
            "checks": {},
            "overall": "pass",
            "warnings": [],
            "errors": [],
        }

        difficulties = []
        for lp in sorted(level_paths):
            try:
                data = json.loads(Path(lp).read_text(encoding="utf-8"))
                d = data.get("difficulty", data.get("difficulty_score"))
                if d is not None:
                    difficulties.append(float(d))
            except Exception:
                continue

        if len(difficulties) < 2:
            result["checks"]["curve"] = {
                "pass": True,
                "details": f"Only {len(difficulties)} levels -- curve check skipped",
            }
            return result

        # 1. Monotonic (small dips OK)
        non_monotonic = 0
        for i in range(1, len(difficulties)):
            if difficulties[i] < difficulties[i - 1] - 0.05:
                non_monotonic += 1
        mono_ok = non_monotonic <= len(difficulties) * 0.2
        result["checks"]["monotonic"] = {
            "pass": mono_ok,
            "details": (f"{non_monotonic} dips in {len(difficulties)} levels"
                        if mono_ok else
                        f"Too many dips: {non_monotonic}/{len(difficulties)}"),
        }
        if not mono_ok:
            result["warnings"].append(
                f"Difficulty curve has {non_monotonic} dips")

        # 2. No large jumps
        max_jump = QA_CONFIG["max_difficulty_jump"]
        jumps = []
        for i in range(1, len(difficulties)):
            jump = difficulties[i] - difficulties[i - 1]
            if jump > max_jump:
                jumps.append((i, jump))
        jump_ok = len(jumps) == 0
        result["checks"]["no_large_jumps"] = {
            "pass": jump_ok,
            "details": ("No large jumps" if jump_ok else
                        f"{len(jumps)} jumps > {max_jump}: "
                        f"{jumps[:3]}"),
        }
        if not jump_ok:
            result["warnings"].append(
                f"{len(jumps)} difficulty jumps exceed {max_jump}")

        # 3. Tutorial levels (first 20%) under 0.2
        tutorial_end = max(1, len(difficulties) // 5)
        tutorial = difficulties[:tutorial_end]
        tutorial_ok = all(d <= 0.25 for d in tutorial)
        result["checks"]["tutorial_difficulty"] = {
            "pass": tutorial_ok,
            "details": (f"First {tutorial_end} levels: max {max(tutorial):.2f}"
                        if tutorial_ok else
                        f"Tutorial too hard: {[f'{d:.2f}' for d in tutorial]}"),
        }
        if not tutorial_ok:
            result["warnings"].append("Tutorial levels too hard")

        # Aggregate
        if result["errors"]:
            result["overall"] = "fail"
        elif result["warnings"]:
            result["overall"] = "warn"

        return result

    def check_batch(self, manifest_path: str) -> list:
        """Check all scene elements from manifest."""
        try:
            data = json.loads(
                Path(manifest_path).read_text(encoding="utf-8"))
        except Exception as e:
            logger.error("Cannot load manifest %s: %s", manifest_path, e)
            return []

        results = []
        base_dir = Path(manifest_path).parent

        # Levels
        level_paths = []
        for f in data.get("levels", {}).get("files", []):
            fp = base_dir / "levels" / f.get("filename", f.get("file", ""))
            if fp.exists():
                level_paths.append(str(fp))
                results.append(self.check_level(str(fp)))

        # Difficulty curve across all levels
        if level_paths:
            results.append(self.check_difficulty_curve(level_paths))

        # Scenes
        for f in data.get("scenes", {}).get("files", []):
            fp = base_dir / "scenes" / f.get("filename", f.get("file", ""))
            if fp.exists():
                results.append(self.check_scene(str(fp)))

        # Shaders
        for f in data.get("shaders", {}).get("files", []):
            fp = base_dir / "shaders" / f.get("filename", f.get("file", ""))
            if fp.exists():
                results.append(self.check_shader(str(fp)))

        # Prefabs
        for f in data.get("prefabs", {}).get("files", []):
            fp = base_dir / "prefabs" / f.get("filename", f.get("file", ""))
            if fp.exists():
                results.append(self.check_prefab(str(fp)))

        return results

    def summary(self, results: list) -> str:
        """Summary string."""
        p = sum(1 for r in results if r["overall"] == "pass")
        w = sum(1 for r in results if r["overall"] == "warn")
        f = sum(1 for r in results if r["overall"] == "fail")
        lines = [f"Scene Integrity: {len(results)} items -- "
                 f"Pass: {p}, Warn: {w}, Fail: {f}"]
        for r in results:
            if r["overall"] != "pass":
                typ = r.get("item_type", "?")
                lines.append(f"  [{r['overall'].upper()}] {r.get('item_id', '?')} "
                             f"({typ}): "
                             f"{'; '.join(r['errors'] + r['warnings'])}")
        return "\n".join(lines)

    # -- Helpers --

    @staticmethod
    def _bfs_reachability(grid: list, rows: int, cols: int) -> int:
        """BFS from top-left non-empty cell. Returns count of reachable cells."""
        visited = [[False] * cols for _ in range(rows)]
        start = None

        for r in range(rows):
            for c in range(cols):
                if isinstance(grid[r], list) and c < len(grid[r]):
                    val = grid[r][c]
                    if val != 0 and val != -1:
                        start = (r, c)
                        break
            if start:
                break

        if not start:
            return 0

        queue = deque([start])
        visited[start[0]][start[1]] = True
        count = 1

        while queue:
            r, c = queue.popleft()
            for dr, dc in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
                nr, nc = r + dr, c + dc
                if 0 <= nr < rows and 0 <= nc < cols and not visited[nr][nc]:
                    if isinstance(grid[nr], list) and nc < len(grid[nr]):
                        val = grid[nr][nc]
                        if val != 0 and val != -1:
                            visited[nr][nc] = True
                            count += 1
                            queue.append((nr, nc))

        return count
