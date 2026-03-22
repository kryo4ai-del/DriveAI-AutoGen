const fs = require('fs');
const path = require('path');
const config = require('../config');
const { parsePipelineSummary } = require('./summary-parser');

const AGENT_REGISTRY = [
  { num: '1', name: 'Trend-Scout', chapter: 'Phase 1', hasWeb: true },
  { num: '2', name: 'Competitor-Scan', chapter: 'Phase 1', hasWeb: true },
  { num: '3', name: 'Zielgruppen-Analyst', chapter: 'Phase 1', hasWeb: true },
  { num: '4', name: 'Concept-Analyst', chapter: 'Phase 1', hasWeb: false },
  { num: '5', name: 'Legal-Research', chapter: 'Phase 1', hasWeb: true },
  { num: '6', name: 'Risk-Assessment', chapter: 'Phase 1', hasWeb: false },
  { num: '7', name: 'Memory-Agent', chapter: 'Uebergreifend', hasWeb: false },
  { num: '8', name: 'Plattform-Strategie', chapter: 'Kapitel 3', hasWeb: true },
  { num: '9', name: 'Monetarisierungs-Architekt', chapter: 'Kapitel 3', hasWeb: true },
  { num: '10', name: 'Marketing-Strategie', chapter: 'Kapitel 3', hasWeb: true },
  { num: '11', name: 'Release-Planer', chapter: 'Kapitel 3', hasWeb: false },
  { num: '12', name: 'Kosten-Kalkulation', chapter: 'Kapitel 3', hasWeb: false },
  { num: '13', name: 'Document Secretary', chapter: 'Querschnitt', hasWeb: false },
  { num: '14', name: 'Feature-Extraction', chapter: 'Kapitel 4', hasWeb: false },
  { num: '15', name: 'Feature-Priorisierung', chapter: 'Kapitel 4', hasWeb: false },
  { num: '16', name: 'Screen-Architect', chapter: 'Kapitel 4', hasWeb: false },
  { num: '17a', name: 'Design-Trend-Breaker', chapter: 'Kapitel 4.5', hasWeb: true },
  { num: '17b', name: 'UX-Emotion-Architect', chapter: 'Kapitel 4.5', hasWeb: true },
  { num: '17c', name: 'Design-Vision-Compiler', chapter: 'Kapitel 4.5', hasWeb: false },
  { num: '18', name: 'Asset-Discovery', chapter: 'Kapitel 5', hasWeb: false },
  { num: '19', name: 'Asset-Strategie', chapter: 'Kapitel 5', hasWeb: true },
  { num: '20', name: 'Visual-Consistency', chapter: 'Kapitel 5', hasWeb: false },
  { num: '21', name: 'Review-Assistant', chapter: 'Kapitel 5', hasWeb: false },
  { num: '22', name: 'CEO-Roadbook', chapter: 'Kapitel 6', hasWeb: false },
  { num: '23', name: 'CD-Roadbook', chapter: 'Kapitel 6', hasWeb: false },
];

const CHAPTER_KEY_MAP = {
  'Phase 1': 'phase1',
  'Kapitel 3': 'kapitel3',
  'Kapitel 4': 'kapitel4',
  'Kapitel 4.5': 'kapitel45',
  'Kapitel 5': 'kapitel5',
  'Kapitel 6': 'kapitel6',
};

function scanAgentData(projectId) {
  const projectFile = path.join(config.PATHS.projects, projectId, 'project.json');
  if (!fs.existsSync(projectFile)) return { agents: AGENT_REGISTRY.map(a => ({ ...a, status: 'Nicht gelaufen', model: '-', provider: '-', report_length: '-', cost: '-', serpapi: '-' })), totals: { agents_run: 0, agents_total: AGENT_REGISTRY.length, serpapi_credits: 0, llm_cost_usd: 0, pdf_count: 0 } };

  const project = JSON.parse(fs.readFileSync(projectFile, 'utf-8'));

  // Read pipeline summaries
  const chapterSummaries = {};
  for (const [label, key] of Object.entries(CHAPTER_KEY_MAP)) {
    const chDir = project.chapters?.[key]?.output_dir;
    if (chDir) {
      const summaryPath = path.join(chDir, 'pipeline_summary.md');
      if (fs.existsSync(summaryPath)) {
        try {
          const content = fs.readFileSync(summaryPath, 'utf-8');
          chapterSummaries[label] = parsePipelineSummary(content);
        } catch (e) { /* skip */ }
      }
    }
  }

  // Match agents with pipeline data
  const agents = AGENT_REGISTRY.map(agent => {
    const chapterData = chapterSummaries[agent.chapter];
    const chapterKey = CHAPTER_KEY_MAP[agent.chapter];
    const chapterComplete = project.chapters?.[chapterKey]?.status === 'complete';
    let agentData = null;

    if (chapterData && chapterData.agents) {
      // Fuzzy match agent name
      const searchName = agent.name.toLowerCase().replace(/-/g, '').replace(/\s/g, '');
      agentData = chapterData.agents.find(a => {
        const parsedName = a.name.toLowerCase().replace(/-/g, '').replace(/\s/g, '');
        return parsedName.includes(searchName.slice(0, 6)) || searchName.includes(parsedName.slice(0, 6));
      });
    }

    const webAgentsInChapter = AGENT_REGISTRY.filter(a => a.chapter === agent.chapter && a.hasWeb).length || 1;

    return {
      ...agent,
      status: agentData ? (agentData.status || 'OK') : (chapterComplete ? 'OK' : 'Nicht gelaufen'),
      model: agentData?.model || (chapterComplete ? 'via TheBrain' : '-'),
      provider: agentData?.provider || '-',
      report_length: agentData?.report_length || '-',
      cost: agentData?.cost || '-',
      serpapi: agent.hasWeb && chapterData?.serpApi
        ? '~' + Math.round(chapterData.serpApi / webAgentsInChapter)
        : '-',
    };
  });

  // Totals
  const totals = {
    serpapi_credits: project.costs?.serpapi_credits_total || 0,
    llm_cost_usd: project.costs?.llm_cost_usd_total || 0,
    pdf_count: 0,
    agents_run: agents.filter(a => a.status === 'OK' || a.status === 'ok' || a.status === 'OK ').length,
    agents_total: agents.length,
  };

  // Count PDFs
  const pdfDir = config.PATHS.documentSecretary;
  if (fs.existsSync(pdfDir)) {
    const slug = projectId.toLowerCase();
    totals.pdf_count = fs.readdirSync(pdfDir).filter(f => f.endsWith('.pdf') && f.toLowerCase().includes(slug)).length;
  }

  return { agents, totals };
}

module.exports = { scanAgentData, AGENT_REGISTRY };
