"""Deterministic GUID generation for Unity asset serialization."""

import hashlib


def generate_guid(name: str, namespace: str = "driveai") -> str:
    """Generate a deterministic 32-char hex GUID from name + namespace.
    Same input always produces same GUID (reproducibility).
    Unity GUIDs are 32 lowercase hex characters."""
    raw = f"{namespace}:{name}"
    return hashlib.md5(raw.encode()).hexdigest()


class FileIDAllocator:
    """Allocates unique FileIDs within a single Unity file."""

    def __init__(self, start: int = 100000):
        self._next = start

    def next(self) -> int:
        """Get next unique FileID."""
        fid = self._next
        self._next += 1
        return fid

    def next_block(self, count: int) -> list:
        """Allocate a block of consecutive FileIDs."""
        ids = list(range(self._next, self._next + count))
        self._next += count
        return ids
