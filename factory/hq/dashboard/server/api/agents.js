const express = require('express');
const router = express.Router();
const { scanAgentData } = require('../scanner/cost-scanner');

// GET /api/agents/:projectId
router.get('/:projectId', (req, res) => {
  try {
    const data = scanAgentData(req.params.projectId);
    res.json(data);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
