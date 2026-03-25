"""Scene Validator -- deterministic validation of all Scene Forge outputs.

Validates:
- Unity scenes (.unity): YAML structure, FileID consistency, required components
- Shaders (.shader): HLSL structure, URP compliance, SRP Batcher
- Prefabs (.prefab): YAML structure, hierarchy, .meta file
- Levels (.json): Grid validity, reachability, difficulty range
"""

import json
import logging
import re
from collections import deque
from dataclasses import dataclass, field
from pathlib import Path

logger = logging.getLogger(__name__)


@dataclass
class SceneValidationResult:
    file_id: str
    file_type: str  # level, scene, shader, prefab
    file_path: str
    overall_status: str = "pass"  # pass, warn, fail
    checks: dict = field(default_factory=dict)
    warnings: list = field(default_factory=list)
    errors: list = field(default_factory=list)

    def _compute_status(self):
        if self.errors:
            self.overall_status = "fail"
        elif self.warnings:
            self.overall_status = "warn"
        else:
            self.overall_status = "pass"

    def add_check(self, name: str, passed: bool, details: str = ""):
        status = "pass" if passed else "fail"
        self.checks[name] = {"status": status, "details": details}
        if not passed:
            self.errors.append(f"{name}: {details}")
        self._compute_status()

    def add_warning(self, name: str, details: str = ""):
        self.checks[name] = {"status": "warn", "details": details}
        self.warnings.append(f"{name}: {details}")
        self._compute_status()


