const express = require('express');
const router = express.Router();
const fs = require('fs');
const path = require('path');
const config = require('../config');

router.get('/', (req, res) => {
  try {
    const projectsDir = config.PATHS.projects;
    if (!fs.existsSync(projectsDir)) return res.json({ projects: [], count: 0 });

    const projects = [];
    const dirs = fs.readdirSync(projectsDir);

    for (const dir of dirs) {
      const pf = path.join(projectsDir, dir, 'project.json');
      if (!fs.existsSync(pf)) continue;

      const project = JSON.parse(fs.readFileSync(pf, 'utf-8'));
      if (project.project_type === 'iteration') continue;

      const historyStatuses = ['preproduction_done', 'in_production', 'killed', 'live', 'sunset', 'production_done'];
      if (!historyStatuses.includes(project.status)) continue;

      const created = project.created || project.updated;
      const updated = project.updated || project.created;
      const durationDays = created && updated
        ? Math.max(1, Math.ceil((new Date(updated) - new Date(created)) / (1000 * 60 * 60 * 24)))
        : null;

      const chaptersComplete = Object.values(project.chapters || {}).filter(c => c.status === 'complete').length;
      const chaptersTotal = Object.keys(project.chapters || {}).length;

      let docCount = 0;
      for (const ch of Object.values(project.chapters || {})) {
        if (ch.output_dir && fs.existsSync(ch.output_dir)) {
          docCount += fs.readdirSync(ch.output_dir).filter(f => f.endsWith('.md')).length;
        }
      }

      let pdfCount = 0;
      const pdfDir = config.PATHS.documentSecretary;
      if (fs.existsSync(pdfDir)) {
        const slug = project.project_id.toLowerCase();
        pdfCount = fs.readdirSync(pdfDir).filter(f => f.endsWith('.pdf') && f.toLowerCase().includes(slug)).length;
      }

      projects.push({
        project_id: project.project_id,
        title: project.title,
        status: project.status,
        project_type: project.project_type || 'production',
        created,
        updated,
        duration_days: durationDays,
        chapters_complete: chaptersComplete,
        chapters_total: chaptersTotal,
        documents: docCount,
        pdfs: pdfCount,
        costs: project.costs || {},
        gates: project.gates || {},
        key_metrics: project.key_metrics || {},
        result: project.status === 'killed'
          ? (project.gates?.ceo_gate?.notes || 'Keine Begruendung')
          : project.status === 'preproduction_done'
            ? 'Bereit fuer Production'
            : project.status,
      });
    }

    projects.sort((a, b) => (b.updated || '').localeCompare(a.updated || ''));
    res.json({ projects, count: projects.length });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
