const express = require('express');
const router = express.Router();
const fs = require('fs');
const path = require('path');
const config = require('../config');
const { scanProjectDocuments } = require('../scanner/document-scanner');

// GET /api/documents/:projectId
router.get('/:projectId', (req, res) => {
  try {
    res.json(scanProjectDocuments(req.params.projectId));
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// GET /api/documents/:projectId/view/:chapter/:filename
router.get('/:projectId/view/:chapter/:filename', (req, res) => {
  try {
    const { projectId, chapter, filename } = req.params;

    const projectFile = path.join(config.PATHS.projects, projectId, 'project.json');
    if (!fs.existsSync(projectFile)) {
      return res.status(404).json({ error: 'Project not found' });
    }

    const project = JSON.parse(fs.readFileSync(projectFile, 'utf-8'));
    let filePath;

    if (chapter === 'pdfs') {
      filePath = path.join(config.PATHS.documentSecretary, filename);
    } else {
      let chapterDir = project.chapters?.[chapter]?.output_dir;
      if (!chapterDir) return res.status(404).json({ error: 'Chapter not found' });
      if (!path.isAbsolute(chapterDir)) chapterDir = path.join(config.FACTORY_BASE, chapterDir);
      filePath = path.join(chapterDir, filename);
    }

    // Security: path traversal check
    const resolvedPath = path.resolve(filePath);
    const resolvedBase = path.resolve(config.FACTORY_BASE);
    if (!resolvedPath.startsWith(resolvedBase)) {
      return res.status(403).json({ error: 'Access denied' });
    }

    if (!fs.existsSync(resolvedPath)) {
      return res.status(404).json({ error: 'File not found' });
    }

    if (filename.endsWith('.pdf')) {
      res.setHeader('Content-Type', 'application/pdf');
      res.setHeader('Content-Disposition', `inline; filename="${filename}"`);
      fs.createReadStream(resolvedPath).pipe(res);
    } else {
      const content = fs.readFileSync(resolvedPath, 'utf-8');
      res.json({
        filename,
        chapter,
        content,
        size_kb: Math.round(Buffer.byteLength(content, 'utf-8') / 1024),
      });
    }
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
