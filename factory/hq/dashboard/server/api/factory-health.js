const express = require('express');
const router = express.Router();
const { scanFactoryHealth } = require('../scanner/health-scanner');

// GET /api/health
router.get('/', (req, res) => {
  try {
    const health = scanFactoryHealth();
    res.json(health);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
