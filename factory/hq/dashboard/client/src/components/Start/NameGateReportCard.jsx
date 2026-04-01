/**
 * NameGateReportCard — Zeigt das vollstaendige Name Gate Validierungsergebnis.
 *
 * Ampel-Badge, 6 Check-Zeilen (expandierbar), Blocker-Banner,
 * Empfehlungen und Aktions-Buttons je nach Ergebnis.
 */

import { useState } from 'react';
import {
  CheckCircle, XCircle, AlertTriangle, ChevronDown, ChevronUp,
  Globe, Store, AtSign, Shield, Sparkles, Search, Lock, ArrowRight,
} from 'lucide-react';

const AMPEL = {
  GRUEN:  { bg: 'bg-green-500/20', border: 'border-green-500/40', text: 'text-green-400', color: '#22c55e', label: 'Freigegeben', Icon: CheckCircle },
  GELB:   { bg: 'bg-yellow-500/20', border: 'border-yellow-500/40', text: 'text-yellow-400', color: '#eab308', label: 'Einschraenkungen', Icon: AlertTriangle },
  ROT:    { bg: 'bg-red-500/20', border: 'border-red-500/40', text: 'text-red-400', color: '#ef4444', label: 'Blockiert', Icon: XCircle },
};

const CHECK_META = [
  { key: 'domain',       label: 'Domain',        maxScore: 25, Icon: Globe },
  { key: 'app_store',    label: 'App Store',      maxScore: 25, Icon: Store },
  { key: 'social_media', label: 'Social Media',   maxScore: 10, Icon: AtSign },
  { key: 'trademark',    label: 'Markenrecht',    maxScore: 25, Icon: Shield },
  { key: 'brand_fit',    label: 'Brand Fit',      maxScore: 10, Icon: Sparkles },
  { key: 'aso',          label: 'ASO',            maxScore: 5,  Icon: Search },
];

function statusIcon(ok) {
  if (ok === true) return <CheckCircle size={16} className="text-green-400 flex-shrink-0" />;
  if (ok === false) return <XCircle size={16} className="text-red-400 flex-shrink-0" />;
  return <AlertTriangle size={16} className="text-yellow-400 flex-shrink-0" />;
}

function scoreColor(score, max) {
  const pct = max > 0 ? score / max : 0;
  if (pct >= 0.8) return 'text-green-400';
  if (pct >= 0.5) return 'text-yellow-400';
  return 'text-red-400';
}

function barWidth(score, max) {
  return max > 0 ? `${Math.round((score / max) * 100)}%` : '0%';
}

function barColor(score, max) {
  const pct = max > 0 ? score / max : 0;
  if (pct >= 0.8) return '#22c55e';
  if (pct >= 0.5) return '#eab308';
  return '#ef4444';
}

// ─── Detail renderers per check type ───────────────────────────

function DomainDetails({ data }) {
  const tlds = [
    { key: 'com', label: '.com' },
    { key: 'de',  label: '.de' },
    { key: 'app', label: '.app' },
    { key: 'io',  label: '.io' },
  ];
  return (
    <div className="flex flex-wrap gap-2 mt-2">
      {tlds.map(t => (
        <span key={t.key} className={`text-xs px-2 py-1 rounded-md ${
          data[t.key] ? 'bg-green-500/15 text-green-400' : 'bg-red-500/15 text-red-400'
        }`}>
          {data[t.key] ? '\u2713' : '\u2717'} {t.label}
        </span>
      ))}
    </div>
  );
}

function StoreDetails({ data }) {
  const stores = [
    { key: 'apple',  label: 'Apple App Store' },
    { key: 'google', label: 'Google Play' },
  ];
  return (
    <div className="flex flex-wrap gap-2 mt-2">
      {stores.map(s => (
        <span key={s.key} className={`text-xs px-2 py-1 rounded-md ${
          data[s.key] ? 'bg-green-500/15 text-green-400' : 'bg-red-500/15 text-red-400'
        }`}>
          {data[s.key] ? '\u2713 Frei' : '\u2717 Belegt'} — {s.label}
        </span>
      ))}
    </div>
  );
}

