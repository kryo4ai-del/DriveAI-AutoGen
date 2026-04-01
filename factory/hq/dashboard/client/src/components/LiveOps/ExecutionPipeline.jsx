/**
 * ExecutionPipeline — Shows the Execution Path status:
 * Briefings -> Submissions -> Releases pipeline view.
 */

import { useState, useEffect } from 'react';

const PRIORITY_COLORS = {
  'P0-CRITICAL': 'text-red-400',
  'P1-HIGH': 'text-orange-400',
  'P2-MEDIUM': 'text-yellow-400',
};

const STATUS_STYLES = {
  created: 'bg-gray-500/20 text-gray-300',
  submitted: 'bg-blue-500/20 text-blue-300',
  accepted: 'bg-cyan-500/20 text-cyan-300',
  in_progress: 'bg-purple-500/20 text-purple-300',
  completed: 'bg-green-500/20 text-green-300',
  failed: 'bg-red-500/20 text-red-300',
  released: 'bg-emerald-500/20 text-emerald-300',
  qa_failed: 'bg-red-500/20 text-red-300',
  qa_passed: 'bg-green-500/20 text-green-300',
};

export default function ExecutionPipeline({ appId }) {
  const [briefings, setBriefings] = useState([]);
  const [submissions, setSubmissions] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function fetchData() {
      try {
        const query = appId ? `?appId=${appId}` : '';
        const [bRes, sRes] = await Promise.all([
          fetch(`/api/liveops/briefings${query}`),
          fetch(`/api/liveops/submissions${query}`),
        ]);
        if (bRes.ok) {
          const data = await bRes.json();
          setBriefings(data.briefings || []);
        }
        if (sRes.ok) {
          const data = await sRes.json();
          setSubmissions(data.submissions || []);
        }
      } catch (err) {
        console.error('ExecutionPipeline fetch error:', err);
      } finally {
        setLoading(false);
      }
    }
    fetchData();
    const interval = setInterval(fetchData, 15000);
    return () => clearInterval(interval);
  }, [appId]);

  if (loading) {
    return <div className="text-factory-text-secondary text-sm">Lade Pipeline...</div>;
  }

  return (
    <div className="space-y-6">
      {/* Briefings */}
      <div className="bg-factory-surface border border-factory-border rounded-lg p-5">
        <h3 className="text-white font-semibold mb-4">
          Briefings {briefings.length > 0 && <span className="text-factory-text-secondary text-sm">({briefings.length})</span>}
        </h3>
        {briefings.length === 0 ? (
          <p className="text-factory-text-secondary text-sm">Keine Briefings vorhanden.</p>
        ) : (
          <div className="space-y-2 max-h-64 overflow-y-auto">
            {briefings.map((b, i) => (
              <div key={i} className="flex items-center justify-between text-sm border-b border-factory-border/50 pb-2">
                <div className="flex items-center gap-2">
                  <span className={`text-xs font-medium ${PRIORITY_COLORS[b.priority] || 'text-gray-400'}`}>
                    {b.priority}
                  </span>
                  <span className="text-white">{b.action_type}</span>
                  <span className="text-factory-text-secondary">v{b.target_version}</span>
                </div>
                <div className="flex items-center gap-2">
                  <span className={`text-xs px-2 py-0.5 rounded-full ${STATUS_STYLES[b.status] || STATUS_STYLES.created}`}>
                    {b.status}
                  </span>
                  <span className="text-factory-text-secondary text-xs">
                    {b.created_at?.split('T')[0] || ''}
                  </span>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Submissions */}
      <div className="bg-factory-surface border border-factory-border rounded-lg p-5">
        <h3 className="text-white font-semibold mb-4">
          Factory Submissions {submissions.length > 0 && <span className="text-factory-text-secondary text-sm">({submissions.length})</span>}
        </h3>
        {submissions.length === 0 ? (
          <p className="text-factory-text-secondary text-sm">Keine Submissions vorhanden.</p>
        ) : (
          <div className="space-y-2 max-h-64 overflow-y-auto">
            {submissions.map((s, i) => (
              <div key={i} className="flex items-center justify-between text-sm border-b border-factory-border/50 pb-2">
                <div className="flex items-center gap-2">
                  <span className={`text-xs font-medium ${PRIORITY_COLORS[s.priority] || 'text-gray-400'}`}>
                    {s.priority}
                  </span>
                  <span className="text-white">{s.action_type}</span>
                  <span className="text-factory-text-secondary">v{s.target_version}</span>
                </div>
                <div className="flex items-center gap-2">
                  <span className={`text-xs px-2 py-0.5 rounded-full ${STATUS_STYLES[s.status] || STATUS_STYLES.created}`}>
                    {s.status}
                  </span>
                  <span className="text-factory-text-secondary text-xs">
                    {s.created_at?.split('T')[0] || ''}
                  </span>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
