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

    const mode = ambition === 'realistic' ? 'factory' : 'vision';
    const slug = title.toLowerCase().replace(/[^a-z0-9]+/g, '_').replace(/^_|_$/g, '');
    let ideaFilePath;

    // Step 1: Ensure idea file exists
    if (idea_source === 'file' && req.body.idea_file) {
      ideaFilePath = path.join(config.PATHS.ideas, req.body.idea_file);
      if (!fs.existsSync(ideaFilePath)) {
        return res.status(404).json({ error: 'Idee-Datei nicht gefunden' });
      }
    } else if (req.body.idea_text) {
      const ideasDir = config.PATHS.ideas;
      if (!fs.existsSync(ideasDir)) fs.mkdirSync(ideasDir, { recursive: true });
      ideaFilePath = path.join(ideasDir, `${slug}.md`);
      if (!fs.existsSync(ideaFilePath)) {
        fs.writeFileSync(ideaFilePath, `# ${title}\n\n${req.body.idea_text}`, 'utf-8');
      }
    } else {
      return res.status(400).json({ error: 'Either idea_text or idea_file required' });
    }

    // Step 2: Register project in project_registry (creates project.json + folder)
    const registerCmd = `python -c "from factory.project_registry import register_project; register_project('${slug}', '${title.replace(/'/g, "\\'")}', open('${ideaFilePath.replace(/\\/g, '/')}', encoding='utf-8').read(), '${mode}')"`;
    exec(registerCmd, { cwd: config.FACTORY_BASE }, (err) => {
      if (err) console.error(`[Start] Registry error: ${err.message}`);
      else console.log(`[Start] Project registered: ${slug}`);
    });

    // Step 3: Launch the actual pipeline
    const command = `python -m factory.pre_production.pipeline --idea-file "${ideaFilePath}" --title "${title}" --mode ${mode}`;
    console.log(`[Start] Launching: ${command}`);
    exec(command, { cwd: config.FACTORY_BASE }, (error, stdout, stderr) => {
      if (error) {
        console.error(`[Start] Pipeline error: ${error.message}`);
      } else {
        console.log(`[Start] Pipeline completed successfully`);
      }
    });

    res.json({
      title,
      slug,
      mode,
      command,
      status: 'launched',
      message: `Factory gestartet: ${title} (${mode} mode)`,
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
