const express = require('express');
const router = express.Router();
const { execSync } = require('child_process');
const config = require('../config');

function runPython(code) {
  try {
    const result = execSync(
      `python -c "${code.replace(/"/g, '\\"')}"`,
      { cwd: config.FACTORY_BASE, timeout: 15000, encoding: 'utf-8' }
    );
    return JSON.parse(result.trim());
  } catch (e) {
    return { error: e.message };
  }
}

// GET /api/providers
router.get('/', (req, res) => {
  const data = runPython(
    "from dotenv import load_dotenv; load_dotenv(); " +
    "from factory.hq.providers.balance_monitor import check_all_providers; " +
    "import json; print(json.dumps(check_all_providers(), default=str))"
  );
  res.json(data);
});

// GET /api/providers/:id
router.get('/:id', (req, res) => {
  const data = runPython(
    "from dotenv import load_dotenv; load_dotenv(); " +
    "from factory.hq.providers.balance_monitor import check_all_providers; " +
    "import json; r=check_all_providers(); " +
    `p=[x for x in r['providers'] if x['id']=='${req.params.id}']; ` +
    "print(json.dumps(p[0] if p else {'error':'not found'}, default=str))"
  );
  res.json(data);
});

// POST /api/providers/:id/balance
router.post('/:id/balance', (req, res) => {
  const { balance } = req.body;
  if (balance === undefined) return res.status(400).json({ error: 'balance required' });
  const data = runPython(
    "from factory.hq.providers.balance_monitor import update_manual_balance; " +
    `import json; print(json.dumps(update_manual_balance('${req.params.id}', ${balance}), default=str))`
  );
  res.json(data);
});

// POST /api/providers/refresh
router.post('/refresh', (req, res) => {
  const data = runPython(
    "from dotenv import load_dotenv; load_dotenv(); " +
    "from factory.hq.providers.balance_monitor import check_all_providers; " +
    "import json; print(json.dumps(check_all_providers(), default=str))"
  );
  res.json(data);
});

module.exports = router;