class SceneValidator:
    """Validates all Scene Forge generated files. Fully deterministic -- no LLM."""

    def validate_scene(self, scene_path: str) -> SceneValidationResult:
        """Validate a Unity .unity scene file."""
        path = Path(scene_path)
        result = SceneValidationResult(
            file_id=path.stem, file_type="scene", file_path=str(path),
        )

        if not path.exists():
            result.add_check("file_exists", False, "File not found")
            return result
        result.add_check("file_exists", True)

        content = path.read_text(encoding="utf-8")

        # 1. YAML header
        has_yaml = content.startswith("%YAML 1.1")
        result.add_check("yaml_header", has_yaml, "" if has_yaml else "Missing %YAML 1.1 header")

        has_tag = "%TAG !u! tag:unity3d.com,2011:" in content
        result.add_check("unity_tag", has_tag, "" if has_tag else "Missing %TAG directive")

        # 2. Parse document separators
        doc_pattern = re.compile(r"--- !u!(\d+) &(\d+)")
        docs = doc_pattern.findall(content)
        result.add_check("has_documents", len(docs) > 0, f"{len(docs)} documents found")

        # 3. No duplicate FileIDs
        file_ids = [int(fid) for _, fid in docs]
        defined_ids = set(file_ids)
        has_dupes = len(file_ids) != len(defined_ids)
        result.add_check("no_duplicate_fileids", not has_dupes,
                         f"Duplicates: {len(file_ids) - len(defined_ids)}" if has_dupes else "")

        # 4. FileID reference consistency
        ref_pattern = re.compile(r"fileID: (\d+)")
        all_refs = set()
        for m in ref_pattern.finditer(content):
            fid = int(m.group(1))
            if fid != 0 and fid != 11500000:  # 0=none, 11500000=Unity built-in
                all_refs.add(fid)
        missing_refs = all_refs - defined_ids
        result.add_check("fileid_consistency", len(missing_refs) == 0,
                         f"Missing: {missing_refs}" if missing_refs else "")

        # 5. Camera present
        has_camera = "Camera:" in content
        result.add_check("has_camera", has_camera, "" if has_camera else "No Camera component found")

        # 6. Canvas + EventSystem
        has_canvas = "Canvas:" in content
        has_eventsystem = "EventSystem" in content
        if has_canvas and not has_eventsystem:
            result.add_warning("canvas_eventsystem", "Canvas present but no EventSystem")

        # 7. File size sanity
        size = path.stat().st_size
        if size > 100000:
            result.add_warning("file_size", f"Large file: {size} bytes")

        return result

    def validate_shader(self, shader_path: str) -> SceneValidationResult:
        """Validate a .shader file."""
        path = Path(shader_path)
        result = SceneValidationResult(
            file_id=path.stem, file_type="shader", file_path=str(path),
        )

        if not path.exists():
            result.add_check("file_exists", False, "File not found")
            return result
        result.add_check("file_exists", True)

        content = path.read_text(encoding="utf-8")

        # 1. Shader declaration
        has_decl = content.lstrip().startswith("Shader \"") or content.lstrip().startswith("//") and "Shader \"" in content[:500]
        result.add_check("shader_declaration", has_decl,
                         "" if has_decl else "Missing Shader declaration")

        # 2. SubShader block
        has_sub = "SubShader" in content
        result.add_check("subshader_block", has_sub, "" if has_sub else "Missing SubShader")

        # 3. Pass block
        has_pass = re.search(r"\bPass\b", content) is not None
        result.add_check("pass_block", has_pass, "" if has_pass else "Missing Pass block")

        # 4. Vertex/Fragment pragmas
        has_vert = "#pragma vertex" in content
        has_frag = "#pragma fragment" in content
        result.add_check("vertex_pragma", has_vert, "" if has_vert else "Missing #pragma vertex")
        result.add_check("fragment_pragma", has_frag, "" if has_frag else "Missing #pragma fragment")

        # 5. URP tags
        has_urp = "UniversalPipeline" in content
        if has_urp:
            result.add_check("urp_tag", True)
        else:
            result.add_warning("urp_tag", "No UniversalPipeline tag (may be intentional)")

        # 6. SRP Batcher
        has_cbuffer = "CBUFFER_START" in content
        if has_urp and not has_cbuffer:
            result.add_warning("srp_batcher", "URP shader without CBUFFER_START (no SRP Batcher)")
        elif has_cbuffer:
            result.add_check("srp_batcher", True)

        # 7. No built-in pipeline includes in URP context
        has_builtin = "UnityCG.cginc" in content
        if has_urp and has_builtin:
            result.add_check("no_builtin_includes", False,
                             "UnityCG.cginc in URP shader -- use Core.hlsl")
        else:
            result.add_check("no_builtin_includes", True)

        # 8. No unresolved placeholders
        unresolved = re.findall(r"\{[A-Z_]+\}", content)
        if unresolved:
            result.add_warning("unresolved_placeholders", f"Found: {unresolved}")

        return result

    def validate_prefab(self, prefab_path: str) -> SceneValidationResult:
        """Validate a .prefab file."""
        path = Path(prefab_path)
        result = SceneValidationResult(
            file_id=path.stem, file_type="prefab", file_path=str(path),
        )

        if not path.exists():
            result.add_check("file_exists", False, "File not found")
            return result
        result.add_check("file_exists", True)

        content = path.read_text(encoding="utf-8")

        # 1. YAML header
        has_yaml = content.startswith("%YAML 1.1")
        result.add_check("yaml_header", has_yaml, "" if has_yaml else "Missing %YAML 1.1 header")

        # 2. Parse docs
        doc_pattern = re.compile(r"--- !u!(\d+) &(\d+)")
        docs = doc_pattern.findall(content)
        result.add_check("has_documents", len(docs) > 0, f"{len(docs)} documents found")

        # 3. No duplicate FileIDs
        file_ids = [int(fid) for _, fid in docs]
        defined_ids = set(file_ids)
        has_dupes = len(file_ids) != len(defined_ids)
        result.add_check("no_duplicate_fileids", not has_dupes,
                         f"Duplicates: {len(file_ids) - len(defined_ids)}" if has_dupes else "")

        # 4. Has root GameObject (classID 1)
        go_count = sum(1 for cid, _ in docs if cid == "1")
        result.add_check("has_gameobject", go_count > 0, f"{go_count} GameObjects" if go_count else "No GameObject")

        # 5. Root has Transform (classID 4 or 224)
        tr_count = sum(1 for cid, _ in docs if cid in ("4", "224"))
        result.add_check("has_transform", tr_count > 0, f"{tr_count} Transforms" if tr_count else "No Transform")

        # 6. Child Transforms reference valid parent
        ref_pattern = re.compile(r"fileID: (\d+)")
        all_refs = set()
        for m in ref_pattern.finditer(content):
            fid = int(m.group(1))
            if fid != 0 and fid != 11500000:
                all_refs.add(fid)
        missing_refs = all_refs - defined_ids
        result.add_check("fileid_consistency", len(missing_refs) == 0,
                         f"Missing: {missing_refs}" if missing_refs else "")

        # 7. .meta file
        meta_path = Path(str(path) + ".meta")
        has_meta = meta_path.exists()
        result.add_check("meta_file_exists", has_meta, "" if has_meta else "Missing .meta file")

        if has_meta:
            meta_content = meta_path.read_text(encoding="utf-8")
            has_guid = "guid:" in meta_content
            result.add_check("meta_has_guid", has_guid, "" if has_guid else "Meta file missing GUID")

        return result

    def validate_level(self, level_path: str) -> SceneValidationResult:
        """Validate a level .json file."""
        path = Path(level_path)
        result = SceneValidationResult(
            file_id=path.stem, file_type="level", file_path=str(path),
        )

        if not path.exists():
            result.add_check("file_exists", False, "File not found")
            return result
        result.add_check("file_exists", True)

        # 1. Valid JSON
        try:
            data = json.loads(path.read_text(encoding="utf-8"))
            result.add_check("valid_json", True)
        except json.JSONDecodeError as e:
            result.add_check("valid_json", False, str(e))
            return result

        # 2. Has grid with cells
        grid = data.get("grid", {})
        has_cells = isinstance(grid.get("cells"), list)
        result.add_check("has_grid_cells", has_cells,
                         "" if has_cells else "Missing grid.cells array")

        if not has_cells:
            return result

        cells = grid["cells"]
        width = grid.get("width", 0)
        height = grid.get("height", 0)

        # 3. Grid dimensions match
        row_count = len(cells)
        col_counts = [len(row) for row in cells if isinstance(row, list)]
        dims_ok = row_count == height and all(c == width for c in col_counts)
        result.add_check("grid_dimensions", dims_ok,
                         f"{width}x{height} expected, got {col_counts[0] if col_counts else 0}x{row_count}")

        # 4. Reachability
        if dims_ok and cells:
            reachable = self._check_reachability(cells)
            result.add_check("reachability", reachable,
                             "" if reachable else "Isolated cells detected")

        # 5. Difficulty range
        diff = data.get("difficulty_score", -1)
        in_range = 0.0 <= diff <= 1.0
        result.add_check("difficulty_range", in_range,
                         f"{diff}" if not in_range else "")

        # 6. Objectives
        has_obj = "objectives" in data and data["objectives"]
        result.add_check("has_objectives", has_obj,
                         "" if has_obj else "Missing objectives")

        return result

    def _check_reachability(self, cells: list) -> bool:
        """BFS reachability check for level grid."""
        height = len(cells)
        width = len(cells[0]) if cells else 0
        if width == 0:
            return True

        start = None
        non_blocked = 0
        for r in range(height):
            for c in range(width):
                if cells[r][c] != 0:
                    non_blocked += 1
                    if start is None:
                        start = (r, c)

        if start is None or non_blocked == 0:
            return True

        visited = set()
        queue = deque([start])
        visited.add(start)
        while queue:
            r, c = queue.popleft()
            for dr, dc in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
                nr, nc = r + dr, c + dc
                if 0 <= nr < height and 0 <= nc < width and (nr, nc) not in visited:
                    if cells[nr][nc] != 0:
                        visited.add((nr, nc))
                        queue.append((nr, nc))

        return len(visited) == non_blocked

    def validate_all(self, generated_dir: str) -> list:
        """Validate all files in generated directory."""
        gen = Path(generated_dir)
        results = []

        # Levels
        levels_dir = gen / "levels"
        if levels_dir.exists():
            for f in sorted(levels_dir.glob("*.json")):
                results.append(self.validate_level(str(f)))

        # Scenes
        scenes_dir = gen / "scenes"
        if scenes_dir.exists():
            for f in sorted(scenes_dir.glob("*.unity")):
                results.append(self.validate_scene(str(f)))

        # Shaders
        shaders_dir = gen / "shaders"
        if shaders_dir.exists():
            for f in sorted(shaders_dir.glob("*.shader")):
                results.append(self.validate_shader(str(f)))

        # Prefabs
        prefabs_dir = gen / "prefabs"
        if prefabs_dir.exists():
            for f in sorted(prefabs_dir.glob("*.prefab")):
                results.append(self.validate_prefab(str(f)))

        return results

    @staticmethod
    def summary(results: list) -> str:
        """Generate summary from validation results."""
        if not results:
            return "No files validated."

        pass_count = sum(1 for r in results if r.overall_status == "pass")
        warn_count = sum(1 for r in results if r.overall_status == "warn")
        fail_count = sum(1 for r in results if r.overall_status == "fail")

        by_type = {}
        for r in results:
            by_type.setdefault(r.file_type, []).append(r)

        lines = [
            f"Validation: {pass_count} pass, {warn_count} warn, {fail_count} fail ({len(results)} total)",
        ]
        for ft in ["level", "scene", "shader", "prefab"]:
            items = by_type.get(ft, [])
            if items:
                p = sum(1 for r in items if r.overall_status == "pass")
                w = sum(1 for r in items if r.overall_status == "warn")
                f = sum(1 for r in items if r.overall_status == "fail")
                lines.append(f"  {ft}s: {p} pass, {w} warn, {f} fail")

        if fail_count:
            lines.append("Errors:")
            for r in results:
                for err in r.errors:
                    lines.append(f"  [{r.file_id}] {err}")

        return "\n".join(lines)
