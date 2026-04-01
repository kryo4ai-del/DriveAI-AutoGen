import { useState, useEffect, useRef } from 'react';

export default function AgentFeed({ entries, isRunning }) {
  const [autoScroll, setAutoScroll] = useState(true);
  const feedRef = useRef(null);
  const prevLenRef = useRef(0);

  // Auto-scroll when new entries arrive
  useEffect(() => {
    if (autoScroll && feedRef.current && entries.length > prevLenRef.current) {
      feedRef.current.scrollTop = 0; // newest at top
    }
    prevLenRef.current = entries.length;
  }, [entries.length, autoScroll]);

  function handleScroll() {
    if (!feedRef.current) return;
    // If user scrolls away from top, disable auto-scroll
    setAutoScroll(feedRef.current.scrollTop < 10);
  }

  // Show last 50 entries, newest first
  const visible = entries.slice(-50).reverse();

  return (
    <div className="bg-factory-surface rounded-xl border border-factory-border p-5">
      <div className="flex items-center justify-between mb-3">
        <h3 className="font-semibold text-factory-text">Agent Activity</h3>
        <div className="flex items-center gap-3">
          {!autoScroll && isRunning && (
            <button
              onClick={() => setAutoScroll(true)}
              className="text-xs text-factory-accent hover:text-factory-accent/80"
            >
              Zum Neuesten
            </button>
          )}
          <span className="text-xs text-factory-text-secondary">{entries.length} Eintraege</span>
        </div>
      </div>

      <div
        ref={feedRef}
        onScroll={handleScroll}
        className="max-h-64 overflow-y-auto font-mono text-xs leading-relaxed"
      >
        {visible.length === 0 ? (
          <div className="text-center py-8 text-factory-text-secondary">
            {isRunning ? (
              <div className="flex items-center justify-center gap-2">
                <div className="w-2 h-2 rounded-full bg-factory-accent animate-pulse" />
                Warte auf erste Daten...
              </div>
            ) : (
              'Keine Eintraege'
            )}
          </div>
        ) : (
          <table className="w-full">
            <tbody>
              {visible.map((entry, i) => {
                const time = entry.timestamp ? new Date(entry.timestamp).toLocaleTimeString('de-DE', { hour: '2-digit', minute: '2-digit', second: '2-digit' }) : '';
                const isError = entry.type === 'error';
                const isComplete = entry.type === 'step_complete';
                const isPhase = entry.type === 'phase_complete' || entry.type === 'phase_start';
                const isProgress = entry.type === 'step_start';

                return (
                  <tr key={i} className={`border-b border-factory-border/20 ${
                    isError ? 'text-factory-error' :
                    isProgress ? 'text-factory-warning' :
                    isPhase ? 'text-factory-accent' :
                    'text-factory-text-secondary'
                  }`}>
                    <td className="py-0.5 pr-3 text-factory-text-secondary whitespace-nowrap">{time}</td>
                    <td className="py-0.5 pr-3 whitespace-nowrap text-factory-text">{entry.agent || '\u2014'}</td>
                    <td className="py-0.5 pr-3 truncate max-w-[200px]">
                      {entry.screen || ''}{entry.message ? ` ${entry.message}` : ''}{entry.phase && !entry.screen ? entry.phase : ''}
                    </td>
                    <td className="py-0.5 pr-3 text-right whitespace-nowrap">
                      {entry.loc ? `${entry.loc} LOC` : '\u2014'}
                    </td>
                    <td className="py-0.5 pr-3 text-right whitespace-nowrap">
                      {entry.cost ? `$${entry.cost.toFixed(3)}` : '\u2014'}
                    </td>
                    <td className="py-0.5 pr-3 text-right whitespace-nowrap">
                      {entry.duration ? `${entry.duration.toFixed(1)}s` : '\u2014'}
                    </td>
                    <td className="py-0.5 text-right whitespace-nowrap">
                      {isComplete ? '\u2705' : isError ? '\u274C' : isProgress ? '\uD83D\uDD04' : isPhase ? '\u2139\uFE0F' : ''}
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        )}
      </div>
    </div>
  );
}
