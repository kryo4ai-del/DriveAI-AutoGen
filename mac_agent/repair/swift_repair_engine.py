import os, subprocess
from dataclasses import dataclass, field

@dataclass
class RepairResult:
    success: bool = False
    iterations: int = 0
    initial_errors: int = 0
    final_errors: int = 0
    cost: float = 0.0
    history: list = field(default_factory=list)
    def summary(self):
        s = 'BUILD SUCCEEDED' if self.success else f'FAILED ({self.final_errors} errors)'
        return f'{s} | {self.iterations} iters | {self.initial_errors}->{self.final_errors}'

class SwiftRepairEngine:
    def __init__(self, project_dir, max_iterations=5):
        self.project_dir = project_dir
        self.max_iterations = max_iterations
        from mac_agent.repair.xcode_error_parser import XcodeErrorParser
        from mac_agent.repair.deterministic_fixes import DeterministicFixes
        from mac_agent.repair.llm_repair import LLMRepair
        self.parser = XcodeErrorParser()
        self.det = DeterministicFixes()
        self.llm = LLMRepair()

    def repair_and_build(self, scheme, simulator='iPhone 16 Pro'):
        cost = 0.0
        history = []
        for i in range(self.max_iterations):
            output = self._build(scheme, simulator)
            errors = self.parser.parse(output)
            ec = sum(1 for e in errors if e.severity=='error')
            print(f'  Build {i+1}: {ec} errors')
            if ec == 0:
                ie = history[0]['errors'] if history else 0
                return RepairResult(True, i+1, ie, 0, cost, history)
            history.append({'iteration':i+1, 'errors':ec})
            dr = self.det.fix_all(errors, self.project_dir)
            if dr.total_actions > 0: continue
            if self.llm.available:
                grouped = self.parser.group_by_file(errors)
                for fp, fe in grouped.items():
                    if self.llm.fix_file(fp, fe, tier=2): cost+=0.003
            else: break
        output = self._build(scheme, simulator)
        fe = sum(1 for e in self.parser.parse(output) if e.severity=='error')
        ie = history[0]['errors'] if history else 0
        return RepairResult(fe==0, len(history), ie, fe, cost, history)

    def _build(self, scheme, simulator):
        proj = None
        for item in os.listdir(self.project_dir):
            if item.endswith('.xcodeproj'): proj = os.path.join(self.project_dir, item); break
        if not proj: return 'No .xcodeproj found'
        cmd = ['xcodebuild','-project',proj,'-scheme',scheme,
               '-destination',f'platform=iOS Simulator,name={simulator}',
               '-configuration','Debug','build']
        try:
            r = subprocess.run(cmd, capture_output=True, text=True, timeout=300)
            return r.stdout + chr(10) + r.stderr
        except Exception as e: return str(e)
