const SECTION_TITLES = {
  start: 'Neues Projekt starten',
  pipeline: 'Projekt-Pipeline',
  gates: 'CEO Gates',
  documents: 'Dokumente',
  factory: 'Factory Status',
  providers: 'Provider Balance',
  janitor: 'Factory Janitor',
  agents: 'Agent Monitor',
  team: 'Team',
  history: 'Projekt-Historie',
  showcase: 'Schaufenster',
};

import { MessageCircle } from 'lucide-react';

export default function Header({ activeSection, onToggleChat, chatOpen }) {
  return (
    <header className="h-16 bg-factory-surface border-b border-factory-border flex items-center justify-between px-6">
      <h2 className="text-lg font-semibold text-factory-text">
        {SECTION_TITLES[activeSection] || activeSection}
      </h2>
      <div className="flex items-center gap-4">
        <div className="flex items-center gap-2">
          <div className="w-2.5 h-2.5 rounded-full bg-factory-success"></div>
          <span className="text-sm text-factory-text-secondary">DAI-Core Online</span>
        </div>
        <button
          onClick={onToggleChat}
          className={`flex items-center gap-2 px-3 py-1.5 rounded-lg text-sm transition-colors ${
            chatOpen
              ? 'bg-factory-accent text-factory-bg'
              : 'bg-factory-bg text-factory-text-secondary hover:text-factory-accent hover:bg-factory-accent/10'
          }`}
        >
          <MessageCircle size={16} />
          Assistant
        </button>
      </div>
    </header>
  );
}
