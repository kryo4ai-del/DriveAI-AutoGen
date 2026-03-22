import os, subprocess, shutil
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

    def repair_and_build(self, scheme, simulator='iPhone 17 Pro'):
        cost = 0.0
        history = []
        for i in range(self.max_iterations):
            # Regenerate xcodeproj before each retry (files may have changed)
            self._xcodegen()
            output = self._build(scheme, simulator)
            errors = self.parser.parse(output)
            ec = sum(1 for e in errors if e.severity=='error')
            print(f'  Repair build {i+1}: {ec} errors')
            if ec == 0:
                ie = history[0]['errors'] if history else 0
                return RepairResult(True, i+1, ie, 0, cost, history)
            history.append({'iteration': i+1, 'errors': ec,
                            'types': self.parser.get_error_summary(errors).get('by_type', {})})
            # Tier 1: Deterministic fixes (free)
            dr = self.det.fix_all(errors, self.project_dir)
            if dr.total_actions > 0:
                print(f'    Tier 1: {dr.total_actions} actions ({len(dr.quarantined)} quarantined, {len(dr.fixed_files)} fixed)')
                continue
            # Tier 2/3: LLM repair (costs money)
            if self.llm.available:
                grouped = self.parser.group_by_file(errors)
                llm_fixed = 0
                for fp, fe in grouped.items():
                    if self.llm.fix_file(fp, fe, tier=2):
                        cost += 0.003
                        llm_fixed += 1
                print(f'    Tier 2: LLM fixed {llm_fixed} files (cost: ${cost:.3f})')
                if llm_fixed == 0:
                    print('    No progress — stopping repair loop')
                    break
            else:
                print('    LLM not available — stopping after deterministic fixes')
                break
        # Final build after all repairs
        self._xcodegen()
        output = self._build(scheme, simulator)
        fe = sum(1 for e in self.parser.parse(output) if e.severity=='error')
        ie = history[0]['errors'] if history else 0
        return RepairResult(fe==0, len(history), ie, fe, cost, history)

    def _xcodegen(self):
        """Regenerate xcodeproj from project.yml."""
        yml = os.path.join(self.project_dir, 'project.yml')
        if not os.path.exists(yml):
            return
        # Remove old xcodeproj
        for item in os.listdir(self.project_dir):
            if item.endswith('.xcodeproj'):
                shutil.rmtree(os.path.join(self.project_dir, item), ignore_errors=True)
        try:
            subprocess.run(['xcodegen', 'generate', '--spec', yml],
                          cwd=self.project_dir, capture_output=True, timeout=45)
        except subprocess.TimeoutExpired:
            subprocess.run(['pkill', '-f', 'xcodegen'], capture_output=True)

    def _build(self, scheme, simulator):
        proj = None
        for item in os.listdir(self.project_dir):
            if item.endswith('.xcodeproj'): proj = os.path.join(self.project_dir, item); break
        if not proj: return 'No .xcodeproj found'
        cmd = ['xcodebuild','-project',proj,'-scheme',scheme,
               '-destination',f'platform=iOS Simulator,name={simulator}',
               '-configuration','Debug','build']
        try:
            r = subprocess.run(cmd, capture_output=True, text=True, timeout=300,
                              cwd=self.project_dir)
            return r.stdout + chr(10) + r.stderr
        except Exception as e: return str(e)
