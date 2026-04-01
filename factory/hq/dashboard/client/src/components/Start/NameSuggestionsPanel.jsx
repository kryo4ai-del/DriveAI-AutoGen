/**
 * NameSuggestionsPanel — Shows 3 AI-generated name suggestions for the CEO.
 *
 * Each card: rank badge, name, ampel dot, score, expandable NameGateReportCard.
 * Bottom: "Eigenen Namen eingeben" option + "Neue Vorschlaege" button.
 */

import { useState } from 'react';
import {
  Sparkles, ChevronDown, ChevronUp, Check, RefreshCw, PenLine,
  Shield, Trophy, Medal, Award,
} from 'lucide-react';
import NameGateReportCard from './NameGateReportCard';

const RANK_STYLE = [
  { bg: 'bg-yellow-500/20', border: 'border-yellow-500/40', text: 'text-yellow-400', Icon: Trophy, label: '1' },
  { bg: 'bg-gray-400/20', border: 'border-gray-400/40', text: 'text-gray-300', Icon: Medal, label: '2' },
  { bg: 'bg-orange-600/20', border: 'border-orange-600/40', text: 'text-orange-400', Icon: Award, label: '3' },
];

const AMPEL_DOT = {
  GRUEN: 'bg-green-400',
  GELB: 'bg-yellow-400',
  ROT: 'bg-red-400',
};

function strengthSummary(report) {
  if (!report) return '';
  const score = report.total_score || 0;
  const checks = report.checks || {};

  if (score >= 85) return 'Starker Name — bereit fuer den Launch';
  if (score >= 70) {
    const weak = [];
    if (checks.domain && checks.domain.score < 15) weak.push('Domain');
    if (checks.social_media && checks.social_media.score < 5) weak.push('Social');
    if (checks.trademark && checks.trademark.hard_blocker) weak.push('Markenrecht');
    return weak.length
      ? `Guter Name — ${weak.join(', ')} beachten`
      : 'Guter Name — kleinere Einschraenkungen';
  }
  if (score >= 50) return 'Akzeptabel — einige Einschraenkungen';
  return 'Schwach — Alternativen empfohlen';
}

