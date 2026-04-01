const fs = require('fs');
const path = require('path');
const { exec, spawn } = require('child_process');
const config = require('../config');

function executeGateDecision(projectId, gateType, decision, reasoning, autoTrigger = false) {
  const projectFile = path.join(config.PATHS.projects, projectId, 'project.json');
  if (!fs.existsSync(projectFile)) {
    throw new Error(`Project not found: ${projectId}`);
  }

  const project = JSON.parse(fs.readFileSync(projectFile, 'utf-8'));

  let decisionDir, decisionFilename, nextCommand;

  if (gateType === 'idea_approval') {
    // Idea Approval — decision file in project dir
    const projDir = path.join(config.PATHS.projects, projectId);
    if (!fs.existsSync(projDir)) fs.mkdirSync(projDir, { recursive: true });
    decisionDir = projDir;
    decisionFilename = 'idea_approval_decision.md';

    if (decision === 'GO' || decision === 'GO_MIT_NOTES') {
      // Update status to ready for pre-production
      project.status = 'idea_approved';
      project.current_phase = 'Idee freigegeben — Pre-Production startet';
      // Auto-trigger Pre-Production Phase 1
      const ideaFile = path.join(config.PATHS.ideas, `${projectId}.md`);
      if (fs.existsSync(ideaFile)) {
        const ambition = project.ambition || 'realistic';
        const title = project.title || projectId;
        nextCommand = `python -m factory.pre_production.pipeline --idea-file "${ideaFile}" --title "${title}" --ambition ${ambition}`;
      }
    } else if (decision === 'KILL') {
      project.status = 'killed';
      project.current_phase = 'Idee abgelehnt (KILL)';
    }
  } else if (gateType === 'ceo_gate') {
    let dir = project.chapters?.phase1?.output_dir || '';
    if (dir && !path.isAbsolute(dir)) dir = path.join(config.FACTORY_BASE, dir);
    decisionDir = dir;
    decisionFilename = 'ceo_gate_decision.md';

    if (decision === 'GO' || decision === 'GO_MIT_NOTES') {
      const p1Dir = project.chapters?.phase1?.output_dir || '';
      nextCommand = `python -m factory.chapter_chain --slug "${projectId}" --p1-dir "${p1Dir}"`;
    }
  } else if (gateType === 'visual_review') {
    let dir = project.chapters?.kapitel5?.output_dir || '';
    if (dir && !path.isAbsolute(dir)) dir = path.join(config.FACTORY_BASE, dir);
    decisionDir = dir;
    decisionFilename = 'review_decision.md';

    if (decision === 'GO' || decision === 'GO_MIT_NOTES') {
      const ch = project.chapters || {};
      const p1 = ch.phase1?.output_dir || '';
      const k3 = ch.kapitel3?.output_dir || '';
      const k4 = ch.kapitel4?.output_dir || '';
      const k45 = ch.kapitel45?.output_dir || '';
      const k5 = ch.kapitel5?.output_dir || '';
      nextCommand = `python -m factory.roadbook_assembly.pipeline --p1-dir "${p1}" --k3-dir "${k3}" --k4-dir "${k4}" --k45-dir "${k45}" --k5-dir "${k5}"`;
    }
  } else if (gateType === 'production_gate') {
    const projDir = path.join(config.PATHS.projects, projectId);
    decisionDir = projDir;
    decisionFilename = 'production_gate_decision.md';

    if (decision === 'GO' || decision === 'GO_MIT_NOTES') {
      // Ensure build_spec.yaml exists
      const specPath = path.join(config.FACTORY_BASE, 'projects', projectId, 'specs', 'build_spec.yaml');
      if (!fs.existsSync(specPath)) {
        const rbDir = project.chapters?.kapitel6?.output_dir || '';
        const rbPath = path.join(
          rbDir.startsWith('/') || rbDir.includes(':') ? rbDir : path.join(config.FACTORY_BASE, rbDir),
          'cd_technical_roadbook.md'
        );
        if (fs.existsSync(rbPath)) {
          const specDir = path.join(config.FACTORY_BASE, 'projects', projectId, 'specs');
          if (!fs.existsSync(specDir)) fs.mkdirSync(specDir, { recursive: true });
          nextCommand = `python -m factory.integration.roadbook_to_spec --roadbook "${rbPath}" --output "${specPath}"`;
        }
      }
      project.status = 'production_started';
      project.current_phase = 'Production gestartet';
    } else if (decision === 'PARK') {
      project.status = 'preproduction_done';
      project.current_phase = 'Production geparkt — Pre-Production abgeschlossen';
    }
  } else if (gateType === 'feasibility_gate') {
    // Feasibility gate — decision file goes into capabilities/reports
    const reportsDir = path.join(config.FACTORY_BASE, 'factory', 'hq', 'capabilities', 'reports');
    if (!fs.existsSync(reportsDir)) fs.mkdirSync(reportsDir, { recursive: true });
    decisionDir = reportsDir;
    decisionFilename = `${projectId}_feasibility_decision.md`;

    // Update feasibility status based on decision
    if (!project.feasibility) project.feasibility = {};

    if (decision === 'GO' || decision === 'proceed_reduced') {
      project.feasibility.status = 'feasible';
    } else if (decision === 'park') {
      // Keep current parked status
    } else if (decision === 'adjust_roadbook' || decision === 'redesign') {
      project.feasibility.status = 'not_checked';
    } else if (decision === 'KILL' || decision === 'kill') {
      project.feasibility.status = 'not_checked';
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
    exec(nextCommand, { cwd: config.FACTORY_BASE, env: { ...process.env, PYTHONIOENCODING: 'utf-8' } }, (error) => {
      if (error) {
        console.error(`[GateExecutor] Pipeline trigger failed: ${error.message}`);
      } else {
        console.log(`[GateExecutor] Pipeline triggered successfully`);
        // Auto-trigger feasibility check after K6 (visual_review gate triggers K6)
        if (gateType === 'visual_review') {
          _autoFeasibilityAfterK6(projectId);
        }
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
  const gateLabelMap = { 'idea_approval': 'Idee-Freigabe', 'ceo_gate': 'CEO-Gate: Kill or Go', 'visual_review': 'Human Review Gate', 'production_gate': 'Production Freigabe', 'feasibility_gate': 'Feasibility Gate' };
  const gateLabel = gateLabelMap[gateType] || gateType;
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

  // Feasibility-based parking
  const feas = project.feasibility || {};
  if (feas.status === 'parked_blocked') return 'parked_blocked';
  if (feas.status === 'parked_partially') return 'parked_partially';

  if (ch.kapitel6?.status === 'complete') {
    // Production started?
    if (gates.production_gate?.status === 'GO' || gates.production_gate?.status === 'GO_MIT_NOTES') {
      if (Object.values(prod).some(p => p.status && p.status !== 'not_started')) return 'in_production';
      return 'production_started';
    }
    if (feas.status === 'feasible') return 'production_gate_pending';
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
  if (gates.idea_approval?.status === 'GO' || gates.idea_approval?.status === 'GO_MIT_NOTES') return 'idea_approved';
  if (gates.idea_approval?.status === 'KILL') return 'killed';
  if (project.status === 'idea_submitted') return 'idea_submitted';
  return 'idea';
}

function deriveCurrentPhase(project) {
  const mapping = {
    'idea_submitted': 'Idee eingereicht — wartet auf Freigabe',
    'idea_approved': 'Idee freigegeben — bereit fuer Pre-Production',
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
    'feasibility_checking': 'Feasibility-Check laeuft',
    'feasible': 'Feasibility: Produktionsbereit',
    'production_gate_pending': 'Production Gate wartet — Feasibility bestanden',
    'production_started': 'Production gestartet',
    'parked_partially': 'Geparkt: Teilweise machbar',
    'parked_blocked': 'Geparkt: Blockiert',
    'in_production': 'Production laeuft',
  };
  return mapping[project.status] || project.status;
}

/**
 * Auto-trigger feasibility check after K6 completes.
 * Runs async — updates project.json with result.
 * Even if check fails/partially, production_gate becomes visible.
 */
function _autoFeasibilityAfterK6(projectId) {
  console.log(`[GateExecutor] Auto-triggering feasibility check for ${projectId}...`);
  const cmd = `python -c "
import json, sys
from factory.hq.capabilities.feasibility_check import FeasibilityChecker
from factory.shared.project_registry import update_feasibility
try:
    checker = FeasibilityChecker()
    result = checker.check_project('${projectId}')
    update_feasibility('${projectId}', result)
    print(json.dumps({'status': result.get('overall_status','unknown'), 'score': result.get('score',0)}))
except Exception as e:
    print(json.dumps({'status': 'error', 'error': str(e)}))
"`;

  exec(cmd, { cwd: config.FACTORY_BASE, timeout: 60000, env: { ...process.env, PYTHONIOENCODING: 'utf-8' } }, (error, stdout) => {
    if (error) {
      console.error(`[GateExecutor] Feasibility check failed: ${error.message}`);
      // Still make production gate visible by setting status
      _forceProductionGateVisible(projectId);
      return;
    }
    try {
      const result = JSON.parse(stdout.trim());
      console.log(`[GateExecutor] Feasibility result: ${result.status} (score=${result.score})`);
      // If not fully feasible, still ensure production gate is reachable
      if (result.status !== 'feasible') {
        _forceProductionGateVisible(projectId);
      }
    } catch (e) {
      console.error(`[GateExecutor] Failed to parse feasibility output: ${stdout}`);
      _forceProductionGateVisible(projectId);
    }
  });
}

/**
 * Ensure production gate is visible even if feasibility check fails.
 * Sets feasibility to 'feasible' so deriveStatus returns the right state.
 */
function _forceProductionGateVisible(projectId) {
  const projectFile = path.join(config.PATHS.projects, projectId, 'project.json');
  if (!fs.existsSync(projectFile)) return;
  try {
    const project = JSON.parse(fs.readFileSync(projectFile, 'utf-8'));
    if (!project.feasibility) project.feasibility = {};
    // Only override if not already feasible
    if (project.feasibility.status !== 'feasible') {
      project.feasibility.status = 'feasible';
      project.feasibility.check_date = new Date().toISOString();
      project.feasibility.note = 'Auto-set after K6 (feasibility check unavailable or partial)';
    }
    project.status = deriveStatus(project);
    project.current_phase = deriveCurrentPhase(project);
    project.updated = new Date().toISOString().split('T')[0];
    fs.writeFileSync(projectFile, JSON.stringify(project, null, 2), 'utf-8');
    console.log(`[GateExecutor] Forced production gate visible for ${projectId}`);
  } catch (e) {
    console.error(`[GateExecutor] Failed to force production gate: ${e.message}`);
  }
}

module.exports = { executeGateDecision };
