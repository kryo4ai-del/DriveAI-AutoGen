/**
 * ReleaseTracker — Shows release records from the Release Manager.
 * QA status, store upload, cooling period info.
 */

import { useState, useEffect } from 'react';

const STATUS_STYLES = {
  pending: 'bg-gray-500/20 text-gray-300',
  qa_check: 'bg-yellow-500/20 text-yellow-300',
  qa_passed: 'bg-green-500/20 text-green-300',
  qa_failed: 'bg-red-500/20 text-red-300',
  uploading: 'bg-blue-500/20 text-blue-300',
  uploaded: 'bg-cyan-500/20 text-cyan-300',
  released: 'bg-emerald-500/20 text-emerald-300',
  failed: 'bg-red-500/20 text-red-300',
};

const QA_ICON = { true: '[OK]', false: '[FAIL]', null: '[-]' };

export default function ReleaseTracker({ appId }) {
  const [releases, setReleases] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function fetchData() {
      try {
        const query = appId ? `?appId=${appId}` : '';
        const res = await fetch(`/api/liveops/releases-exec${query}`);
        if (res.ok) {
          const data = await res.json();
          setReleases(data.releases || []);
        }
      } catch (err) {
        console.error('ReleaseTracker fetch error:', err);
      } finally {
        setLoading(false);
      }
    }
    fetchData();
    const interval = setInterval(fetchData, 15000);
    return () => clearInterval(interval);
  }, [appId]);

  if (loading) {
    return <div className="text-factory-text-secondary text-sm">Lade Releases...</div>;
  }

  // Summary stats
  const released = releases.filter(r => r.status === 'released').length;
  const failed = releases.filter(r => r.status === 'qa_failed' || r.status === 'failed').length;
  const active = releases.filter(r => !['released', 'qa_failed', 'failed'].includes(r.status)).length;

  return (
    <div className="bg-factory-surface border border-factory-border rounded-lg p-5">
      <div className="flex items-center justify-between mb-4">
        <h3 className="text-white font-semibold">Release Tracker</h3>
        <div className="flex gap-3 text-xs">
          {released > 0 && (
            <span className="text-emerald-400">{released} released</span>
          )}
          {active > 0 && (
            <span className="text-blue-400">{active} active</span>
          )}
          {failed > 0 && (
            <span className="text-red-400">{failed} failed</span>
          )}
        </div>
      </div>

      {releases.length === 0 ? (
        <p className="text-factory-text-secondary text-sm">Keine Releases vorhanden.</p>
      ) : (
        <div className="space-y-3 max-h-80 overflow-y-auto">
          {releases.map((r, i) => (
            <div key={i} className="border border-factory-border/50 rounded-lg p-3">
              <div className="flex items-center justify-between mb-1">
                <div className="flex items-center gap-2">
                  <span className="text-white font-medium text-sm">v{r.target_version}</span>
                  <span className="text-factory-text-secondary text-xs">{r.action_type}</span>
                </div>
                <span className={`text-xs px-2 py-0.5 rounded-full ${STATUS_STYLES[r.status] || STATUS_STYLES.pending}`}>
                  {r.status}
                </span>
              </div>
              <div className="flex items-center gap-4 text-xs text-factory-text-secondary">
                <span>QA: <span className={r.qa_passed ? 'text-green-400' : r.qa_passed === false ? 'text-red-400' : 'text-gray-500'}>
                  {QA_ICON[r.qa_passed]}
                </span></span>
                {r.cooling_hours && (
                  <span>Cooling: {r.cooling_hours}h</span>
                )}
                <span>{r.created_at?.split('T')[0] || ''}</span>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
