const fs = require('fs');
const path = require('path');
const { exec } = require('child_process');
const config = require('../config');

function executeGateDecision(projectId, gateType, decision, reasoning, autoTrigger = false) {
  const projectFile = path.join(config.PATHS.projects, projectId, 'project.json');
  if (!fs.existsSync(projectFile)) {
    throw new Error(`Project not found: ${projectId}`);
  }

  const project = JSON.parse(fs.readFileSync(projectFile, 'utf-8'));

  let decisionDir, decisionFilename, nextCommand;

  if (gateType === 'ceo_gate') {
    let dir = project.chapters?.phase1?.output_dir || '';
    if (dir && !path.isAbsolute(dir)) dir = path.join(config.FACTORY_BASE, dir);
    decisionDir = dir;
    decisionFilename = 'ceo_gate_decision.md';

    if (decision === 'GO' || decision === 'GO_MIT_NOTES') {
      nextCommand = `python -m factory.market_strategy.pipeline --run-dir "${decisionDir}"`;
    }
  } else if (gateType === 'visual_review') {
    let dir = project.chapters?.kapitel5?.output_dir || '';
    if (dir && !path.isAbsolute(dir)) dir = path.join(config.FACTORY_BASE, dir);
    decisionDir = dir;
    decisionFilename = 'review_decision.md';

    if (decision === 'GO' || decision === 'GO_MIT_NOTES') {
      nextCommand = `python -m factory.roadbook_assembly.pipeline --latest`;
    }
  }

  if (!decisionDir || !fs.existsSync(decisionDir)) {
    throw new Error(`Output directory not found: ${decisionDir}`);
  }

  const now = new Date().toISOString().split('T')[0];
  const content = generateDecisionMarkdown(gateType, decision, reasoning, projectId, now);
  const decisionPath = path.join(decisionDir, decisionFilename);
  fs.writeFileSync(decisionPath, content, 'utf-8');

  project.gates[gateType] = {
    status: decision,
    date: now,
    notes: reasoning || null,
  };
  project.updated = now;
  project.status = deriveStatus(project);
  project.current_phase = deriveCurrentPhase(project);

  fs.writeFileSync(projectFile, JSON.stringify(project, null, 2), 'utf-8');

  let triggerResult = null;
  if (autoTrigger && nextCommand && (decision === 'GO' || decision === 'GO_MIT_NOTES')) {
    triggerResult = { command: nextCommand, status: 'triggered' };
    exec(nextCommand, { cwd: config.FACTORY_BASE }, (error) => {
      if (error) {
        console.error(`[GateExecutor] Pipeline trigger failed: ${error.message}`);
      } else {
        console.log(`[GateExecutor] Pipeline triggered successfully`);
      }
    });
  }

  return {
    project_id: projectId,
    gate_type: gateType,
    decision,
    reasoning,
    file_written: decisionPath,
    project_status: project.status,
    next_pipeline: triggerResult,
  };
}

function generateDecisionMarkdown(gateType, decision, reasoning, projectId, date) {
  const gateLabel = gateType === 'ceo_gate' ? 'CEO-Gate: Kill or Go' : 'Human Review Gate';
  const nextStep = decision === 'GO' || decision === 'GO_MIT_NOTES'
    ? 'Weiter zur naechsten Pipeline-Phase.'
    : decision === 'KILL'
      ? 'Projekt beendet.'
      : 'Aenderungen erforderlich, danach erneute Pruefung.';

  return `# ${gateLabel}

**Projekt:** ${projectId}
**Datum:** ${date}
**Entscheidung:** ${decision}
**Quelle:** Dashboard CEO Cockpit

## Begruendung
${reasoning || 'Keine Anmerkungen.'}

## Naechster Schritt
${nextStep}
`;
}

function deriveStatus(project) {
  const ch = project.chapters || {};
  const gates = project.gates || {};
  const prod = project.production || {};

  if (ch.kapitel6?.status === 'complete') {
    if (Object.values(prod).some(p => p.status && p.status !== 'not_started')) return 'in_production';
    return 'preproduction_done';
  }
  if (ch.kapitel5?.status === 'complete') {
    if (gates.visual_review?.status === 'GO' || gates.visual_review?.status === 'GO_MIT_NOTES') return 'review_go';
    return 'review_pending';
  }
  if (ch.kapitel45?.status === 'complete') return 'design_complete';
  if (ch.kapitel4?.status === 'complete') return 'features_complete';
  if (ch.kapitel3?.status === 'complete') return 'strategy_complete';
  if (gates.ceo_gate?.status === 'GO' || gates.ceo_gate?.status === 'GO_MIT_NOTES') return 'ceo_gate_go';
  if (gates.ceo_gate?.status === 'KILL') return 'killed';
  if (ch.phase1?.status === 'complete') return 'ceo_gate_pending';
  return 'idea';
}

function deriveCurrentPhase(project) {
  const mapping = {
    'idea': 'Idee wartet',
    'phase1_running': 'Pre-Production: Phase 1 laeuft',
    'ceo_gate_pending': 'Pre-Production: CEO-Gate wartet',
    'ceo_gate_go': 'Pre-Production: Bereit fuer Kapitel 3',
    'killed': 'Projekt beendet (KILL)',
    'strategy_complete': 'Pre-Production: Kapitel 3 fertig',
    'features_complete': 'Pre-Production: Kapitel 4 fertig',
    'design_complete': 'Pre-Production: Kapitel 4.5 fertig',
    'review_pending': 'Pre-Production: Human Review wartet',
    'review_go': 'Pre-Production: Review bestanden',
    'preproduction_done': 'Pre-Production abgeschlossen — bereit fuer Production',
    'in_production': 'Production laeuft',
  };
  return mapping[project.status] || project.status;
}

module.exports = { executeGateDecision };
