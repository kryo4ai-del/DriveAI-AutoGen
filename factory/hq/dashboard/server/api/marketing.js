const express = require('express');
const router = express.Router();
const { scanMarketing } = require('../scanner/marketing-scanner');

// GET /api/marketing — Gesamtstatus (READ-ONLY)
router.get('/', (req, res) => {
  try {
    const data = scanMarketing();
    res.json(data);
  } catch (err) {
    console.error('Marketing API error:', err.message);
    res.status(500).json({ error: err.message, available: false });
  }
});

// NUR GET. Kein POST, PUT, DELETE. READ-ONLY.

module.exports = router;
