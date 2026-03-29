const express = require('express');
const router = express.Router();
const { scanBrainStatus } = require('../scanner/brain-scanner');

// GET /api/brain
router.get('/', (req, res) => {
  try {
    const status = scanBrainStatus();
    res.json(status);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
