import { useState, useEffect } from 'react';
import Sidebar from './components/Layout/Sidebar';
import Header from './components/Layout/Header';
import ProjectGrid from './components/Pipeline/ProjectGrid';
import ProjectDetail from './components/Pipeline/ProjectDetail';
import GateInbox from './components/Gates/GateInbox';
import DocumentLibrary from './components/Documents/DocumentLibrary';
import HealthOverview from './components/FactoryStatus/HealthOverview';
import AgentMonitor from './components/AgentMonitor/AgentMonitor';
import ProjectHistory from './components/History/ProjectHistory';
import ShowcaseView from './components/Showcase/ShowcaseView';
import StartView from './components/Start/StartView';
import ChatPanel from './components/Assistant/ChatPanel';
import TeamView from './components/Team/TeamView';
import ProviderView from './components/Provider/ProviderView';
import JanitorView from './components/Janitor/JanitorView';
import BrainView from './components/Brain/BrainView';
import AppFleetOverview from './components/LiveOps/AppFleetOverview';
import AppDetailView from './components/LiveOps/AppDetailView';
import ProductionDashboard from './components/Production/ProductionDashboard';
import MarketingView from './components/Marketing/MarketingView';

const BASE_SECTIONS = [
  { id: 'start', label: 'Start', icon: 'Rocket' },
  { id: 'pipeline', label: 'Pipeline', icon: 'GitBranch' },
  { id: 'gates', label: 'Gates', icon: 'ShieldCheck', badge: 0 },
  { id: 'documents', label: 'Dokumente', icon: 'FileText' },
  { id: 'factory', label: 'Factory Status', icon: 'Activity' },
  { id: 'brain', label: 'TheBrain', icon: 'Brain' },
  { id: 'providers', label: 'Provider', icon: 'Wallet' },
  { id: 'janitor', label: 'Janitor', icon: 'Wrench', badge: 0 },
  { id: 'agents', label: 'Agent Monitor', icon: 'Bot' },
  { id: 'team', label: 'Team', icon: 'Users' },
  { id: 'history', label: 'Historie', icon: 'Clock' },
  { id: 'showcase', label: 'Schaufenster', icon: 'Eye' },
  { id: 'liveops', label: 'Live Operations', icon: 'HeartPulse' },
  { id: 'marketing', label: 'Marketing', icon: 'Megaphone' },
];

export default function App() {
  const [activeSection, setActiveSection] = useState('start');
  const [selectedProject, setSelectedProject] = useState(null);
  const [selectedApp, setSelectedApp] = useState(null);
  const [productionSlug, setProductionSlug] = useState(null);
  const [gateCount, setGateCount] = useState(0);
  const [janitorProposals, setJanitorProposals] = useState(0);
  const [chatOpen, setChatOpen] = useState(false);

  // Keyboard shortcuts
  useEffect(() => {
    function handleKeyboard(e) {
      // Ctrl+K / Cmd+K: Toggle chat
      if ((e.ctrlKey || e.metaKey) && e.key === 'k') {
        e.preventDefault();
        setChatOpen(prev => !prev);
      }
      // Escape: Close chat
      if (e.key === 'Escape' && chatOpen) {
        setChatOpen(false);
      }
    }
    window.addEventListener('keydown', handleKeyboard);
    return () => window.removeEventListener('keydown', handleKeyboard);
  }, [chatOpen]);

  useEffect(() => {
    async function fetchCounts() {
      try {
        const [gatesRes, janitorRes] = await Promise.all([
          fetch('/api/gates'),
          fetch('/api/janitor/proposals').catch(() => ({ json: () => ({ proposals: [] }) })),
        ]);
        const gates = await gatesRes.json();
        setGateCount(gates.count || 0);
        const janitor = await janitorRes.json();
        setJanitorProposals((janitor.proposals || []).filter(p => p.status === 'pending').length);
      } catch (err) { /* ignore */ }
    }
    fetchCounts();
    const interval = setInterval(fetchCounts, 15000);
    return () => clearInterval(interval);
  }, []);

  const sections = BASE_SECTIONS.map(s => {
    if (s.id === 'gates') return { ...s, badge: gateCount };
    if (s.id === 'janitor') return { ...s, badge: janitorProposals };
    return s;
  });

  function handleSelectSection(section) {
    setActiveSection(section);
    setSelectedProject(null);
    setSelectedApp(null);
    setProductionSlug(null);
  }

  return (
    <div className="flex h-screen bg-factory-bg">
      <Sidebar
        sections={sections}
        active={activeSection}
        onSelect={handleSelectSection}
      />
      <div className="flex-1 flex flex-col overflow-hidden">
        <Header activeSection={activeSection} onToggleChat={() => setChatOpen(!chatOpen)} chatOpen={chatOpen} />
        <main className="flex-1 overflow-y-auto p-6">
          {productionSlug ? (
            <ProductionDashboard slug={productionSlug} onBack={() => setProductionSlug(null)} />
          ) : (
            <>
              {activeSection === 'start' && <StartView />}
              {activeSection === 'pipeline' && !selectedProject && (
                <ProjectGrid onSelectProject={setSelectedProject} />
              )}
              {activeSection === 'pipeline' && selectedProject && (
                <ProjectDetail projectId={selectedProject} onBack={() => setSelectedProject(null)} onNavigateToProduction={setProductionSlug} />
              )}
              {activeSection === 'gates' && <GateInbox onNavigateToProduction={setProductionSlug} />}
              {activeSection === 'documents' && <DocumentLibrary />}
              {activeSection === 'factory' && <HealthOverview />}
              {activeSection === 'brain' && <BrainView />}
              {activeSection === 'providers' && <ProviderView />}
              {activeSection === 'janitor' && <JanitorView />}
              {activeSection === 'agents' && <AgentMonitor />}
              {activeSection === 'team' && <TeamView />}
              {activeSection === 'history' && <ProjectHistory />}
              {activeSection === 'showcase' && <ShowcaseView />}
              {activeSection === 'liveops' && !selectedApp && (
                <AppFleetOverview onSelectApp={setSelectedApp} />
              )}
              {activeSection === 'liveops' && selectedApp && (
                <AppDetailView appId={selectedApp} onBack={() => setSelectedApp(null)} />
              )}
              {activeSection === 'marketing' && <MarketingView />}
              {!['start', 'pipeline', 'gates', 'documents', 'factory', 'brain', 'providers', 'janitor', 'agents', 'team', 'history', 'showcase', 'liveops', 'marketing'].includes(activeSection) && (
                <PlaceholderView
                  title={sections.find(s => s.id === activeSection)?.label || ''}
                  description="Wird in einem zukuenftigen Step implementiert"
                />
              )}
            </>
          )}
        </main>
      </div>
      <ChatPanel isOpen={chatOpen} onClose={() => setChatOpen(false)} />
    </div>
  );
}

function PlaceholderView({ title, description }) {
  return (
    <div className="flex items-center justify-center h-full">
      <div className="text-center">
        <h2 className="text-2xl font-bold text-factory-text mb-2">{title}</h2>
        <p className="text-factory-text-secondary">{description}</p>
      </div>
    </div>
  );
}
