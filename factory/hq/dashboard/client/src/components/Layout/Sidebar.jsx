import { Rocket, GitBranch, ShieldCheck, FileText, Activity, Wallet, Wrench, Bot, Users, Clock, Eye, Brain, HeartPulse } from 'lucide-react';

const ICON_MAP = {
  Rocket, GitBranch, ShieldCheck, FileText, Activity, Wallet, Wrench, Bot, Users, Clock, Eye, Brain, HeartPulse
};

export default function Sidebar({ sections, active, onSelect }) {
  return (
    <aside className="w-64 bg-factory-surface border-r border-factory-border flex flex-col">
      <div className="p-6 border-b border-factory-border">
        <div className="flex items-center gap-3">
          <img src="/dai-core-logo.png" alt="DAI-Core" className="w-8 h-8" />
          <h1 className="text-xl font-bold text-white">DAI-Core</h1>
        </div>
        <p className="text-sm text-factory-text-secondary mt-1">CEO Cockpit</p>
      </div>

      <nav className="flex-1 py-4">
        {sections.map((section) => {
          const Icon = ICON_MAP[section.icon];
          const isActive = active === section.id;

          return (
            <button
              key={section.id}
              onClick={() => onSelect(section.id)}
              className={`w-full flex items-center gap-3 px-6 py-3 text-left transition-colors ${
                isActive
                  ? 'bg-factory-accent/10 text-factory-accent border-r-2 border-factory-accent'
                  : 'text-factory-text-secondary hover:text-factory-text hover:bg-factory-surface-hover'
              }`}
            >
              {Icon && <Icon size={20} />}
              <span className="text-sm font-medium">{section.label}</span>
              {section.badge > 0 && (
                <span className="ml-auto bg-factory-error text-white text-xs px-2 py-0.5 rounded-full animate-blink-red">
                  {section.badge}
                </span>
              )}
            </button>
          );
        })}
      </nav>

      <div className="p-4 border-t border-factory-border">
        <p className="text-xs text-factory-text-secondary">DAI-Core v1.0</p>
        <p className="text-xs text-factory-text-secondary">100+ Agents &bull; 14 Departments</p>
      </div>
    </aside>
  );
}
