import { useState, useEffect, useRef, useCallback } from 'react';
import { ArrowLeft, Wifi, WifiOff, CheckCircle, XCircle, Pause, RotateCcw } from 'lucide-react';
import CostTracker from './CostTracker';
import ScreenGrid from './ScreenGrid';
import AgentFeed from './AgentFeed';

export default function ProductionDashboard({ slug, onBack }) {
  const [status, setStatus] = useState(null);
  const [estimate, setEstimate] = useState(null);
  const [logEntries, setLogEntries] = useState([]);
  const [sseConnected, setSseConnected] = useState(false);
  const [sseError, setSseError] = useState(false);
  const [startTime, setStartTime] = useState(null);
  const [elapsed, setElapsed] = useState(0);
  const [loading, setLoading] = useState(true);
  const eventSourceRef = useRef(null);
  const reconnectRef = useRef(null);

  // ── Initial Data Load ────────────────────────────────────────────
  useEffect(() => {
    async function loadInitial() {
      try {
        const [statusRes, estimateRes] = await Promise.all([
          fetch(`/api/production/status/${slug}`),
          fetch('/api/production/estimate', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ slug }),
          }),
        ]);
        if (statusRes.ok) {
          const s = await statusRes.json();
          setStatus(s);
          if (s.elapsed_seconds > 0) {
            const st = new Date(Date.now() - s.elapsed_seconds * 1000);
            setStartTime(st);
            setElapsed(s.elapsed_seconds);
          }
        }
        if (estimateRes.ok) setEstimate(await estimateRes.json());
      } catch (e) { /* ignore */ }
      setLoading(false);
    }
    loadInitial();
  }, [slug]);

  // ── SSE Connection ───────────────────────────────────────────────
  const connectSSE = useCallback(() => {
    if (eventSourceRef.current) eventSourceRef.current.close();

    const es = new EventSource(`/api/production/status/${slug}/stream`);
    eventSourceRef.current = es;

    es.onopen = () => {
      setSseConnected(true);
      setSseError(false);
    };

    es.onmessage = (event) => {
      try {
        const entry = JSON.parse(event.data);
        if (entry.type === 'connected') return;

        setLogEntries(prev => {
          const next = [...prev, entry];
          return next.length > 500 ? next.slice(-500) : next;
        });

        // Track start time from first real entry
        if (entry.timestamp) {
          setStartTime(prev => prev || new Date(entry.timestamp));
        }

        // Update status on terminal events
        if (entry.type === 'production_complete' || entry.type === 'production_failed') {
          setStatus(prev => ({
            ...prev,
            status: entry.type === 'production_complete' ? 'completed' : 'failed',
          }));
        }
        // Update current phase on step events (counts come from API poll below)
        if (entry.type === 'step_complete' || entry.type === 'step_start') {
          setStatus(prev => ({
            ...prev,
            current_phase: entry.phase || prev?.current_phase,
          }));
        }
      } catch (e) { /* skip bad entries */ }
    };

    es.onerror = () => {
      setSseConnected(false);
      setSseError(true);
      es.close();
      // Auto-reconnect after 5s
      reconnectRef.current = setTimeout(connectSSE, 5000);
    };
  }, [slug]);

  useEffect(() => {
    connectSSE();
    return () => {
      if (eventSourceRef.current) eventSourceRef.current.close();
      if (reconnectRef.current) clearTimeout(reconnectRef.current);
    };
  }, [connectSSE]);

  // ── Elapsed Timer ────────────────────────────────────────────────
  useEffect(() => {
    if (!startTime) return;
    const isDone = status?.status === 'completed' || status?.status === 'failed';
    if (isDone) return;

    const timer = setInterval(() => {
      setElapsed(Math.floor((Date.now() - startTime.getTime()) / 1000));
    }, 1000);
    return () => clearInterval(timer);
  }, [startTime, status?.status]);

  // ── Poll API for real step counts (build_plan.json = source of truth) ──
  useEffect(() => {
    const isDone = status?.status === 'completed' || status?.status === 'failed'
      || status?.status === 'production_complete' || status?.status === 'production_failed';
    if (isDone) return;

    const poll = async () => {
      try {
        const r = await fetch(`/api/production/status/${slug}`);
        if (r.ok) {
          const s = await r.json();
          setStatus(prev => ({
            ...prev,
            completed_steps: s.completed_steps,
            failed_steps: s.failed_steps,
            total_steps: s.total_steps,
            total_cost: s.total_cost,
            status: s.status,
          }));
        }
      } catch (e) { /* ignore */ }
    };
    const interval = setInterval(poll, 15000);
    return () => clearInterval(interval);
  }, [slug, status?.status]);

  // ── Derived Values ───────────────────────────────────────────────
  const isDone = status?.status === 'completed' || status?.status === 'production_complete';
  const isFailed = status?.status === 'failed' || status?.status === 'production_failed';
  const isRunning = status?.status === 'running' || status?.status === 'in_production';
  const isNotStarted = !status || status.status === 'not_started' || status.project_status === 'production_gate_pending';

  const completedSteps = status?.completed_steps || 0;
  const totalSteps = status?.total_steps || estimate?.totals?.api_calls || 0;
  const progressPct = totalSteps > 0 ? Math.min(100, Math.round((completedSteps / totalSteps) * 100)) : 0;

  const estimatedTotalSec = (estimate?.totals?.estimated_hours?.factory_hours_estimated || 0) * 3600;
  const remainingSec = estimatedTotalSec > 0 && elapsed > 0
    ? Math.max(0, Math.round(estimatedTotalSec * (1 - progressPct / 100)))
    : null;

  const currentStep = logEntries.length > 0
    ? logEntries[logEntries.length - 1]
    : null;

  // ── Aggregate screen states from log entries ─────────────────────
  const screenStates = {};
  for (const entry of logEntries) {
    if (!entry.screen) continue;
    const id = entry.screen;
    if (!screenStates[id]) screenStates[id] = { id, status: 'waiting', agent: null, loc: 0, cost: 0, duration: 0, files: 0, repairs: 0 };
    const s = screenStates[id];
    if (entry.type === 'step_start') { s.status = 'in_progress'; s.agent = entry.agent; }
    if (entry.type === 'step_complete') {
      s.status = entry.subtype === 'repair' ? 'repaired' : 'completed';
      s.agent = entry.agent || s.agent;
      s.loc += entry.loc || 0;
      s.cost += entry.cost || 0;
      s.duration += entry.duration || 0;
      s.files += entry.files || 0;
      if (entry.subtype === 'repair') s.repairs++;
    }
    if (entry.type === 'error') { s.status = 'error'; s.repairs = (s.repairs || 0); }
  }

  // Merge with build_spec screens (if available from estimate)
  const allScreens = [];
  const totalScreens = estimate?.scope?.total_screens || 0;
  for (let i = 1; i <= totalScreens; i++) {
    const id = `S${String(i).padStart(3, '0')}`;
    allScreens.push(screenStates[id] || { id, status: 'waiting', agent: null, loc: 0, cost: 0, duration: 0, files: 0, repairs: 0 });
  }
  // Add any screens from log that exceed the estimated count
  for (const id of Object.keys(screenStates)) {
    if (!allScreens.find(s => s.id === id)) allScreens.push(screenStates[id]);
  }

  const screensComplete = allScreens.filter(s => s.status === 'completed' || s.status === 'repaired').length;
  const totalLoc = allScreens.reduce((sum, s) => sum + s.loc, 0);
  const totalFiles = allScreens.reduce((sum, s) => sum + s.files, 0);

  // ── Aggregate model costs ────────────────────────────────────────
  const modelCosts = {};
  for (const entry of logEntries) {
    if (!entry.model && !entry.agent) continue;
    const key = entry.model || 'unknown';
    if (!modelCosts[key]) modelCosts[key] = { calls: 0, tokens: 0, cost: 0 };
    modelCosts[key].calls++;
    modelCosts[key].tokens += entry.tokens || 0;
    modelCosts[key].cost += entry.cost || 0;
  }

  // ── Not Started State ────────────────────────────────────────────
  if (!loading && isNotStarted) {
    return (
      <div className="max-w-4xl mx-auto">
        <button onClick={onBack} className="text-factory-text-secondary hover:text-factory-text mb-6 flex items-center gap-2 text-sm">
          <ArrowLeft size={16} /> Zurueck
        </button>
        <div className="flex flex-col items-center justify-center h-64">
          <Pause size={48} className="text-factory-text-secondary mb-4" />
          <p className="text-factory-text text-lg">Production wurde noch nicht gestartet</p>
          <p className="text-factory-text-secondary text-sm mt-1">Zurueck zum Briefing um Production freizugeben.</p>
        </div>
      </div>
    );
  }

  // ── Loading State ────────────────────────────────────────────────
  if (loading) {
    return (
      <div className="max-w-6xl mx-auto">
        <div className="bg-factory-surface rounded-xl border border-factory-border p-8 animate-pulse">
          <div className="h-8 bg-white/5 rounded-lg w-64 mb-4" />
          <div className="h-4 bg-white/5 rounded-lg w-full mb-8" />
          <div className="grid grid-cols-3 gap-4 mb-6">
            {[1, 2, 3].map(i => <div key={i} className="h-32 bg-white/5 rounded-lg" />)}
          </div>
          <div className="h-48 bg-white/5 rounded-lg" />
        </div>
      </div>
    );
  }

  return (
    <div className="max-w-6xl mx-auto space-y-4">
      {/* ── Back Button ──────────────────────────────────────────── */}
      <button onClick={onBack} className="text-factory-text-secondary hover:text-factory-text flex items-center gap-2 text-sm">
        <ArrowLeft size={16} /> Zurueck
      </button>

      {/* ── Area 1: Header with Live Status ──────────────────────── */}
      <div className="bg-factory-surface rounded-xl border border-factory-border p-5">
        <div className="flex items-center justify-between mb-3">
          <div className="flex items-center gap-3">
            <div className={`w-3 h-3 rounded-full ${
              isDone ? 'bg-factory-success' :
              isFailed ? 'bg-factory-error' :
              'bg-factory-success animate-pulse'
            }`} />
            <h2 className="text-xl font-bold text-factory-text">
              {estimate?.project?.name || slug}
            </h2>
            <span className={`text-sm font-medium ${
              isDone ? 'text-factory-success' :
              isFailed ? 'text-factory-error' :
              'text-factory-accent'
            }`}>
              {isDone ? 'Production abgeschlossen' :
               isFailed ? 'Production fehlgeschlagen' :
               'Production laeuft...'}
            </span>
          </div>
          <div className="flex items-center gap-4 text-sm">
            <span className="text-factory-text font-mono font-bold">{formatTime(elapsed)}</span>
            {remainingSec != null && isRunning && (
              <span className="text-factory-text-secondary">~{formatMinutes(remainingSec)} verbleibend</span>
            )}
            {sseConnected ? (
              <Wifi size={14} className="text-factory-success" />
            ) : sseError ? (
              <span className="flex items-center gap-1 text-factory-warning text-xs">
                <WifiOff size={14} /> Verbindung unterbrochen
              </span>
            ) : null}
          </div>
        </div>

        {/* Progress Bar */}
        <div className="relative">
          <div className="h-3 bg-factory-bg rounded-full overflow-hidden">
            <div
              className={`h-full rounded-full transition-all duration-500 ${
                isFailed ? 'bg-factory-error' : 'bg-factory-success'
              }`}
              style={{ width: `${progressPct}%` }}
            />
          </div>
          <div className="flex justify-between mt-1.5 text-xs text-factory-text-secondary">
            <span>{progressPct}% ({completedSteps}/{totalSteps} Steps)</span>
            {currentStep && isRunning && (
              <span className="text-factory-accent truncate ml-4">
                {currentStep.phase ? `${currentStep.phase}: ` : ''}{currentStep.screen || currentStep.message || ''}
              </span>
            )}
          </div>
        </div>

        {/* SSE Reconnect Banner */}
        {sseError && !sseConnected && (
          <div className="mt-3 p-2 bg-factory-warning/10 rounded-lg flex items-center gap-2 text-xs text-factory-warning">
            <WifiOff size={12} /> Verbindung unterbrochen — versuche erneut...
          </div>
        )}
      </div>

      {/* ── Completion Summary ───────────────────────────────────── */}
      {(isDone || isFailed) && (
        <div className={`rounded-xl border-2 p-5 ${isDone ? 'border-factory-success bg-factory-success/5' : 'border-factory-error bg-factory-error/5'}`}>
          <div className="flex items-start justify-between">
            <div>
              <div className="flex items-center gap-2 mb-2">
                {isDone ? <CheckCircle size={20} className="text-factory-success" /> : <XCircle size={20} className="text-factory-error" />}
                <h3 className="font-bold text-factory-text">
                  {isDone ? 'Ergebnis' : 'Fehler'}
                </h3>
              </div>
              <div className="space-y-1 text-sm">
                <p className="text-factory-text">
                  {screensComplete}/{totalScreens} Screens &middot; {totalFiles} Dateien &middot; {totalLoc.toLocaleString()} LOC
                </p>
                <p className="text-factory-text-secondary">
                  Kosten: ${(status?.total_cost || 0).toFixed(2)} von ~${(estimate?.totals?.cost_usd || 0).toFixed(2)} geschaetzt
                  {estimate?.totals?.cost_usd > 0 && (
                    <span className={status?.total_cost <= estimate.totals.cost_usd ? ' text-factory-success' : ' text-factory-error'}>
                      {' '}({Math.round(((estimate.totals.cost_usd - (status?.total_cost || 0)) / estimate.totals.cost_usd) * 100)}%
                      {status?.total_cost <= estimate.totals.cost_usd ? ' unter' : ' ueber'} Budget)
                    </span>
                  )}
                </p>
                <p className="text-factory-text-secondary">
                  Dauer: {formatMinutes(elapsed)} von ~{estimate?.totals?.estimated_hours?.factory_hours_estimated || '?'}h geschaetzt
                </p>
              </div>
            </div>
            <div className="flex gap-2">
              {isFailed && (
                <button
                  onClick={async () => {
                    try {
                      const r = await fetch('/api/production/resume', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({ slug }),
                      });
                      if (r.ok) {
                        // Reset state in-place instead of full page reload (which loses productionSlug)
                        setStatus(prev => ({ ...prev, status: 'running', project_status: 'in_production' }));
                        connectSSE();
                      }
                    } catch (e) { /* ignore */ }
                  }}
                  className="px-4 py-2 bg-factory-warning/20 text-factory-warning rounded-lg text-sm hover:bg-factory-warning/30 flex items-center gap-2"
                >
                  <RotateCcw size={14} /> Production fortsetzen
                </button>
              )}
              <button onClick={onBack}
                className="px-4 py-2 bg-factory-accent/20 text-factory-accent rounded-lg text-sm hover:bg-factory-accent/30">
                Zur Pipeline
              </button>
            </div>
          </div>
        </div>
      )}

      {/* ── Area 2: Cost Tracker ─────────────────────────────────── */}
      <CostTracker
        status={status}
        estimate={estimate}
        modelCosts={modelCosts}
        logEntries={logEntries}
      />

      {/* ── Area 3: Screen Grid ──────────────────────────────────── */}
      <ScreenGrid
        screens={allScreens}
        screensComplete={screensComplete}
        totalFiles={totalFiles}
        totalLoc={totalLoc}
      />

      {/* ── Area 4: Agent Feed ───────────────────────────────────── */}
      <AgentFeed entries={logEntries} isRunning={isRunning} />
    </div>
  );
}

function formatTime(seconds) {
  const h = Math.floor(seconds / 3600);
  const m = Math.floor((seconds % 3600) / 60);
  const s = seconds % 60;
  if (h > 0) return `${h}:${String(m).padStart(2, '0')}:${String(s).padStart(2, '0')}`;
  return `${String(m).padStart(2, '0')}:${String(s).padStart(2, '0')}`;
}

function formatMinutes(seconds) {
  if (seconds < 60) return `${seconds}s`;
  const m = Math.round(seconds / 60);
  if (m < 60) return `${m} Min`;
  const h = Math.floor(m / 60);
  const rm = m % 60;
  return rm > 0 ? `${h}h ${rm}m` : `${h}h`;
}
