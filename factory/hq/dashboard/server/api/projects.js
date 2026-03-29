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

// DELETE /api/projects/:id — full cleanup: project folder + all pipeline outputs + reports + run_logs + code
router.delete('/:id', (req, res) => {
  try {
    const projectId = req.params.id;
    const projectDir = path.join(config.PATHS.projects, projectId);
    if (!fs.existsSync(projectDir)) {
      return res.status(404).json({ error: 'Project not found' });
    }

    const deleted = [];
    const rmDir = (dir) => {
      if (dir && fs.existsSync(dir)) {
        fs.rmSync(dir, { recursive: true, force: true });
        deleted.push(dir);
      }
    };
    const rmFile = (fp) => {
      if (fp && fs.existsSync(fp)) {
        fs.unlinkSync(fp);
        deleted.push(fp);
      }
    };

    // 1. Project folder (factory/projects/<id>/) — read title before deleting
    let projectTitle = projectId;
    try {
      const pData = JSON.parse(fs.readFileSync(path.join(projectDir, 'project.json'), 'utf-8'));
      if (pData.title) projectTitle = pData.title;
    } catch (e) { /* use projectId as fallback */ }
    rmDir(projectDir);

    // 2. Pipeline output directories (scan for <NNN>_<projectId> pattern)
    const outputDirs = [
      config.PATHS.preProduction,
      config.PATHS.marketStrategy,
      config.PATHS.mvpScope,
      config.PATHS.designVision,
      config.PATHS.visualAudit,
      config.PATHS.roadbookAssembly,
      config.PATHS.documentSecretary,
    ];
    for (const outDir of outputDirs) {
      if (!fs.existsSync(outDir)) continue;
      for (const entry of fs.readdirSync(outDir)) {
        const entryPath = path.join(outDir, entry);
        const stat = fs.statSync(entryPath);
        if (stat.isDirectory()) {
          // Match folder patterns: NNN_projectId or just projectId
          if (entry.endsWith('_' + projectId) || entry === projectId) {
            rmDir(entryPath);
          }
        } else if (outDir === config.PATHS.documentSecretary) {
          // PDFs/ZIPs are named with project title: CEO_Briefing_Phase1_Echomatch_2026-03-20.pdf
          const titleMatch = projectTitle.charAt(0).toUpperCase() + projectTitle.slice(1);
          const lowerEntry = entry.toLowerCase();
          if (lowerEntry.includes(projectId) || entry.includes(titleMatch) || entry.startsWith(titleMatch) || entry.startsWith(projectId)) {
            rmFile(entryPath);
          }
        }
      }
    }

    // 3. Generated code (projects/<id>/ + platform variants like <id>_android, <id>_web)
    const codeBase = path.join(config.FACTORY_BASE, 'projects');
    if (fs.existsSync(codeBase)) {
      for (const entry of fs.readdirSync(codeBase)) {
        if (entry === projectId || entry.startsWith(projectId + '_')) {
          rmDir(path.join(codeBase, entry));
        }
      }
    }

    // 4. Reports (factory/reports/*/<projectId>*.json)
    const reportsBase = path.join(config.FACTORY_BASE, 'factory', 'reports');
    if (fs.existsSync(reportsBase)) {
      for (const subDir of fs.readdirSync(reportsBase)) {
        const fullSub = path.join(reportsBase, subDir);
        if (!fs.statSync(fullSub).isDirectory()) continue;
        for (const file of fs.readdirSync(fullSub)) {
          if (file.startsWith(projectId + '_') || file.startsWith(projectId + '.')) {
            rmFile(path.join(fullSub, file));
          }
        }
      }
    }

    // 5. Run logs (run_logs/<projectId>*.txt)
    const logsDir = path.join(config.FACTORY_BASE, 'run_logs');
    if (fs.existsSync(logsDir)) {
      for (const file of fs.readdirSync(logsDir)) {
        if (file.startsWith(projectId + '_') || file.startsWith(projectId + '.')) {
          rmFile(path.join(logsDir, file));
        }
      }
    }

    // 6. Gate files (factory/hq/gates/pending/ and resolved/)
    const gatesBase = path.join(config.FACTORY_BASE, 'factory', 'hq', 'gates');
    for (const sub of ['pending', 'resolved']) {
      const gDir = path.join(gatesBase, sub);
      if (!fs.existsSync(gDir)) continue;
      for (const file of fs.readdirSync(gDir)) {
        if (file.includes('_' + projectId + '_') || file.includes('_' + projectId + '.')) {
          rmFile(path.join(gDir, file));
        }
      }
    }

    // 7. Command logs (_commands/*<projectId>*.md)
    const cmdDir = path.join(config.FACTORY_BASE, '_commands');
    if (fs.existsSync(cmdDir)) {
      for (const file of fs.readdirSync(cmdDir)) {
        if (file.includes(projectId)) {
          rmFile(path.join(cmdDir, file));
        }
      }
    }

    // 8. Pre-production memory (factory/pre_production/memory/runs/*<projectId>*)
    const memDir = path.join(config.FACTORY_BASE, 'factory', 'pre_production', 'memory', 'runs');
    if (fs.existsSync(memDir)) {
      for (const file of fs.readdirSync(memDir)) {
        if (file.includes(projectId)) {
          rmFile(path.join(memDir, file));
        }
      }
    }

    // 9. Store Prep output (factory/store_prep/output/<projectId>/)
    rmDir(path.join(config.PATHS.storePrep, projectId));

    // 10. Asset Forge output (factory/asset_forge/output/<projectId>/ + manifests)
    if (fs.existsSync(config.PATHS.assetForge)) {
      for (const entry of fs.readdirSync(config.PATHS.assetForge)) {
        const entryPath = path.join(config.PATHS.assetForge, entry);
        if (entry === projectId || entry.startsWith(projectId + '_')) {
          const stat = fs.statSync(entryPath);
          if (stat.isDirectory()) rmDir(entryPath);
          else rmFile(entryPath);
        }
        // Also match <projectId>_manifest.json and <projectId>_proof/
        if (entry === projectId + '_manifest.json' || entry === projectId + '_proof') {
          const stat = fs.statSync(entryPath);
          if (stat.isDirectory()) rmDir(entryPath);
          else rmFile(entryPath);
        }
      }
    }

    // 11. Forge catalogs + specs (sound_forge, scene_forge, motion_forge)
    for (const forgeBase of [config.PATHS.soundForge, config.PATHS.sceneForge, config.PATHS.motionForge]) {
      if (!fs.existsSync(forgeBase)) continue;
      // specs/<projectId>_*.json
      const specsDir = path.join(forgeBase, 'specs');
      if (fs.existsSync(specsDir)) {
        for (const file of fs.readdirSync(specsDir)) {
          if (file.startsWith(projectId + '_')) rmFile(path.join(specsDir, file));
        }
      }
      // catalog/<projectId>/
      const catalogDir = path.join(forgeBase, 'catalog', projectId);
      rmDir(catalogDir);
      // generated/<projectId>* files
      const genDir = path.join(forgeBase, 'generated');
      if (fs.existsSync(genDir)) {
        for (const file of fs.readdirSync(genDir)) {
          if (file.startsWith(projectId + '_') || file.startsWith(projectId + '.')) {
            rmFile(path.join(genDir, file));
          }
        }
      }
    }

    // 12. Integration maps + build plans (factory/integration/)
    const intBase = config.PATHS.integration;
    for (const sub of ['maps', 'build_plans']) {
      const intDir = path.join(intBase, sub);
      if (!fs.existsSync(intDir)) continue;
      for (const file of fs.readdirSync(intDir)) {
        if (file.startsWith(projectId + '_') || file.startsWith(projectId + '.')) {
          const fp = path.join(intDir, file);
          const stat = fs.statSync(fp);
          if (stat.isDirectory()) rmDir(fp);
          else rmFile(fp);
        }
      }
    }

    // 13. QA Forge reports (factory/qa_forge/reports/<projectId>_*)
    if (fs.existsSync(config.PATHS.qaForge)) {
      for (const file of fs.readdirSync(config.PATHS.qaForge)) {
        if (file.startsWith(projectId + '_') || file.startsWith(projectId + '.')) {
          rmFile(path.join(config.PATHS.qaForge, file));
        }
      }
    }

    // 14. Marketing (brand directives, app stories, output)
    const mktBase = config.PATHS.marketing;
    rmFile(path.join(mktBase, 'brand', 'directives', projectId + '_directive.md'));
    rmDir(path.join(mktBase, 'brand', 'app_stories', projectId));
    rmDir(path.join(mktBase, 'output', projectId));
    // brand_book/app_styles/<projectId>_style.json
    rmFile(path.join(mktBase, 'brand', 'brand_book', 'app_styles', projectId + '_style.json'));

    // 15. Capabilities reports (factory/hq/capabilities/reports/*<projectId>*)
    if (fs.existsSync(config.PATHS.capabilities)) {
      for (const file of fs.readdirSync(config.PATHS.capabilities)) {
        if (file.includes(projectId)) {
          rmFile(path.join(config.PATHS.capabilities, file));
        }
      }
    }

    // 16. Ideas file (ideas/<projectId>.md — case-insensitive match)
    const ideasDir = config.PATHS.ideas;
    if (fs.existsSync(ideasDir)) {
      for (const file of fs.readdirSync(ideasDir)) {
        if (file.toLowerCase().replace(/[^a-z0-9]/g, '').includes(projectId.toLowerCase().replace(/[^a-z0-9]/g, ''))) {
          rmFile(path.join(ideasDir, file));
        }
      }
    }

    // 17. Dispatcher queue — remove entries from queue_store.json
    const queueFile = path.join(config.PATHS.dispatcher, 'queue_store.json');
    if (fs.existsSync(queueFile)) {
      try {
        const queue = JSON.parse(fs.readFileSync(queueFile, 'utf-8'));
        const before = queue.products?.length || 0;
        queue.products = (queue.products || []).filter(p =>
          !p.id?.includes(projectId) && !p.title?.toLowerCase().includes(projectId)
        );
        if (queue.products.length < before) {
          queue.updated = new Date().toISOString();
          fs.writeFileSync(queueFile, JSON.stringify(queue, null, 2), 'utf-8');
          deleted.push(`queue_store.json (${before - queue.products.length} entries removed)`);
        }
      } catch (e) { /* ignore parse errors */ }
    }

    res.json({ success: true, project_id: projectId, deleted_count: deleted.length, deleted });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
