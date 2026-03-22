const express = require('express');
const router = express.Router();
const fs = require('fs');
const path = require('path');
const config = require('../config');

router.get('/', (req, res) => {
  try {
    const projectsDir = config.PATHS.projects;
    if (!fs.existsSync(projectsDir)) return res.json({ projects: [], factory: {} });

    const projects = [];
    const dirs = fs.readdirSync(projectsDir);
    let totalProjects = 0;

    for (const dir of dirs) {
      const pf = path.join(projectsDir, dir, 'project.json');
      if (!fs.existsSync(pf)) continue;

      const project = JSON.parse(fs.readFileSync(pf, 'utf-8'));
      totalProjects++;

      // Only show production projects that aren't killed or archived
      if (project.project_type !== 'production') continue;
      if (project.archived) continue;
      if (project.status === 'killed') continue;

      projects.push({
        title: project.title,
        phase: getPublicPhase(project.status),
        progress: getProgressPercent(project.status),
        active: !['preproduction_done', 'live', 'sunset'].includes(project.status),
      });
    }

    res.json({
      projects,
      factory: {
        total_projects: totalProjects,
        active_projects: projects.filter(p => p.active).length,
        agents_available: 24,
      }
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

function getPublicPhase(status) {
  if (['phase1_running', 'ceo_gate_pending', 'ceo_gate_go', 'strategy_complete',
       'features_complete', 'design_complete', 'review_pending', 'review_go',
       'preproduction_done'].includes(status)) return 'Pre-Production';
  if (status.includes('production')) return 'Production';
  if (status.includes('qa') || status.includes('testing')) return 'Testing';
  if (status.includes('release') || status.includes('launch')) return 'Release';
  if (status.includes('live')) return 'Live';
  return 'In Arbeit';
}

function getProgressPercent(status) {
  const map = {
    'idea': 5, 'phase1_running': 10, 'ceo_gate_pending': 15, 'ceo_gate_go': 20,
    'strategy_complete': 30, 'features_complete': 40, 'design_complete': 50,
    'review_pending': 55, 'review_go': 60, 'preproduction_done': 65,
    'in_production': 75, 'production_done': 85, 'live': 100,
  };
  return map[status] || 50;
}

module.exports = router;
