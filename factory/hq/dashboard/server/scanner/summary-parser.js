/**
 * Parses pipeline_summary.md and gate decision files.
 * Handles both old (3-column) and new enriched (7-column) formats.
 */

function parsePipelineSummary(content) {
  const agents = [];
  const lines = content.split('\n');

  let inTable = false;
  let headerParsed = false;
  let isEnriched = false;

  for (const line of lines) {
    if (line.includes('|') && line.includes('Agent') && line.includes('Status')) {
      inTable = true;
      isEnriched = line.includes('Modell') || line.includes('Provider');
      continue;
    }

    if (inTable && line.match(/^\|[\s-|]+$/)) {
      headerParsed = true;
      continue;
    }

    if (inTable && headerParsed && line.startsWith('|')) {
      const cells = line.split('|').map(c => c.trim()).filter(c => c);

      if (cells.length >= 2) {
        if (isEnriched && cells.length >= 5) {
          agents.push({
            name: cells[0],
            status: cells[1],
            model: cells[2] || 'unknown',
            provider: cells[3] || 'unknown',
            report_length: cells[4] || '',
            llm_calls: cells[5] || '',
            cost: cells[6] || '',
          });
        } else {
          agents.push({
            name: cells[0],
            status: cells[1],
            model: 'unknown',
            provider: 'unknown',
            report_length: cells[2] || '',
            llm_calls: '',
            cost: '',
          });
        }
      }
    }

    if (inTable && headerParsed && !line.startsWith('|') && line.trim() !== '') {
      inTable = false;
    }
  }

  const serpApiMatch = content.match(/API-Calls:\s*(\d+)/);
  const serpApi = serpApiMatch ? parseInt(serpApiMatch[1]) : 0;

  const dateMatch = content.match(/Datum:\s*(\d{4}-\d{2}-\d{2})/);
  const date = dateMatch ? dateMatch[1] : null;

  const statusMatch = content.match(/Status:\s*(\w+)/);
  const status = statusMatch ? statusMatch[1] : 'unknown';

  const kapitelMatch = content.match(/Kapitel:\s*(.+)/);
  const kapitel = kapitelMatch ? kapitelMatch[1].trim() : null;

  return { agents, serpApi, date, status, kapitel };
}

function parseGateDecision(content) {
  let decision = 'unknown';
  const decisionLine = content.split('\n').find(l => l.trim().startsWith('**Entscheidung:**'));
  if (decisionLine) {
    const val = decisionLine.split(':**')[1]?.trim() || '';
    if (val.includes('GO_MIT_NOTES') || val.includes('GO MIT NOTES')) decision = 'GO_MIT_NOTES';
    else if (val.includes('REDO')) decision = 'REDO';
    else if (val.includes('KILL')) decision = 'KILL';
    else if (val.includes('GO')) decision = 'GO';
  }

  const dateMatch = content.match(/Datum:\s*(\d{4}-\d{2}-\d{2})/);
  const notesMatch = content.match(/(?:Anmerkungen?|Begründung|Reasoning):\s*(.+)/i);

  return {
    decision,
    date: dateMatch ? dateMatch[1] : null,
    notes: notesMatch ? notesMatch[1].trim() : '',
  };
}

module.exports = { parsePipelineSummary, parseGateDecision };
