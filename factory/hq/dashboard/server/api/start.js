const express = require('express');
const router = express.Router();
const fs = require('fs');
const path = require('path');
const { exec } = require('child_process');
const config = require('../config');

// GET /api/start/ideas — list all saved ideas
router.get('/ideas', (req, res) => {
  try {
    const ideasDir = config.PATHS.ideas;
    if (!fs.existsSync(ideasDir)) {
      fs.mkdirSync(ideasDir, { recursive: true });
      return res.json({ ideas: [], count: 0 });
    }

    const ideas = fs.readdirSync(ideasDir)
      .filter(f => f.endsWith('.md'))
      .map(f => {
        const filePath = path.join(ideasDir, f);
        const content = fs.readFileSync(filePath, 'utf-8');
        const stats = fs.statSync(filePath);
        const lines = content.split('\n').filter(l => l.trim());

        const titleMatch = content.match(/^#\s+(.+)/m);
        const title = titleMatch ? titleMatch[1] : f.replace('.md', '').replace(/[-_]/g, ' ');
        const preview = lines.find(l => !l.startsWith('#') && l.trim().length > 0) || '';

        const slug = f.replace('.md', '').toLowerCase().replace(/\s+/g, '_');
        const projectFile = path.join(config.PATHS.projects, slug, 'project.json');
        const isRunning = fs.existsSync(projectFile);
        let projectStatus = null;
        if (isRunning) {
          try {
            const project = JSON.parse(fs.readFileSync(projectFile, 'utf-8'));
            projectStatus = project.current_phase || project.status;
          } catch (e) { /* ignore */ }
        }

        return {
          filename: f,
          title,
          preview: preview.substring(0, 150),
          size_kb: Math.round(stats.size / 1024),
          created: stats.birthtime.toISOString().split('T')[0],
          modified: stats.mtime.toISOString().split('T')[0],
          is_running: isRunning,
          project_status: projectStatus,
          slug,
        };
      })
      .sort((a, b) => b.modified.localeCompare(a.modified));

    res.json({ ideas, count: ideas.length });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// POST /api/start/save-idea
router.post('/save-idea', (req, res) => {
  try {
    const { title, content } = req.body;
    if (!title || !content) {
      return res.status(400).json({ error: 'title and content required' });
    }

    const ideasDir = config.PATHS.ideas;
    if (!fs.existsSync(ideasDir)) fs.mkdirSync(ideasDir, { recursive: true });

    const slug = title.toLowerCase().replace(/[^a-z0-9]+/g, '_').replace(/^_|_$/g, '');
    const filename = `${slug}.md`;
    const filePath = path.join(ideasDir, filename);

    if (fs.existsSync(filePath)) {
      return res.status(409).json({ error: 'Idee mit diesem Namen existiert bereits', filename });
    }

    fs.writeFileSync(filePath, `# ${title}\n\n${content}`, 'utf-8');
    res.json({ filename, slug, path: filePath, message: `Idee gespeichert: ${filename}` });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// POST /api/start/launch — launch the factory pipeline
router.post('/launch', (req, res) => {
  try {
    const { title, ambition, idea_source } = req.body;
    if (!title || !ambition) {
      return res.status(400).json({ error: 'title and ambition required' });
    }

    let command;

    if (idea_source === 'file' && req.body.idea_file) {
      const ideaPath = path.join(config.PATHS.ideas, req.body.idea_file);
      if (!fs.existsSync(ideaPath)) {
        return res.status(404).json({ error: 'Idee-Datei nicht gefunden' });
      }
      command = `python main.py --factory-submit --idea-file "${ideaPath}" --title "${title}" --ambition ${ambition}`;
    } else if (req.body.idea_text) {
      const slug = title.toLowerCase().replace(/[^a-z0-9]+/g, '_').replace(/^_|_$/g, '');
      const filename = `${slug}.md`;
      const ideasDir = config.PATHS.ideas;
      if (!fs.existsSync(ideasDir)) fs.mkdirSync(ideasDir, { recursive: true });

      const filePath = path.join(ideasDir, filename);
      if (!fs.existsSync(filePath)) {
        fs.writeFileSync(filePath, `# ${title}\n\n${req.body.idea_text}`, 'utf-8');
      }
      command = `python main.py --factory-submit --idea-file "${filePath}" --title "${title}" --ambition ${ambition}`;
    } else {
      return res.status(400).json({ error: 'Either idea_text or idea_file required' });
    }

    console.log(`[Start] Launching: ${command}`);
    exec(command, { cwd: config.FACTORY_BASE }, (error, stdout, stderr) => {
      if (error) {
        console.error(`[Start] Pipeline error: ${error.message}`);
      } else {
        console.log(`[Start] Pipeline started successfully`);
      }
    });

    res.json({
      title,
      ambition,
      command,
      status: 'launched',
      message: `Factory gestartet: ${title} (${ambition})`,
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// DELETE /api/start/ideas/:filename
router.delete('/ideas/:filename', (req, res) => {
  try {
    const filePath = path.join(config.PATHS.ideas, req.params.filename);
    const resolved = path.resolve(filePath);
    if (!resolved.startsWith(path.resolve(config.PATHS.ideas))) {
      return res.status(403).json({ error: 'Access denied' });
    }
    if (!fs.existsSync(filePath)) {
      return res.status(404).json({ error: 'Datei nicht gefunden' });
    }
    fs.unlinkSync(filePath);
    res.json({ deleted: req.params.filename });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
