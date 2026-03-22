import { useState, useEffect } from 'react';
import { Brain, Search, FileText, Database, FolderOpen, Smartphone, Tablet, Globe, Activity, ChevronDown, ChevronRight } from 'lucide-react';

const ICON_MAP = { Brain, Search, FileText, Database, FolderOpen, Smartphone, Tablet, Globe };

const STATUS_CONFIG = {
  green: { color: 'text-factory-success', bg: 'bg-factory-success', label: 'OK', ring: 'ring-factory-success/30' },
  yellow: { color: 'text-factory-warning', bg: 'bg-factory-warning', label: 'Warnung', ring: 'ring-factory-warning/30' },
  red: { color: 'text-factory-error', bg: 'bg-factory-error', label: 'Fehler', ring: 'ring-factory-error/30' },
  gray: { color: 'text-factory-text-secondary', bg: 'bg-factory-text-secondary', label: 'Offline', ring: 'ring-factory-border' },
};

export default function HealthOverview() {
  const [health, setHealth] = useState(null);
  const [loading, setLoading] = useState(true);
  const [expandedComponent, setExpandedComponent] = useState(null);

  useEffect(() => {
    fetchHealth();
    const interval = setInterval(fetchHealth, 30000);
    return () => clearInterval(interval);
  }, []);

  async function fetchHealth() {
    try {
      const res = await fetch('/api/health');
      const data = await res.json();
      setHealth(data);
    } catch (err) {
      console.error('Health check failed:', err);
    } finally {
      setLoading(false);
    }
  }

  if (loading) return <p className="text-factory-text-secondary">Pruefe Factory-Gesundheit...</p>;
  if (!health) return <p className="text-factory-error">Health-Check fehlgeschlagen</p>;

  const overallConfig = STATUS_CONFIG[health.overall];

  return (
    <div>
      {/* Overall Status Banner */}
      <div className={`rounded-xl border-2 ${
        health.overall === 'green' ? 'border-factory-success bg-factory-success/5' :
        health.overall === 'yellow' ? 'border-factory-warning bg-factory-warning/5' :
        'border-factory-error bg-factory-error/5'
      } p-6 mb-8`}>
        <div className="flex items-center gap-4">
          <Activity size={32} className={overallConfig.color} />
          <div>
            <h2 className={`text-xl font-bold ${overallConfig.color}`}>
              Factory {health.overall === 'green' ? 'laeuft einwandfrei' : health.overall === 'yellow' ? 'laeuft mit Einschraenkungen' : 'hat Probleme'}
            </h2>
            <p className="text-sm text-factory-text-secondary mt-1">
              Letzter Check: {new Date(health.checked_at).toLocaleTimeString('de-DE')}
            </p>
          </div>
        </div>
      </div>

      {/* Component Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        {health.components.map((comp) => {
          const cfg = STATUS_CONFIG[comp.status];
          const Icon = ICON_MAP[comp.icon] || Activity;
          const isExpanded = expandedComponent === comp.name;

          return (
            <div
              key={comp.name}
              className="bg-factory-surface rounded-xl border border-factory-border p-5 cursor-pointer hover:bg-factory-surface-hover transition-all"
              onClick={() => setExpandedComponent(isExpanded ? null : comp.name)}
            >
              <div className="flex items-center gap-4">
                <div className={`w-3 h-3 rounded-full ${cfg.bg} ring-4 ${cfg.ring}`} />
                <Icon size={24} className={cfg.color} />
                <div className="flex-1">
                  <h3 className="font-semibold text-factory-text">{comp.name}</h3>
                  <p className="text-sm text-factory-text-secondary">{comp.message}</p>
                </div>
                {isExpanded
                  ? <ChevronDown size={16} className="text-factory-text-secondary" />
                  : <ChevronRight size={16} className="text-factory-text-secondary" />
                }
              </div>

              {isExpanded && comp.details && (
                <div className="mt-4 pt-4 border-t border-factory-border">
                  <div className="grid grid-cols-2 gap-2 text-sm">
                    {Object.entries(comp.details).map(([key, value]) => (
                      <div key={key} className="flex justify-between">
                        <span className="text-factory-text-secondary">{key.replace(/_/g, ' ')}</span>
                        <span className={`font-medium ${
                          value === 'OK' || value === 'Konfiguriert' ? 'text-factory-success' :
                          value === 'Fehlt' ? 'text-factory-error' :
                          'text-factory-text'
                        }`}>{String(value)}</span>
                      </div>
                    ))}
                  </div>
                </div>
              )}
            </div>
          );
        })}
      </div>
    </div>
  );
}