function SocialDetails({ data }) {
  const platforms = ['instagram', 'tiktok', 'twitter', 'facebook', 'youtube'];
  return (
    <div className="flex flex-wrap gap-2 mt-2">
      {platforms.map(p => {
        if (data[p] === undefined) return null;
        return (
          <span key={p} className={`text-xs px-2 py-1 rounded-md capitalize ${
            data[p] ? 'bg-green-500/15 text-green-400' : 'bg-red-500/15 text-red-400'
          }`}>
            {data[p] ? '\u2713' : '\u2717'} {p}
          </span>
        );
      })}
    </div>
  );
}

function TrademarkDetails({ data }) {
  const regs = [
    { key: 'dpma',  label: 'DPMA (DE)' },
    { key: 'euipo', label: 'EUIPO (EU)' },
  ];
  return (
    <div className="space-y-1 mt-2">
      {regs.map(r => {
        const val = data[r.key];
        const clear = typeof val === 'object' ? !val.found : val;
        return (
          <span key={r.key} className={`text-xs px-2 py-1 rounded-md inline-block mr-2 ${
            clear ? 'bg-green-500/15 text-green-400' : 'bg-red-500/15 text-red-400'
          }`}>
            {clear ? '\u2713 Keine Konflikte' : '\u2717 Konflikt gefunden'} — {r.label}
          </span>
        );
      })}
      {data.hard_blocker && (
        <p className="text-xs text-red-400 font-medium mt-1">Hard Blocker: Markenrechtlicher Konflikt!</p>
      )}
    </div>
  );
}

function BrandFitDetails({ data }) {
  const dims = [
    { key: 'tonality',          label: 'Tonality' },
    { key: 'pronounceability',  label: 'Aussprechbarkeit' },
    { key: 'memorability',      label: 'Merkbarkeit' },
    { key: 'confusion_risk',    label: 'Verwechslungsgefahr' },
    { key: 'international',     label: 'International' },
  ];
  return (
    <div className="space-y-1.5 mt-2">
      {dims.map(d => {
        const val = data[d.key];
        if (val === undefined) return null;
        const pct = typeof val === 'number' ? val * 10 : 0;
        return (
          <div key={d.key} className="flex items-center gap-2">
            <span className="text-xs text-factory-text-secondary w-32">{d.label}</span>
            <div className="flex-1 h-1.5 bg-white/5 rounded-full overflow-hidden">
              <div className="h-full rounded-full transition-all" style={{
                width: `${pct}%`,
                backgroundColor: pct >= 70 ? '#22c55e' : pct >= 40 ? '#eab308' : '#ef4444',
              }} />
            </div>
            <span className="text-xs font-mono w-6 text-right" style={{
              color: pct >= 70 ? '#22c55e' : pct >= 40 ? '#eab308' : '#ef4444',
            }}>{val}</span>
          </div>
        );
      })}
      {data.recommendation && (
        <p className="text-xs text-factory-text-secondary mt-1 italic">{data.recommendation}</p>
      )}
    </div>
  );
}

function ASODetails({ data }) {
  const satColors = { low: 'text-green-400', medium: 'text-yellow-400', high: 'text-red-400' };
  const satLabels = { low: 'Gering', medium: 'Mittel', high: 'Hoch' };
  return (
    <div className="mt-2 space-y-1">
      <p className="text-xs">
        Keyword-Saettigung:{' '}
        <span className={`font-medium ${satColors[data.keyword_saturation] || 'text-factory-text-secondary'}`}>
          {satLabels[data.keyword_saturation] || data.keyword_saturation}
        </span>
      </p>
      {data.dominant_competitors && data.dominant_competitors.length > 0 && (
        <p className="text-xs text-factory-text-secondary">
          Konkurrenten: {data.dominant_competitors.join(', ')}
        </p>
      )}
    </div>
  );
}

