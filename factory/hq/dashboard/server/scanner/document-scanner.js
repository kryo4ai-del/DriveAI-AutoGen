const fs = require('fs');
const path = require('path');
const config = require('../config');

function scanProjectDocuments(projectId) {
  const projectFile = path.join(config.PATHS.projects, projectId, 'project.json');
  if (!fs.existsSync(projectFile)) return { categories: [], total: 0 };

  const project = JSON.parse(fs.readFileSync(projectFile, 'utf-8'));
  const categories = [];

  const chapterDirs = [
    { key: 'phase1', label: 'Phase 1: Pre-Production', dir: project.chapters?.phase1?.output_dir },
    { key: 'kapitel3', label: 'Kapitel 3: Market Strategy', dir: project.chapters?.kapitel3?.output_dir },
    { key: 'kapitel4', label: 'Kapitel 4: MVP & Features', dir: project.chapters?.kapitel4?.output_dir },
    { key: 'kapitel45', label: 'Kapitel 4.5: Design Vision', dir: project.chapters?.kapitel45?.output_dir },
    { key: 'kapitel5', label: 'Kapitel 5: Visual Audit', dir: project.chapters?.kapitel5?.output_dir },
    { key: 'kapitel6', label: 'Kapitel 6: Roadbook Assembly', dir: project.chapters?.kapitel6?.output_dir },
  ];

  for (const ch of chapterDirs) {
    let dir = ch.dir;
    if (!dir) continue;
    if (!path.isAbsolute(dir)) dir = path.join(config.FACTORY_BASE, dir);
    if (!fs.existsSync(dir)) continue;

    const files = fs.readdirSync(dir)
      .filter(f => f.endsWith('.md'))
      .map(f => {
        const filePath = path.join(dir, f);
        const stats = fs.statSync(filePath);
        return {
          name: f,
          display_name: formatDocName(f),
          path: filePath,
          relative_path: path.relative(config.FACTORY_BASE, filePath),
          size_kb: Math.round(stats.size / 1024),
          modified: stats.mtime.toISOString().split('T')[0],
          type: 'markdown',
          chapter: ch.key,
          chapter_label: ch.label,
        };
      });

    if (files.length > 0) {
      categories.push({ label: ch.label, key: ch.key, files });
    }
  }

  // PDFs from document_secretary
  const pdfDir = config.PATHS.documentSecretary;
  if (fs.existsSync(pdfDir)) {
    const slug = projectId.toLowerCase();
    const pdfs = fs.readdirSync(pdfDir)
      .filter(f => f.endsWith('.pdf') && f.toLowerCase().includes(slug))
      .map(f => {
        const filePath = path.join(pdfDir, f);
        const stats = fs.statSync(filePath);
        return {
          name: f,
          display_name: f.replace(/_/g, ' ').replace('.pdf', ''),
          path: filePath,
          relative_path: path.relative(config.FACTORY_BASE, filePath),
          size_kb: Math.round(stats.size / 1024),
          modified: stats.mtime.toISOString().split('T')[0],
          type: 'pdf',
          chapter: 'pdfs',
          chapter_label: 'PDF-Dokumente',
        };
      });

    if (pdfs.length > 0) {
      categories.push({ label: 'PDF-Dokumente (Document Secretary)', key: 'pdfs', files: pdfs });
    }
  }

  const total = categories.reduce((sum, cat) => sum + cat.files.length, 0);
  return { categories, total };
}

function formatDocName(filename) {
  return filename
    .replace('.md', '')
    .replace(/_/g, ' ')
    .replace(/\b\w/g, l => l.toUpperCase());
}

module.exports = { scanProjectDocuments };
