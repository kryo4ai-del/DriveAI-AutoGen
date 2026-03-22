const express = require('express');
const router = express.Router();
const fs = require('fs');
const path = require('path');
const config = require('../config');
const { parsePipelineSummary, parseGateDecision } = require('../scanner/summary-parser');

function loadAllProjects() {
  const projectsDir = config.PATHS.projects;
  if (!fs.existsSync(projectsDir)) return [];

  const projects = [];
  for (const dir of fs.readdirSync(projectsDir)) {
    const projectFile = path.join(projectsDir, dir, 'project.json');
    if (fs.existsSync(projectFile)) {
      try {
        projects.push(JSON.parse(fs.readFileSync(projectFile, 'utf-8')));
      } catch (e) {
        console.error(`Error parsing ${projectFile}:`, e.message);
      }
    }
  }
  return projects;
}

const CHAPTER_CONFIG = [
  { key: 'phase1', label: 'Phase 1: Pre-Production', gateAfter: 'ceo_gate', gateLabel: 'CEO-Gate: Kill or Go', gateFile: 'ceo_gate_decision.md' },
  { key: 'kapitel3', label: 'Kapitel 3: Market Strategy', gateAfter: null },
  { key: 'kapitel4', label: 'Kapitel 4: MVP & Features', gateAfter: null },
  { key: 'kapitel45', label: 'Kapitel 4.5: Design Vision', gateAfter: null },
  { key: 'kapitel5', label: 'Kapitel 5: Visual Audit', gateAfter: 'visual_review', gateLabel: 'Human Review Gate', gateFile: 'review_decision.md' },
  { key: 'kapitel6', label: 'Kapitel 6: Roadbook Assembly', gateAfter: null },
];

function listDirFiles(dirPath) {
  if (!dirPath || !fs.existsSync(dirPath)) return [];
  const files = [];
  for (const f of fs.readdirSync(dirPath)) {
    const fp = path.join(dirPath, f);
    const stat = fs.statSync(fp);
    if (stat.isFile()) {
      const sizeKB = Math.round(stat.size / 1024);
      files.push({ name: f, size: `${sizeKB} KB`, path: fp });
    }
  }
  return files;
}

