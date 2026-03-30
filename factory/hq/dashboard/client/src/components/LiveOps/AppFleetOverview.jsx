/**
 * AppFleetOverview — Uebersichtsseite aller Apps mit Health Scores.
 * Zeigt Karten-Grid, sortiert nach Health Score (Probleme zuerst).
 */

import { useState, useEffect, useCallback } from 'react';
import HealthScoreCircle, { getZone } from './HealthScoreCircle';

const ZONE_ICONS = { green: '🟢', yellow: '🟡', red: '🔴' };
const PROFILE_COLORS = {
  gaming: 'bg-purple-500/20 text-purple-300',
  education: 'bg-blue-500/20 text-blue-300',
  utility: 'bg-gray-500/20 text-gray-300',
  content: 'bg-orange-500/20 text-orange-300',
  subscription: 'bg-emerald-500/20 text-emerald-300',
};

export default function AppFleetOverview({ onSelectApp }) {
  const [apps, setApps] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [sortBy, setSortBy] = useState('score'); // 'score' | 'name'
  const [filterZone, setFilterZone] = useState('all'); // 'all' | 'green' | 'yellow' | 'red'

  const fetchApps = useCallback(async () => {
    try {
      const res = await fetch('/api/liveops/fleet');
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      const data = await res.json();
      setApps(data.apps || []);
      setError(null);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchApps();
    const interval = setInterval(fetchApps, 15000);
    return () => clearInterval(interval);
  }, [fetchApps]);

  const filtered = apps.filter(app =>
    filterZone === 'all' || app.health_zone === filterZone
  );

  const sorted = [...filtered].sort((a, b) => {
    if (sortBy === 'name') return (a.app_name || '').localeCompare(b.app_name || '');
    return (a.health_score || 0) - (b.health_score || 0); // lowest first
  });

  // Zone counts
  const zoneCounts = {
    green: apps.filter(a => a.health_zone === 'green').length,
    yellow: apps.filter(a => a.health_zone === 'yellow').length,
    red: apps.filter(a => a.health_zone === 'red').length,
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="text-factory-text-secondary">Lade App Fleet...</div>
      </div>
    );
  }

  return (
    <div>
      {/* Header */}
      <div className="flex items-center justify-between mb-6">
        <div>
          <h2 className="text-2xl font-bold text-white">App Fleet</h2>
          <p className="text-factory-text-secondary text-sm mt-1">
            {apps.length} Apps registriert
          </p>
        </div>

        <div className="flex items-center gap-4">
          {/* Zone Summary */}
          <div className="flex items-center gap-3 text-sm">
            <span className="text-factory-success">{ZONE_ICONS.green} {zoneCounts.green}</span>
            <span className="text-factory-warning">{ZONE_ICONS.yellow} {zoneCounts.yellow}</span>
            <span className="text-factory-error">{ZONE_ICONS.red} {zoneCounts.red}</span>
          </div>

          {/* Filter */}
          <select
            value={filterZone}
            onChange={e => setFilterZone(e.target.value)}
            className="bg-factory-surface border border-factory-border text-factory-text text-sm rounded px-3 py-1.5"
          >
            <option value="all">Alle Zonen</option>
            <option value="red">Nur Rot</option>
            <option value="yellow">Nur Gelb</option>
            <option value="green">Nur Gruen</option>
          </select>

          {/* Sort */}
          <button
            onClick={() => setSortBy(s => s === 'score' ? 'name' : 'score')}
            className="text-sm text-factory-text-secondary hover:text-factory-text border border-factory-border rounded px-3 py-1.5 transition-colors"
          >
            {sortBy === 'score' ? '↑ Score' : '↑ Name'}
          </button>
        </div>
      </div>

      {error && (
        <div className="bg-factory-error/10 border border-factory-error/30 text-factory-error rounded-lg p-4 mb-6">
          API Fehler: {error}
        </div>
      )}

      {/* Grid */}
      {sorted.length === 0 ? (
        <div className="flex items-center justify-center h-64 border border-dashed border-factory-border rounded-lg">
          <div className="text-center">
            <p className="text-factory-text-secondary text-lg">Keine Apps gefunden</p>
            <p className="text-factory-text-secondary text-sm mt-1">
              {filterZone !== 'all' ? 'Anderen Filter waehlen oder ' : ''}
              Apps ueber die Registry registrieren
            </p>
          </div>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 2xl:grid-cols-4 gap-4">
          {sorted.map(app => (
            <AppCard key={app.app_id} app={app} onClick={() => onSelectApp?.(app.app_id)} />
          ))}
        </div>
      )}
    </div>
  );
}

function AppCard({ app, onClick }) {
  const zone = getZone(app.health_score || 0);
  const profileClass = PROFILE_COLORS[app.app_profile] || PROFILE_COLORS.utility;
  const isCooling = !!app.cooling_until;

  return (
    <button
      onClick={onClick}
      className={`w-full text-left bg-factory-surface border rounded-lg p-5 transition-all hover:bg-factory-surface-hover hover:border-factory-accent/30 ${
        zone === 'red' ? 'border-factory-error/40' : 'border-factory-border'
      }`}
    >
      <div className="flex items-start justify-between">
        <div className="flex-1 min-w-0 mr-4">
          <h3 className="text-white font-semibold truncate">{app.app_name || 'Unnamed'}</h3>
          <div className="flex items-center gap-2 mt-1.5">
            <span className={`text-xs px-2 py-0.5 rounded-full ${profileClass}`}>
              {app.app_profile || 'utility'}
            </span>
            {app.current_version && (
              <span className="text-xs text-factory-text-secondary">
                v{app.current_version}
              </span>
            )}
          </div>
        </div>
        <HealthScoreCircle score={app.health_score || 0} size="md" animated={true} />
      </div>

      {/* Status row */}
      <div className="flex items-center gap-3 mt-4 text-xs text-factory-text-secondary">
        <span>{ZONE_ICONS[zone]} {zone}</span>
        {app.store_status && app.store_status !== 'unknown' && (
          <span>Store: {app.store_status}</span>
        )}
        {isCooling && (
          <span className="text-factory-accent-blue">
            ❄ Cooling aktiv
          </span>
        )}
      </div>
    </button>
  );
}