const DETAIL_RENDERERS = {
  domain: DomainDetails,
  app_store: StoreDetails,
  social_media: SocialDetails,
  trademark: TrademarkDetails,
  brand_fit: BrandFitDetails,
  aso: ASODetails,
};

// ─── Main Component ────────────────────────────────────────────

export default function NameGateReportCard({ report, onApprove, onRequestAlternatives, onForce, loading }) {
  const [expanded, setExpanded] = useState({});

  if (loading) {
    return (
      <div className="bg-factory-surface rounded-xl border border-factory-border p-6 animate-pulse">
        <div className="h-16 bg-white/5 rounded-lg mb-4" />
        <div className="space-y-3">
          {[1, 2, 3, 4, 5, 6].map(i => (
            <div key={i} className="h-10 bg-white/5 rounded-lg" />
          ))}
        </div>
      </div>
    );
  }

  if (!report) return null;

  const ampel = AMPEL[report.ampel] || AMPEL.ROT;
  const AmpelIcon = ampel.Icon;
  const checks = report.checks || {};

  function toggleExpand(key) {
    setExpanded(prev => ({ ...prev, [key]: !prev[key] }));
  }

  return (
    <div className={`bg-factory-surface rounded-xl border-2 ${ampel.border} p-6 transition-all`}>

      {/* ── Ampel Badge + Name ── */}
      <div className="flex items-center gap-4 mb-6">
        <div className={`w-16 h-16 rounded-full ${ampel.bg} flex items-center justify-center flex-shrink-0`}
          style={{ boxShadow: `0 0 24px 4px ${ampel.color}30` }}>
          <AmpelIcon size={28} style={{ color: ampel.color }} />
        </div>
        <div className="flex-1 min-w-0">
          <h2 className="text-xl font-bold text-factory-text truncate">{report.name}</h2>
          <div className="flex items-center gap-3 mt-1">
            <span className={`text-2xl font-bold ${ampel.text}`}>{report.total_score}/100</span>
            <span className={`text-xs px-2 py-0.5 rounded-full ${ampel.bg} ${ampel.text} font-medium`}>
              {ampel.label}
            </span>
          </div>
        </div>
      </div>

      {/* ── Hard Blockers ── */}
      {report.hard_blockers && report.hard_blockers.length > 0 && (
        <div className="mb-4 p-3 rounded-lg bg-red-500/10 border border-red-500/30">
          <div className="flex items-center gap-2 mb-1">
            <XCircle size={16} className="text-red-400" />
            <span className="text-sm font-bold text-red-400">Hard Blockers</span>
          </div>
          <ul className="text-xs text-red-300 space-y-0.5 ml-6">
            {report.hard_blockers.map((b, i) => <li key={i}>{b}</li>)}
          </ul>
        </div>
      )}

      {/* ── Soft Blockers ── */}
      {report.soft_blockers && report.soft_blockers.length > 0 && (
        <div className="mb-4 p-3 rounded-lg bg-yellow-500/10 border border-yellow-500/30">
          <div className="flex items-center gap-2 mb-1">
            <AlertTriangle size={16} className="text-yellow-400" />
            <span className="text-sm font-bold text-yellow-400">Einschraenkungen</span>
          </div>
          <ul className="text-xs text-yellow-300 space-y-0.5 ml-6">
            {report.soft_blockers.map((b, i) => <li key={i}>{b}</li>)}
          </ul>
        </div>
      )}

      {/* ── Check List ── */}
      <div className="space-y-1 mb-4">
        {CHECK_META.map(({ key, label, maxScore, Icon }) => {
          const check = checks[key];
          if (!check) return null;
          const score = check.score != null ? check.score : 0;
          const isExpanded = expanded[key];
          const DetailRenderer = DETAIL_RENDERERS[key];

          return (
            <div key={key}>
              <button
                onClick={() => toggleExpand(key)}
                className="w-full flex items-center gap-3 px-3 py-2.5 rounded-lg hover:bg-white/5 transition-colors text-left"
              >
                <Icon size={16} className="text-factory-text-secondary flex-shrink-0" />
                <span className="text-sm text-factory-text flex-1">{label}</span>

                {/* Score bar */}
                <div className="w-24 h-1.5 bg-white/5 rounded-full overflow-hidden flex-shrink-0">
                  <div className="h-full rounded-full transition-all" style={{
                    width: barWidth(score, maxScore),
                    backgroundColor: barColor(score, maxScore),
                  }} />
                </div>

                <span className={`text-xs font-mono w-10 text-right flex-shrink-0 ${scoreColor(score, maxScore)}`}>
                  {score}/{maxScore}
                </span>

                {isExpanded
                  ? <ChevronUp size={14} className="text-factory-text-secondary flex-shrink-0" />
                  : <ChevronDown size={14} className="text-factory-text-secondary flex-shrink-0" />
                }
              </button>

              {isExpanded && DetailRenderer && (
                <div className="ml-9 mr-3 mb-2 pl-3 border-l border-factory-border">
                  <DetailRenderer data={check} />
                </div>
              )}
            </div>
          );
        })}
      </div>

      {/* ── Recommendations ── */}
      {report.recommendations && report.recommendations.length > 0 && (
        <div className="mb-5 px-3">
          <p className="text-xs text-factory-text-secondary font-medium uppercase tracking-wide mb-1.5">Empfehlungen</p>
          <ul className="space-y-1">
            {report.recommendations.map((r, i) => (
              <li key={i} className="text-xs text-factory-text-secondary flex gap-2">
                <span className="text-factory-accent-blue flex-shrink-0">-</span>
                <span>{r}</span>
              </li>
            ))}
          </ul>
        </div>
      )}

      {/* ── Action Buttons ── */}
      <div className="pt-4 border-t border-factory-border">
        {report.ampel === 'GRUEN' && (
          <button
            onClick={() => onApprove && onApprove(report.name)}
            className="w-full flex items-center justify-center gap-2 py-3 px-6 rounded-lg bg-green-500 text-white font-bold hover:bg-green-600 transition-colors"
          >
            <Lock size={16} /> Name bestaetigen & Projekt starten
          </button>
        )}

        {report.ampel === 'GELB' && (
          <div className="flex gap-3">
            <button
              onClick={() => onApprove && onApprove(report.name)}
              className="flex-1 flex items-center justify-center gap-2 py-3 px-4 rounded-lg bg-yellow-500/80 text-white font-bold hover:bg-yellow-500 transition-colors"
            >
              <ArrowRight size={16} /> Trotzdem verwenden
            </button>
            <button
              onClick={() => onRequestAlternatives && onRequestAlternatives()}
              className="flex-1 flex items-center justify-center gap-2 py-3 px-4 rounded-lg bg-factory-accent/20 text-factory-accent font-medium hover:bg-factory-accent/30 transition-colors"
            >
              <Search size={16} /> Alternativen anzeigen
            </button>
          </div>
        )}

        {report.ampel === 'ROT' && (
          <div className="space-y-2">
            <button
              onClick={() => onRequestAlternatives && onRequestAlternatives()}
              className="w-full flex items-center justify-center gap-2 py-3 px-6 rounded-lg bg-factory-accent/20 text-factory-accent font-bold hover:bg-factory-accent/30 transition-colors"
            >
              <Search size={16} /> Alternativen anzeigen
            </button>
            <button
              onClick={() => onForce && onForce(report.name)}
              className="w-full text-center text-xs text-factory-text-secondary hover:text-red-400 transition-colors py-1"
            >
              Trotzdem verwenden (auf eigenes Risiko)
            </button>
          </div>
        )}
      </div>
    </div>
  );
}
