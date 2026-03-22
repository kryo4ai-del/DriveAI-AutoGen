const express = require('express');
const router = express.Router();
const fs = require('fs');
const path = require('path');
const config = require('../config');
const { executeGateDecision } = require('../actions/gate-executor');

// GET /api/gates — all pending gates
router.get('/', (req, res) => {
  try {
    const projectsDir = config.PATHS.projects;
    if (!fs.existsSync(projectsDir)) {
      return res.json({ gates: [], count: 0 });
    }

    const gates = [];

    for (const dir of fs.readdirSync(projectsDir)) {
      const projectFile = path.join(projectsDir, dir, 'project.json');
      if (!fs.existsSync(projectFile)) continue;

      const project = JSON.parse(fs.readFileSync(projectFile, 'utf-8'));
      if (project.archived) continue;

      // CEO Gate pending?
      if (project.chapters?.phase1?.status === 'complete' &&
          (!project.gates?.ceo_gate?.status || project.gates.ceo_gate.status === 'pending')) {
        gates.push({
          project_id: project.project_id,
          project_title: project.title,
          gate_type: 'ceo_gate',
          gate_label: 'CEO-Gate: Kill or Go',
          since: project.chapters.phase1.date || project.updated,
          summary: buildGateSummary(project, 'ceo_gate'),
        });
      }

      // Visual Review Gate pending?
      if (project.chapters?.kapitel5?.status === 'complete' &&
          (!project.gates?.visual_review?.status || project.gates.visual_review.status === 'pending')) {
        gates.push({
          project_id: project.project_id,
          project_title: project.title,
          gate_type: 'visual_review',
          gate_label: 'Human Review Gate',
          since: project.chapters.kapitel5.date || project.updated,
          summary: buildGateSummary(project, 'visual_review'),
        });
      }
    }

    gates.sort((a, b) => (a.since || '').localeCompare(b.since || ''));
    res.json({ gates, count: gates.length });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// POST /api/gates/:projectId/decide
router.post('/:projectId/decide', (req, res) => {
  try {
    const { gate_type, decision, reasoning, auto_trigger } = req.body;

    if (!gate_type || !decision) {
      return res.status(400).json({ error: 'gate_type and decision required' });
    }

    if (!['GO', 'KILL', 'GO_MIT_NOTES', 'REDO'].includes(decision)) {
      return res.status(400).json({ error: 'Invalid decision' });
    }

    const result = executeGateDecision(
      req.params.projectId, gate_type, decision, reasoning || '', auto_trigger || false
    );

    res.json(result);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

function buildGateSummary(project, gateType) {
  const costs = project.costs || {};

  if (gateType === 'ceo_gate') {
    return {
      chapters_complete: Object.values(project.chapters || {}).filter(c => c?.status === 'complete').length,
      serpapi_credits: costs.serpapi_credits_total || 0,
      hint: 'Phase 1 abgeschlossen. Concept Brief, Legal Report und Risk Assessment liegen vor.',
    };
  }

  if (gateType === 'visual_review') {
    const metrics = project.key_metrics || {};
    return {
      assets_total: metrics.assets_total || 0,
      assets_critical: metrics.assets_launch_critical || 0,
      blocker_count: metrics.blocker_count || 0,
      ki_warnings: metrics.ki_warnings_count || 0,
      hint: 'Visual Audit abgeschlossen. Asset-Liste, Stil-Guide und Ampel-Report liegen vor.',
    };
  }

  return {};
}

module.exports = router;
