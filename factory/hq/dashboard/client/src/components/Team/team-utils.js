// Team page constants — shared across TeamTable, TeamFilters, TeamSummary, etc.
// Colors are safelisted in tailwind.config.js to prevent purge.

export const STATUS_ICONS = {
  active: '\u{1F7E2}',    // green circle
  disabled: '\u{1F534}',  // red circle
  planned: '\u{1F7E1}',   // yellow circle
};

export const TIER_STYLES = {
  standard: {
    bg: 'bg-blue-500/15',
    text: 'text-blue-400',
    bar: 'bg-blue-500',
    label: 'Standard',
  },
  lightweight: {
    bg: 'bg-teal-500/15',
    text: 'text-teal-400',
    bar: 'bg-teal-500',
    label: 'Lightweight',
  },
  premium: {
    bg: 'bg-purple-500/15',
    text: 'text-purple-400',
    bar: 'bg-purple-500',
    label: 'Premium',
  },
  none: {
    bg: 'bg-gray-500/15',
    text: 'text-gray-400',
    bar: 'bg-gray-500',
    label: 'Kein LLM',
  },
};

export const TIER_OPTIONS = ['Alle', 'standard', 'lightweight', 'premium', 'none'];

export const QUALITY_STYLES = {
  perfect: {
    bg: 'bg-emerald-500/10',
    text: 'text-emerald-400',
    bar: 'bg-emerald-500',
    label: 'Perfect',
  },
  good: {
    bg: 'bg-blue-500/10',
    text: 'text-blue-400',
    bar: 'bg-blue-500',
    label: 'Good',
  },
  partial: {
    bg: 'bg-amber-500/10',
    text: 'text-amber-400',
    bar: 'bg-amber-500',
    label: 'Partial',
  },
  none: {
    bg: 'bg-factory-error/10',
    text: 'text-factory-error',
    bar: 'bg-factory-error',
    label: 'No Match',
  },
  no_llm: {
    bg: 'bg-gray-500/10',
    text: 'text-gray-400',
    bar: 'bg-gray-500',
    label: 'Kein LLM',
  },
};

export const PROVIDER_STYLES = {
  anthropic: { color: 'text-amber-400',  label: 'Anthropic', bar: 'bg-amber-500' },
  openai:    { color: 'text-factory-success', label: 'OpenAI', bar: 'bg-factory-success' },
  mistral:   { color: 'text-orange-400', label: 'Mistral',   bar: 'bg-orange-500' },
  google:    { color: 'text-blue-400',   label: 'Google',    bar: 'bg-blue-500' },
};

export const CAP_LABELS = {
  code_generation: 'Code Gen',
  code_review: 'Code Review',
  architecture: 'Architektur',
  bug_hunting: 'Bug Hunting',
  refactoring: 'Refactoring',
  test_generation: 'Test Gen',
  planning: 'Planung',
  orchestration: 'Orchestrierung',
  content: 'Content',
  compliance: 'Compliance',
  accessibility: 'Accessibility',
  classification: 'Klassifikation',
  summarization: 'Zusammenfassung',
  trend_analysis: 'Trend-Analyse',
  scoring: 'Scoring',
  labeling: 'Labeling',
  extraction: 'Extraktion',
  briefing: 'Briefing',
};