export default function NameSuggestionsPanel({
  suggestions,
  idea,
  onSelectName,
  onCustomName,
  onRegenerate,
  loading,
}) {
  const [expandedIdx, setExpandedIdx] = useState(null);
  const [customInput, setCustomInput] = useState('');
  const [showCustom, setShowCustom] = useState(false);

  if (loading) {
    return (
      <div className="bg-factory-surface rounded-xl border border-factory-accent/30 p-6 animate-pulse">
        <div className="flex items-center gap-3 mb-6">
          <div className="w-8 h-8 rounded-full bg-factory-accent/20" />
          <div className="h-5 w-64 bg-white/5 rounded" />
        </div>
        <div className="space-y-4">
          {[1, 2, 3].map(i => (
            <div key={i} className="h-24 bg-white/5 rounded-xl" />
          ))}
        </div>
      </div>
    );
  }

  if (!suggestions || suggestions.length === 0) return null;

  return (
    <div className="bg-factory-surface rounded-xl border border-factory-accent/30 p-6">
      {/* Header */}
      <div className="flex items-center gap-3 mb-6">
        <div className="w-10 h-10 rounded-full bg-factory-accent/20 flex items-center justify-center flex-shrink-0">
          <Sparkles size={20} className="text-factory-accent" />
        </div>
        <div>
          <h3 className="text-lg font-bold text-factory-text">Namensvorschlaege fuer deine App</h3>
          <p className="text-xs text-factory-text-secondary mt-0.5">
            {suggestions.length} Namen generiert und validiert — waehle deinen Favoriten
          </p>
        </div>
      </div>

      {/* Suggestion Cards */}
      <div className="space-y-3 mb-6">
        {suggestions.map((s, idx) => {
          const report = s.report;
          const rank = RANK_STYLE[idx] || RANK_STYLE[2];
          const RankIcon = rank.Icon;
          const ampelDot = AMPEL_DOT[report.ampel] || AMPEL_DOT.ROT;
          const isExpanded = expandedIdx === idx;

          return (
            <div key={idx} className={`rounded-xl border transition-all ${
              isExpanded ? `${rank.border} bg-white/[0.02]` : 'border-factory-border hover:border-factory-accent/30'
            }`}>
              {/* Card header */}
              <div className="flex items-center gap-3 p-4">
                {/* Rank badge */}
                <div className={`w-10 h-10 rounded-full ${rank.bg} flex items-center justify-center flex-shrink-0`}>
                  <RankIcon size={18} className={rank.text} />
                </div>

                {/* Name + score */}
                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-2">
                    <h4 className="text-lg font-bold text-factory-text truncate">{report.name}</h4>
                    <div className={`w-2.5 h-2.5 rounded-full ${ampelDot} flex-shrink-0`} />
                  </div>
                  <p className="text-xs text-factory-text-secondary mt-0.5">
                    {strengthSummary(report)}
                  </p>
                </div>

                {/* Score */}
                <div className="flex-shrink-0 text-right mr-2">
                  <span className={`text-xl font-bold ${
                    report.total_score >= 70 ? 'text-green-400'
                    : report.total_score >= 50 ? 'text-yellow-400'
                    : 'text-red-400'
                  }`}>{report.total_score}</span>
                  <span className="text-xs text-factory-text-secondary">/100</span>
                </div>

                {/* Expand / Select buttons */}
                <div className="flex gap-2 flex-shrink-0">
                  <button
                    onClick={() => setExpandedIdx(isExpanded ? null : idx)}
                    className="w-8 h-8 rounded-lg bg-white/5 flex items-center justify-center hover:bg-white/10 transition-colors"
                    title="Details anzeigen"
                  >
                    {isExpanded
                      ? <ChevronUp size={16} className="text-factory-text-secondary" />
                      : <ChevronDown size={16} className="text-factory-text-secondary" />
                    }
                  </button>
                  <button
                    onClick={() => onSelectName && onSelectName(report.name, report)}
                    className="px-4 py-2 rounded-lg bg-factory-accent/20 text-factory-accent text-sm font-medium hover:bg-factory-accent/30 transition-colors flex items-center gap-1.5"
                  >
                    <Check size={14} /> Waehlen
                  </button>
                </div>
              </div>

              {/* Expanded detail view */}
              {isExpanded && (
                <div className="px-4 pb-4 border-t border-factory-border/50 mt-0 pt-4">
                  <NameGateReportCard
                    report={report}
                    onApprove={(name) => onSelectName && onSelectName(name, report)}
                    onRequestAlternatives={null}
                    onForce={(name) => onSelectName && onSelectName(name, report)}
                    loading={false}
                  />
                </div>
              )}
            </div>
          );
        })}
      </div>

      {/* Divider + Custom Name */}
      <div className="relative my-6">
        <div className="absolute inset-0 flex items-center">
          <div className="w-full border-t border-factory-border" />
        </div>
        <div className="relative flex justify-center">
          <span className="bg-factory-surface px-4 text-xs text-factory-text-secondary uppercase tracking-wide">
            oder
          </span>
        </div>
      </div>

      {showCustom ? (
        <div className="flex gap-2 mb-4">
          <input
            type="text"
            value={customInput}
            onChange={(e) => setCustomInput(e.target.value)}
            onKeyDown={(e) => {
              if (e.key === 'Enter' && customInput.trim()) {
                onCustomName && onCustomName(customInput.trim());
              }
            }}
            placeholder="Eigenen Namen eingeben..."
            className="flex-1 bg-factory-bg border border-factory-border rounded-lg px-4 py-2.5 text-factory-text placeholder-factory-text-secondary focus:border-factory-accent focus:outline-none"
            autoFocus
          />
          <button
            onClick={() => customInput.trim() && onCustomName && onCustomName(customInput.trim())}
            disabled={!customInput.trim()}
            className="px-4 py-2.5 rounded-lg bg-factory-accent/20 text-factory-accent text-sm font-medium hover:bg-factory-accent/30 transition-colors flex items-center gap-1.5 disabled:opacity-40 disabled:cursor-not-allowed"
          >
            <Shield size={14} /> Pruefen
          </button>
          <button
            onClick={() => { setShowCustom(false); setCustomInput(''); }}
            className="px-3 py-2.5 rounded-lg text-factory-text-secondary hover:text-factory-text hover:bg-white/5 transition-colors text-sm"
          >
            Abbrechen
          </button>
        </div>
      ) : (
        <button
          onClick={() => setShowCustom(true)}
          className="w-full flex items-center justify-center gap-2 py-3 px-4 rounded-lg border border-dashed border-factory-border text-factory-text-secondary hover:border-factory-accent/30 hover:text-factory-accent transition-colors text-sm"
        >
          <PenLine size={14} /> Eigenen Namen eingeben
        </button>
      )}

      {/* Regenerate link */}
      <button
        onClick={() => onRegenerate && onRegenerate()}
        className="w-full mt-4 flex items-center justify-center gap-2 text-xs text-factory-text-secondary hover:text-factory-accent transition-colors py-2"
      >
        <RefreshCw size={12} /> Neue Vorschlaege generieren
      </button>
    </div>
  );
}
