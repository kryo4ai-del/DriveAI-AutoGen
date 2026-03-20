"""iOS Assembly Line — Xcode via Mac bridge (skeleton).

iOS assembly requires macOS + Xcode. This line uses the _commands/ Git-based
queue to dispatch build tasks to the Mac agent:

1. receive_handoff() → validates .swift files
2. create_build_system() → pushes project.yml for xcodegen on Mac
3. compile() → creates _commands/ entry for Mac xcodebuild
4. Results come back via git pull from Mac agent

This is a skeleton — full implementation requires the Mac bridge.
"""

from factory.assembly.handoff_protocol import ProductionHandoff
from factory.assembly.lines.base_line import (
    BaseAssemblyLine, CompileResult, FixAction,
)


class iOSAssemblyLine(BaseAssemblyLine):
    """iOS assembly via Mac bridge. Skeleton implementation."""

    def receive_handoff(self, handoff: ProductionHandoff) -> bool:
        if handoff.platform != "ios":
            return False
        swift_files = [f for f in handoff.file_manifest if f.endswith(".swift")]
        print(f"  [iOS] Received: {len(swift_files)} .swift files (Mac bridge required)")
        return len(swift_files) > 0

    def create_build_system(self) -> dict:
        raise NotImplementedError("iOS build system requires Mac bridge (xcodegen on macOS)")

    def organize_files(self) -> dict:
        raise NotImplementedError("iOS file organization requires Mac bridge")

    def wire_app(self) -> dict:
        raise NotImplementedError("iOS app wiring requires Mac bridge")

    def compile(self) -> CompileResult:
        return CompileResult(
            success=False, skipped=True,
            skip_reason="iOS compilation requires macOS + Xcode. Use _commands/ queue.",
        )

    def diagnose_errors(self, compile_result: CompileResult) -> list[FixAction]:
        raise NotImplementedError("iOS error diagnosis requires Mac bridge")

    def apply_fixes(self, fixes: list[FixAction]) -> dict:
        raise NotImplementedError("iOS fix application requires Mac bridge")

    def run_tests(self) -> dict:
        return {"status": "skipped", "reason": "Requires macOS + Xcode simulator"}
