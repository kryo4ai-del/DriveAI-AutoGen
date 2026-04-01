/**
 * NameAlternativesPanel — Zeigt alternative Namensvorschlaege mit Mini-Validierung.
 *
 * Jeder Vorschlag zeigt Name, Ampel-Dot, Score und expandierbare Check-Zusammenfassung.
 */

import { useState } from 'react';
import {
  CheckCircle, XCircle, AlertTriangle, ChevronDown, ChevronUp,
  Lightbulb, ArrowRight,
} from 'lucide-react';

const AMPEL_DOT = {
  GRUEN: { bg: 'bg-green-400', shadow: '0 0 6px #22c55e' },
  GELB:  { bg: 'bg-yellow-400', shadow: '0 0 6px #eab308' },
  ROT:   { bg: 'bg-red-400', shadow: '0 0 6px #ef4444' },
};

const AMPEL_TEXT = {
  GRUEN: 'text-green-400',
  GELB:  'text-yellow-400',
  ROT:   'text-red-400',
};

const CHECK_LABELS = {
  domain:       'Domain',
  app_store:    'App Store',
  social_media: 'Social Media',
  trademark:    'Markenrecht',
  brand_fit:    'Brand Fit',
  aso:          'ASO',
};

const CHECK_MAX = {
  domain: 25, app_store: 25, social_media: 10,
  trademark: 25, brand_fit: 10, aso: 5,
};

function MiniCheckRow({ label, score, maxScore }) {
  const pct = maxScore > 0 ? score / maxScore : 0;
  const color = pct >= 0.8 ? '#22c55e' : pct >= 0.5 ? '#eab308' : '#ef4444';
  return (
    <div className="flex items-center gap-2">
      <span className="text-xs text-factory-text-secondary w-24">{label}</span>
      <div className="flex-1 h-1 bg-white/5 rounded-full overflow-hidden">
        <div className="h-full rounded-full" style={{
          width: `${Math.round(pct * 100)}%`, backgroundColor: color,
        }} />
      </div>
      <span className="text-xs font-mono w-8 text-right" style={{ color }}>
        {score}/{maxScore}
      </span>
    </div>
  );
}

export default function NameAlternativesPanel({ alternatives, onSelectAlternative, loading }) {
  const [expanded, setExpanded] = useState({});

  if (loading) {
    return (
      <div className="bg-factory-surface rounded-xl border border-factory-border p-6 animate-pulse">
        <div className="h-6 w-48 bg-white/5 rounded mb-4" />
        {[1, 2, 3].map(i => (
          <div key={i} className="h-14 bg-white/5 rounded-lg mb-2" />
        ))}
      </div>
    );
  }

  if (!alternatives || alternatives.length === 0) {
    return (
      <div className="bg-factory-surface rounded-xl border border-factory-border p-6">
        <div className="flex items-center gap-2 mb-2">
          <Lightbulb size={18} className="text-factory-accent" />
          <h3 className="text-sm font-bold text-factory-text">Alternative Namensvorschlaege</h3>
        </div>
        <p className="text-sm text-factory-text-secondary">
          Keine Alternativen gefunden. Versuche eine andere Idee-Beschreibung.
        </p>
      </div>
    );
  }

  function toggleExpand(idx) {
    setExpanded(prev => ({ ...prev, [idx]: !prev[idx] }));
  }

  return (
    <div className="bg-factory-surface rounded-xl border border-factory-border p-6">
      <div className="flex items-center gap-2 mb-4">
        <Lightbulb size={18} className="text-factory-accent" />
        <h3 className="text-sm font-bold text-factory-text">
          Alternative Namensvorschlaege ({alternatives.length})
        </h3>
      </div>

      <div className="space-y-2">
        {alternatives.map((alt, idx) => {
          const dot = AMPEL_DOT[alt.ampel] || AMPEL_DOT.ROT;
          const textColor = AMPEL_TEXT[alt.ampel] || AMPEL_TEXT.ROT;
          const isExpanded = expanded[idx];
          const checks = alt.checks || {};

          return (
            <div key={idx} className="rounded-lg border border-factory-border overflow-hidden">
              {/* Header row */}
              <div className="flex items-center gap-3 px-4 py-3 hover:bg-white/5 transition-colors">
                {/* Ampel dot */}
                <div className={`w-3 h-3 rounded-full ${dot.bg} flex-shrink-0`}
                  style={{ boxShadow: dot.shadow }} />

                {/* Name */}
                <span className="text-sm font-bold text-factory-text flex-1 truncate">
                  {alt.name}
                </span>

                {/* Score */}
                <span className={`text-sm font-mono font-bold ${textColor} flex-shrink-0`}>
                  {alt.total_score}/100
                </span>

                {/* Expand button */}
                <button
                  onClick={() => toggleExpand(idx)}
                  className="p-1 text-factory-text-secondary hover:text-factory-text transition-colors flex-shrink-0"
                >
                  {isExpanded ? <ChevronUp size={14} /> : <ChevronDown size={14} />}
                </button>

                {/* Select button */}
                <button
                  onClick={() => onSelectAlternative && onSelectAlternative(alt.name)}
                  className="flex items-center gap-1 text-xs px-3 py-1.5 rounded-lg bg-factory-accent/20 text-factory-accent font-medium hover:bg-factory-accent/30 transition-colors flex-shrink-0"
                >
                  Waehlen <ArrowRight size={12} />
                </button>
              </div>

              {/* Expanded: mini checks */}
              {isExpanded && (
                <div className="px-4 pb-3 pt-1 border-t border-factory-border/50 space-y-1.5">
                  {Object.entries(CHECK_LABELS).map(([key, label]) => {
                    const check = checks[key];
                    if (!check) return null;
                    return (
                      <MiniCheckRow
                        key={key}
                        label={label}
                        score={check.score != null ? check.score : 0}
                        maxScore={CHECK_MAX[key] || 10}
                      />
                    );
                  })}

                  {alt.hard_blockers && alt.hard_blockers.length > 0 && (
                    <div className="flex items-center gap-1 mt-1">
                      <XCircle size={12} className="text-red-400" />
                      <span className="text-xs text-red-400">
                        Hard Blockers: {alt.hard_blockers.join(', ')}
                      </span>
                    </div>
                  )}
                </div>
              )}
            </div>
          );
        })}
      </div>
    </div>
  );
}
