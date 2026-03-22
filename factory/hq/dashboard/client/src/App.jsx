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

const BASE_SECTIONS = [
  { id: 'pipeline', label: 'Pipeline', icon: 'GitBranch' },
  { id: 'gates', label: 'Gates', icon: 'ShieldCheck', badge: 0 },
  { id: 'documents', label: 'Dokumente', icon: 'FileText' },
  { id: 'factory', label: 'Factory Status', icon: 'Activity' },
  { id: 'agents', label: 'Agent Monitor', icon: 'Bot' },
  { id: 'history', label: 'Historie', icon: 'Clock' },
  { id: 'showcase', label: 'Schaufenster', icon: 'Eye' },
];

export default function App() {
  const [activeSection, setActiveSection] = useState('pipeline');
  const [selectedProject, setSelectedProject] = useState(null);
  const [gateCount, setGateCount] = useState(0);

  useEffect(() => {
    async function fetchGateCount() {
      try {
        const res = await fetch('/api/gates');
        const data = await res.json();
        setGateCount(data.count || 0);
      } catch (err) { /* ignore */ }
    }
    fetchGateCount();
    const interval = setInterval(fetchGateCount, 15000);
    return () => clearInterval(interval);
  }, []);

  const sections = BASE_SECTIONS.map(s =>
    s.id === 'gates' ? { ...s, badge: gateCount } : s
  );

  function handleSelectSection(section) {
    setActiveSection(section);
    setSelectedProject(null);
  }

  return (
    <div className="flex h-screen bg-factory-bg">
      <Sidebar
        sections={sections}
        active={activeSection}
        onSelect={handleSelectSection}
      />
      <div className="flex-1 flex flex-col overflow-hidden">
        <Header activeSection={activeSection} />
        <main className="flex-1 overflow-y-auto p-6">
          {activeSection === 'pipeline' && !selectedProject && (
            <ProjectGrid onSelectProject={setSelectedProject} />
          )}
          {activeSection === 'pipeline' && selectedProject && (
            <ProjectDetail projectId={selectedProject} onBack={() => setSelectedProject(null)} />
          )}
          {activeSection === 'gates' && <GateInbox />}
          {activeSection === 'documents' && <DocumentLibrary />}
          {activeSection === 'factory' && <HealthOverview />}
          {activeSection === 'agents' && <AgentMonitor />}
          {activeSection === 'history' && <ProjectHistory />}
          {activeSection === 'showcase' && <ShowcaseView />}
          {!['pipeline', 'gates', 'documents', 'factory', 'agents', 'history', 'showcase'].includes(activeSection) && (
            <PlaceholderView
              title={sections.find(s => s.id === activeSection)?.label || ''}
              description="Wird in einem zukuenftigen Step implementiert"
            />
          )}
        </main>
      </div>
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