// GET /api/projects?type=production|test|all&archived=true|false
router.get('/', (req, res) => {
  try {
    const showType = req.query.type || 'production';
    const showArchived = req.query.archived === 'true';

    let projects = loadAllProjects();

    if (showType !== 'all') {
      projects = projects.filter(p => (p.project_type || 'production') === showType);
    }
    if (!showArchived) {
      projects = projects.filter(p => !p.archived);
    }

    projects.sort((a, b) => {
      if (a.status === 'killed' && b.status !== 'killed') return 1;
      if (a.status !== 'killed' && b.status === 'killed') return -1;
      return (b.updated || '').localeCompare(a.updated || '');
    });

    res.json({ projects, count: projects.length });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// GET /api/projects/:id
router.get('/:id', (req, res) => {
  try {
    const projectFile = path.join(config.PATHS.projects, req.params.id, 'project.json');
    if (!fs.existsSync(projectFile)) {
      return res.status(404).json({ error: 'Project not found' });
    }
    res.json(JSON.parse(fs.readFileSync(projectFile, 'utf-8')));
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// GET /api/projects/:id/timeline
router.get('/:id/timeline', (req, res) => {
  try {
    const projectFile = path.join(config.PATHS.projects, req.params.id, 'project.json');
    if (!fs.existsSync(projectFile)) {
      return res.status(404).json({ error: 'Project not found' });
    }

    const project = JSON.parse(fs.readFileSync(projectFile, 'utf-8'));
    const timeline = [];

    for (const chapterCfg of CHAPTER_CONFIG) {
      const chapter = project.chapters?.[chapterCfg.key];
      if (!chapter || chapter.status === 'not_started') {
        timeline.push({
          phase: chapterCfg.label,
          chapter_key: chapterCfg.key,
          status: 'not_started',
          date: null,
          agents: [],
          documents: [],
          serpapi_total: 0,
          llm_cost: 0,
        });
      } else {
        let outputDir = chapter.output_dir || '';
        // Resolve relative paths against factory base
        if (outputDir && !path.isAbsolute(outputDir)) {
          outputDir = path.join(config.FACTORY_BASE, outputDir);
        }
        let agents = [];
        let serpApi = 0;
        let date = chapter.date || null;

        const summaryPath = path.join(outputDir, 'pipeline_summary.md');
        if (outputDir && fs.existsSync(summaryPath)) {
          const parsed = parsePipelineSummary(fs.readFileSync(summaryPath, 'utf-8'));
          agents = parsed.agents;
          serpApi = parsed.serpApi;
          if (parsed.date) date = parsed.date;
        }

        const documents = listDirFiles(outputDir);

        timeline.push({
          phase: chapterCfg.label,
          chapter_key: chapterCfg.key,
          status: chapter.status || 'unknown',
          date,
          agents,
          documents,
          serpapi_total: serpApi,
          llm_cost: 0,
        });
      }

      // Gate entry
      if (chapterCfg.gateAfter) {
        const gate = project.gates?.[chapterCfg.gateAfter];
        const gateEntry = {
          phase: chapterCfg.gateLabel,
          chapter_key: chapterCfg.gateAfter,
          type: 'gate',
          status: gate?.status || 'pending',
          decision: gate?.status || 'pending',
          date: gate?.date || null,
          notes: gate?.notes || '',
        };

        const ch = project.chapters?.[chapterCfg.key];
        if (ch?.output_dir && chapterCfg.gateFile) {
          let chOutDir = ch.output_dir;
          if (chOutDir && !path.isAbsolute(chOutDir)) chOutDir = path.join(config.FACTORY_BASE, chOutDir);
          const gateFilePath = path.join(chOutDir, chapterCfg.gateFile);
          if (fs.existsSync(gateFilePath)) {
            const parsed = parseGateDecision(fs.readFileSync(gateFilePath, 'utf-8'));
            gateEntry.decision = parsed.decision;
            if (parsed.date) gateEntry.date = parsed.date;
            if (parsed.notes) gateEntry.notes = parsed.notes;
          }
        }

        timeline.push(gateEntry);
      }
    }

    res.json({ project, timeline });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// POST /api/projects/:id/archive
router.post('/:id/archive', (req, res) => {
  try {
    const projectFile = path.join(config.PATHS.projects, req.params.id, 'project.json');
    if (!fs.existsSync(projectFile)) {
      return res.status(404).json({ error: 'Project not found' });
    }
    const data = JSON.parse(fs.readFileSync(projectFile, 'utf-8'));
    data.archived = req.body.archived !== undefined ? req.body.archived : true;
    data.updated = new Date().toISOString().split('T')[0];
    fs.writeFileSync(projectFile, JSON.stringify(data, null, 2), 'utf-8');
    res.json({ success: true, archived: data.archived });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// POST /api/projects/:id/type
router.post('/:id/type', (req, res) => {
  try {
    const projectFile = path.join(config.PATHS.projects, req.params.id, 'project.json');
    if (!fs.existsSync(projectFile)) {
      return res.status(404).json({ error: 'Project not found' });
    }
    const validTypes = ['production', 'test', 'iteration'];
    if (!validTypes.includes(req.body.type)) {
      return res.status(400).json({ error: `Invalid type. Must be: ${validTypes.join(', ')}` });
    }
    const data = JSON.parse(fs.readFileSync(projectFile, 'utf-8'));
    data.project_type = req.body.type;
    data.updated = new Date().toISOString().split('T')[0];
    fs.writeFileSync(projectFile, JSON.stringify(data, null, 2), 'utf-8');
    res.json({ success: true, project_type: data.project_type });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
