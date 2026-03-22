import json, os
from datetime import datetime

def save_repair_report(result, project_name, output_dir='.'):
    report = {'project':project_name, 'timestamp':datetime.now().isoformat(),
        'success':result.success, 'iterations':result.iterations,
        'initial_errors':result.initial_errors, 'final_errors':result.final_errors,
        'cost':result.cost, 'history':result.history}
    path = os.path.join(output_dir, f'{project_name}_repair_report.json')
    with open(path, 'w', encoding='utf-8') as f:
        json.dump(report, f, indent=2)
    return path
