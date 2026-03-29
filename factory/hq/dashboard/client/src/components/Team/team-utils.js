// Tier badge styles
export const TIER_STYLES = {
  premium:     { bg: 'bg-purple-500/20', text: 'text-purple-400', border: 'border-purple-500/30', label: 'Premium' },
  standard:    { bg: 'bg-factory-accent/20', text: 'text-factory-accent', border: 'border-factory-accent/30', label: 'Standard' },
  lightweight: { bg: 'bg-blue-500/20', text: 'text-blue-400', border: 'border-blue-500/30', label: 'Lightweight' },
  none:        { bg: 'bg-factory-border/50', text: 'text-factory-text-secondary', border: 'border-factory-border', label: 'Kein LLM' },
};

// Match quality styles
export const QUALITY_STYLES = {
  perfect: { bg: 'bg-factory-success/20', text: 'text-factory-success', bar: 'bg-factory-success', label: 'Perfekt' },
  good:    { bg: 'bg-factory-accent/20', text: 'text-factory-accent', bar: 'bg-factory-accent', label: 'Gut' },
  partial: { bg: 'bg-factory-warning/20', text: 'text-factory-warning', bar: 'bg-factory-warning', label: 'Teilweise' },
  none:    { bg: 'bg-factory-error/20', text: 'text-factory-error', bar: 'bg-factory-error', label: 'Kein Match' },
  no_llm:  { bg: 'bg-factory-border/50', text: 'text-factory-text-secondary', bar: 'bg-factory-border', label: 'Kein LLM' },
};

// Provider colors
export const PROVIDER_STYLES = {
  anthropic: { color: 'text-orange-400', bar: 'bg-orange-400', label: 'Anthropic' },
  openai:    { color: 'text-green-400', bar: 'bg-green-400', label: 'OpenAI' },
  google:    { color: 'text-blue-400', bar: 'bg-blue-400', label: 'Google' },
  mistral:   { color: 'text-yellow-400', bar: 'bg-yellow-400', label: 'Mistral' },
};

export const STATUS_ICONS = { active: '\u{1F7E2}', disabled: '\u{1F534}', planned: '\u26AB' };

// Capability tag short labels (German)
export const CAP_LABELS = {
  code_generation: 'Code Gen',
  code_review: 'Review',
  swift_code: 'Swift',
  kotlin_code: 'Kotlin',
  typescript_code: 'TypeScript',
  python_code: 'Python',
  csharp_code: 'C#',
  architecture: 'Architektur',
  planning: 'Planung',
  reasoning: 'Reasoning',
  content_creation: 'Content',
  research: 'Research',
  classification: 'Klassifikation',
  summarization: 'Summary',
  extraction: 'Extraktion',
  large_context: 'Large Ctx',
  quality_assurance: 'QA',
};

export const TIER_OPTIONS = ['Alle', 'premium', 'standard', 'lightweight', 'none'];
