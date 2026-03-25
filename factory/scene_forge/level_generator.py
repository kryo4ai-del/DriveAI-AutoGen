"""Level Layout Generator -- creates playable level layouts as data structures.

Generates Match-3 grid layouts with:
- Configurable grid sizes
- Obstacle placement
- Difficulty curves
- Initial fill validation (no pre-existing matches)
- Reachability checks (no isolated cells)
"""

import json
import random
import math
import logging
from collections import deque
from dataclasses import dataclass, field, asdict
from pathlib import Path
from typing import Optional

logger = logging.getLogger(__name__)


@dataclass
class LevelLayout:
    """A complete level layout."""
    level_id: str
    grid: dict  # {width, height, cells: 2D array}
    cell_types: dict  # {0: "blocked", 1: "normal", 2: "obstacle_ice", ...}
    stone_pool: dict  # {types: [...], weights: [...]}
    initial_fill: str  # "random_no_matches"
    objectives: dict  # {type, target, move_limit or time_limit}
    difficulty_score: float
    meta: dict  # {chapter, position, is_tutorial, tutorial_hints}

    def to_json(self) -> str:
        return json.dumps(asdict(self), indent=2)


class LevelGenerator:
    """Generates level layouts from LevelSpecs."""

    TEMPLATE_DIR = Path(__file__).parent / "level_templates"
    OUTPUT_DIR = Path(__file__).parent / "generated" / "levels"

    # Cell types
    BLOCKED = 0
    NORMAL = 1
    OBSTACLE_ICE = 2
    OBSTACLE_STONE = 3
    OBSTACLE_CHAIN = 4
    SPAWNER = 5

    CELL_TYPE_NAMES = {
        0: "blocked",
        1: "normal",
        2: "obstacle_ice",
        3: "obstacle_stone",
        4: "obstacle_chain",
        5: "spawner",
    }

    # Stone colors for Match-3
    STONE_COLORS = ["red", "blue", "green", "yellow", "purple", "white"]

    def __init__(self, output_dir: str = None, seed: int = None):
        if output_dir:
            self.OUTPUT_DIR = Path(output_dir)
        self.OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
        if seed is not None:
            random.seed(seed)

    def generate_from_spec(self, spec) -> LevelLayout:
        """Generate a single level from a LevelSpec."""
        width = spec.grid.get("width", 7)
        height = spec.grid.get("height", 9)
        stone_count = min(spec.stone_types, len(self.STONE_COLORS))

        # Determine obstacle density from spec
        obstacle_types = spec.obstacles or []
        obstacle_density = len(obstacle_types) * 0.03
        blocked_density = 0.0

        # Create grid
        grid = self._create_grid(width, height, obstacle_density, blocked_density)

        # Count obstacles
        obstacles_count = sum(
            1 for row in grid for cell in row if cell in (self.OBSTACLE_ICE, self.OBSTACLE_STONE, self.OBSTACLE_CHAIN)
        )

        # Calculate difficulty
        difficulty = self._calculate_difficulty(
            grid, stone_count, spec.move_limit, obstacles_count, spec.special_mechanics
        )

        # Build stone pool
        active_stones = self.STONE_COLORS[:stone_count]
        weights = [1.0] * stone_count

        layout = LevelLayout(
            level_id=spec.spec_id,
            grid={"width": width, "height": height, "cells": grid},
            cell_types=self.CELL_TYPE_NAMES.copy(),
            stone_pool={"types": active_stones, "weights": weights},
            initial_fill="random_no_matches",
            objectives=spec.target.copy(),
            difficulty_score=round(difficulty, 3),
            meta={
                "chapter": 1,
                "position": 0,
                "is_tutorial": spec.difficulty < 0.2,
                "tutorial_hints": ["Match 3 gems of the same color"] if spec.difficulty < 0.2 else [],
            },
        )

        self._save_level(layout)
        return layout

    def generate_campaign(
        self,
        num_levels: int,
        base_spec=None,
        stone_types_start: int = 4,
        stone_types_end: int = 6,
    ) -> list:
        """Generate a full campaign with smooth difficulty curve."""
        levels = []

        for i in range(num_levels):
            progress = i / max(num_levels - 1, 1)

            # Difficulty curve (smooth S-curve)
            raw_diff = 0.05 + 0.90 * (1 / (1 + math.exp(-8 * (progress - 0.5))))
            difficulty = round(raw_diff, 3)

            # Stone types increase gradually
            stone_count = stone_types_start + int(
                (stone_types_end - stone_types_start) * min(progress * 1.3, 1.0)
            )
            stone_count = min(stone_count, len(self.STONE_COLORS))

            # Grid size: mostly 7x9, some harder levels get 8x10
            if progress > 0.7 and i % 3 == 0:
                width, height = 8, 10
            else:
                width, height = 7, 9

            # Obstacles increase with difficulty
            obstacle_density = 0.0
            blocked_density = 0.0
            obstacle_pool = []

            if progress > 0.15:
                obstacle_density = min(0.12, progress * 0.15)
                obstacle_pool = ["ice"]
            if progress > 0.35:
                obstacle_pool.append("stone")
            if progress > 0.6:
                obstacle_pool.append("chain")
                blocked_density = min(0.08, (progress - 0.6) * 0.2)

            # Move limit decreases
            move_limit = max(15, int(35 - progress * 20))

            # Special mechanics introduced gradually
            special = []
            if progress > 0.3:
                special.append("cascade_bonus")
            if progress > 0.5:
                special.append("color_bomb")
            if progress > 0.7:
                special.append("line_clear")

            # Target score increases
            target_score = int(500 + progress * 4500)

            # Create grid
            grid = self._create_grid(width, height, obstacle_density, blocked_density)

            obstacles_count = sum(
                1 for row in grid for cell in row if cell in (self.OBSTACLE_ICE, self.OBSTACLE_STONE, self.OBSTACLE_CHAIN)
            )

            # Recalculate actual difficulty
            actual_diff = self._calculate_difficulty(
                grid, stone_count, move_limit, obstacles_count, special
            )

            # Blend target and actual difficulty
            final_diff = round(difficulty * 0.6 + actual_diff * 0.4, 3)

            # Build stone pool
            active_stones = self.STONE_COLORS[:stone_count]

            # Determine chapter
            if progress < 0.2:
                chapter = 1
            elif progress < 0.4:
                chapter = 2
            elif progress < 0.6:
                chapter = 3
            elif progress < 0.8:
                chapter = 4
            else:
                chapter = 5

            level_id = f"LVL-{i + 1:03d}"
            layout = LevelLayout(
                level_id=level_id,
                grid={"width": width, "height": height, "cells": grid},
                cell_types=self.CELL_TYPE_NAMES.copy(),
                stone_pool={"types": active_stones, "weights": [1.0] * stone_count},
                initial_fill="random_no_matches",
                objectives={"type": "score", "value": target_score, "move_limit": move_limit},
                difficulty_score=final_diff,
                meta={
                    "chapter": chapter,
                    "position": i + 1,
                    "is_tutorial": progress < 0.1,
                    "tutorial_hints": ["Match 3 gems of the same color"] if progress < 0.1 else [],
                    "special_mechanics": special,
                    "obstacles": obstacle_pool,
                },
            )

            self._save_level(layout)
            levels.append(layout)

        return levels

    def _create_grid(
        self,
        width: int,
        height: int,
        obstacle_density: float = 0.0,
        blocked_density: float = 0.0,
    ) -> list:
        """Create a grid with obstacles and blocked cells."""
        total_cells = width * height

        for attempt in range(10):
            grid = [[self.NORMAL] * width for _ in range(height)]

            # Place blocked cells
            num_blocked = int(total_cells * blocked_density)
            positions = [(r, c) for r in range(height) for c in range(width)]
            random.shuffle(positions)

            placed_blocked = 0
            for r, c in positions:
                if placed_blocked >= num_blocked:
                    break
                # Don't block top row (spawner zone) or too many adjacent
                if r > 0:
                    grid[r][c] = self.BLOCKED
                    placed_blocked += 1

            # Place obstacles on remaining normal cells
            normal_positions = [(r, c) for r in range(height) for c in range(width) if grid[r][c] == self.NORMAL]
            random.shuffle(normal_positions)
            num_obstacles = int(total_cells * obstacle_density)

            obstacle_types = [self.OBSTACLE_ICE, self.OBSTACLE_STONE, self.OBSTACLE_CHAIN]
            placed = 0
            for r, c in normal_positions:
                if placed >= num_obstacles:
                    break
                # Prefer obstacles in middle rows
                if 1 <= r <= height - 2:
                    grid[r][c] = random.choice(obstacle_types)
                    placed += 1

            if self._validate_reachability(grid):
                return grid

        # Fallback: return clean grid
        logger.warning("Grid reachability failed after 10 attempts, returning clean grid")
        return [[self.NORMAL] * width for _ in range(height)]

    def _validate_reachability(self, grid: list) -> bool:
        """Check all non-blocked cells are connected via BFS."""
        height = len(grid)
        width = len(grid[0])

        # Find first non-blocked cell
        start = None
        non_blocked_count = 0
        for r in range(height):
            for c in range(width):
                if grid[r][c] != self.BLOCKED:
                    non_blocked_count += 1
                    if start is None:
                        start = (r, c)

        if start is None or non_blocked_count == 0:
            return True

        # BFS
        visited = set()
        queue = deque([start])
        visited.add(start)

        while queue:
            r, c = queue.popleft()
            for dr, dc in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
                nr, nc = r + dr, c + dc
                if 0 <= nr < height and 0 <= nc < width and (nr, nc) not in visited:
                    if grid[nr][nc] != self.BLOCKED:
                        visited.add((nr, nc))
                        queue.append((nr, nc))

        return len(visited) == non_blocked_count

    def _validate_no_initial_matches(self, grid: list, stone_count: int) -> list:
        """Generate initial stone placement with no 3-in-a-row matches."""
        height = len(grid)
        width = len(grid[0])
        stones = [[0] * width for _ in range(height)]

        for iteration in range(100):
            has_match = False
            for r in range(height):
                for c in range(width):
                    if grid[r][c] == self.BLOCKED:
                        stones[r][c] = 0
                        continue

                    # Pick random stone avoiding matches
                    forbidden = set()

                    # Check horizontal (look at 2 left)
                    if c >= 2 and stones[r][c - 1] == stones[r][c - 2] and stones[r][c - 1] != 0:
                        forbidden.add(stones[r][c - 1])

                    # Check vertical (look at 2 above)
                    if r >= 2 and stones[r - 1][c] == stones[r - 2][c] and stones[r - 1][c] != 0:
                        forbidden.add(stones[r - 1][c])

                    available = [s for s in range(1, stone_count + 1) if s not in forbidden]
                    if available:
                        stones[r][c] = random.choice(available)
                    else:
                        stones[r][c] = random.randint(1, stone_count)
                        has_match = True

            if not has_match:
                break

        return stones

    def _calculate_difficulty(
        self, grid, stone_count, move_limit, obstacles_count, special_mechanics
    ) -> float:
        """Calculate difficulty score 0.0-1.0."""
        score = 0.0

        # Move limit factor
        if move_limit <= 15:
            score += 0.30
        elif move_limit <= 20:
            score += 0.20
        elif move_limit <= 25:
            score += 0.10

        # Stone types factor
        score += max(0, (stone_count - 3)) * 0.10

        # Obstacles factor
        score += obstacles_count * 0.02

        # Blocked cell ratio
        height = len(grid)
        width = len(grid[0])
        total = height * width
        blocked = sum(1 for row in grid for cell in row if cell == self.BLOCKED)
        score += 0.30 * (blocked / total)

        # Special mechanics
        score += len(special_mechanics or []) * 0.10

        return max(0.0, min(1.0, score))

    def _save_level(self, layout: LevelLayout) -> str:
        """Save level layout to JSON file."""
        path = self.OUTPUT_DIR / f"{layout.level_id.lower()}.json"
        path.write_text(layout.to_json(), encoding="utf-8")
        return str(path)

    def generate_batch(self, specs: list) -> list:
        """Generate levels from multiple specs."""
        return [self.generate_from_spec(s) for s in specs]

    def load_template(self, template_name: str) -> dict:
        """Load a level template from level_templates/."""
        path = self.TEMPLATE_DIR / template_name
        if not path.exists():
            raise FileNotFoundError(f"Template not found: {path}")
        return json.loads(path.read_text(encoding="utf-8"))


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    import argparse

    logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")

    parser = argparse.ArgumentParser(description="Level Generator")
    parser.add_argument("--campaign", type=int, help="Generate N-level campaign")
    parser.add_argument("--seed", type=int, default=42, help="Random seed")
    parser.add_argument("--output", help="Output directory")
    args = parser.parse_args()

    gen = LevelGenerator(output_dir=args.output, seed=args.seed)

    if args.campaign:
        levels = gen.generate_campaign(args.campaign)
        print(f"Generated {len(levels)} levels:")
        for lv in levels:
            print(f"  {lv.level_id}: difficulty={lv.difficulty_score:.3f} "
                  f"grid={lv.grid['width']}x{lv.grid['height']} "
                  f"stones={len(lv.stone_pool['types'])} "
                  f"moves={lv.objectives.get('move_limit', '?')}")
