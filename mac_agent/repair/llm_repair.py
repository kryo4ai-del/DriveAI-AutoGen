import os, sys

class LLMRepair:
    def __init__(self):
        root = os.path.join(os.path.dirname(__file__), '..', '..')
        if root not in sys.path: sys.path.insert(0, root)
        try:
            from factory.brain.model_provider import get_router, get_model
            self.router = get_router()
            self.get_model = get_model
            self.available = True
        except Exception:
            self.available = False

    def fix_file(self, filepath, errors, tier=2):
        if not self.available: return False
        try: content = open(filepath, encoding='utf-8').read()
        except: return False
        parts = []
        for e in errors:
            if e.severity == 'error': parts.append('Line ' + str(e.line) + ': ' + e.message)
        edesc = chr(10).join(parts)
        profile = 'dev' if tier == 2 else 'standard'
        sel = self.get_model(agent_name='swift_repair', task_type='code_generation', profile=profile)
        prompt = 'Fix these Swift errors:' + chr(10) + edesc + chr(10) + 'File:' + chr(10) + content
        try:
            resp = self.router.call(model_id=sel['model'], provider=sel['provider'],
                messages=[{'role':'system','content':'Fix Swift errors. Return only valid Swift code.'},
                          {'role':'user','content':prompt}], max_tokens=4096)
            fixed = resp.content.strip()
            if fixed and len(fixed) > 50:
                open(filepath, 'w', encoding='utf-8').write(fixed)
                return True
        except Exception as ex:
            print('  LLM error: ' + str(ex))
        return False
