const SECTION_TITLES = {
  pipeline: 'Projekt-Pipeline',
  gates: 'CEO Gates',
  documents: 'Dokumente',
  factory: 'Factory Status',
  agents: 'Agent Monitor',
  history: 'Projekt-Historie',
  showcase: 'Schaufenster',
};

export default function Header({ activeSection }) {
  return (
    <header className="h-16 bg-factory-surface border-b border-factory-border flex items-center justify-between px-6">
      <h2 className="text-lg font-semibold text-factory-text">
        {SECTION_TITLES[activeSection] || activeSection}
      </h2>
      <div className="flex items-center gap-4">
        <div className="flex items-center gap-2">
          <div className="w-2.5 h-2.5 rounded-full bg-factory-success"></div>
          <span className="text-sm text-factory-text-secondary">Factory Online</span>
        </div>
      </div>
    </header>
  );
}
