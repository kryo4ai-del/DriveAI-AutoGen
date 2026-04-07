"""CodeGen configuration."""
from dataclasses import dataclass


@dataclass
class CodeGenConfig:
    model: str = "claude-sonnet-4-6"
    max_tokens: int = 4000
    temperature: float = 0.2
    max_fix_attempts: int = 3
    no_third_party: bool = True
