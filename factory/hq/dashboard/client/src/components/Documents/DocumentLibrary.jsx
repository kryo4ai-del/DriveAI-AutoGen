import { useState, useEffect } from 'react';
import { FileText, File, ChevronRight, ArrowLeft, ExternalLink } from 'lucide-react';

export default function DocumentLibrary() {
  const [projects, setProjects] = useState([]);
  const [selectedProject, setSelectedProject] = useState(null);
  const [viewingDoc, setViewingDoc] = useState(null);

  useEffect(() => {
    fetch('/api/projects?type=all&archived=false')
      .then(r => r.json())
      .then(data => setProjects(data.projects || []));
  }, []);

  if (viewingDoc) {
    return <DocumentViewer doc={viewingDoc} onBack={() => setViewingDoc(null)} />;
  }

  return (
    <div className="flex gap-6 h-full">
      {/* Left: Project List */}
      <div className="w-64 flex-shrink-0">
        <h3 className="text-sm font-medium text-factory-text-secondary mb-3">Projekt</h3>
        <div className="space-y-1">
          {projects.map(p => (
            <button
              key={p.project_id}
              onClick={() => { setSelectedProject(p.project_id); setViewingDoc(null); }}
              className={`w-full text-left px-4 py-3 rounded-lg transition-colors ${
                selectedProject === p.project_id
                  ? 'bg-factory-accent/10 text-factory-accent'
                  : 'text-factory-text-secondary hover:text-factory-text hover:bg-factory-surface'
              }`}
            >
              <p className="font-medium text-sm">{p.title}</p>
              <p className="text-xs mt-0.5 opacity-60">{p.current_phase}</p>
            </button>
          ))}
        </div>
      </div>

      {/* Right: Document Panel — key forces COMPLETE re-mount on project switch */}
      <div className="flex-1 overflow-y-auto">
        {!selectedProject && (
          <div className="flex items-center justify-center h-64 text-factory-text-secondary">
            Projekt auswaehlen um Dokumente zu sehen
          </div>
        )}
        {selectedProject && (
          <DocumentPanel
            key={selectedProject}
            projectId={selectedProject}
            onViewDoc={(file) => setViewingDoc({ ...file, projectId: selectedProject })}
          />
        )}
      </div>
    </div>
  );
}

/**
 * Isolated component with its OWN state.
 * key={selectedProject} on the parent ensures this is completely
 * destroyed and recreated when the project changes — no stale data.
 */
function DocumentPanel({ projectId, onViewDoc }) {
  const [documents, setDocuments] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let cancelled = false;
    setLoading(true);
    setDocuments(null);
    fetch(`/api/documents/${projectId}`)
      .then(r => r.json())
      .then(data => {
        if (!cancelled) {
          setDocuments(data);
          setLoading(false);
        }
      })
      .catch(() => {
        if (!cancelled) setLoading(false);
      });
    return () => { cancelled = true; };
  }, [projectId]);

  if (loading) {
    return <div className="text-factory-text-secondary p-4">Lade Dokumente...</div>;
  }

  if (!documents || documents.total === 0) {
    return <div className="text-factory-text-secondary p-4">Keine Dokumente gefunden</div>;
  }

  return (
    <div>
      <p className="text-factory-text-secondary mb-4">{documents.total} Dokumente</p>
      {documents.categories.map(cat => (
        <div key={cat.key} className="mb-6">
          <h3 className="text-xs font-medium text-factory-text-secondary mb-2 uppercase tracking-wider">
            {cat.label}
          </h3>
          <div className="space-y-1">
            {cat.files.map(file => (
              <button
                key={file.name}
                onClick={() => {
                  if (file.type === 'pdf') {
                    window.open(`/api/documents/${projectId}/view/${file.chapter}/${file.name}`, '_blank');
                  } else {
                    onViewDoc(file);
                  }
                }}
                className="w-full flex items-center gap-3 px-4 py-3 rounded-lg bg-factory-surface hover:bg-factory-surface-hover transition-colors group"
              >
                {file.type === 'pdf'
                  ? <File size={16} className="text-factory-error flex-shrink-0" />
                  : <FileText size={16} className="text-factory-accent-blue flex-shrink-0" />
                }
                <div className="flex-1 text-left min-w-0">
                  <p className="text-sm text-factory-text group-hover:text-factory-accent truncate">
                    {file.display_name}
                  </p>
                </div>
                <span className="text-xs text-factory-text-secondary flex-shrink-0">{file.size_kb} KB</span>
                <span className="text-xs text-factory-text-secondary flex-shrink-0">{file.modified}</span>
                {file.type === 'pdf'
                  ? <ExternalLink size={14} className="text-factory-text-secondary flex-shrink-0" />
                  : <ChevronRight size={14} className="text-factory-text-secondary flex-shrink-0" />
                }
              </button>
            ))}
          </div>
        </div>
      ))}
    </div>
  );
}

function DocumentViewer({ doc, onBack }) {
  const [content, setContent] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetch(`/api/documents/${doc.projectId}/view/${doc.chapter}/${doc.name}`)
      .then(r => r.json())
      .then(data => setContent(data.content))
      .catch(err => setContent('Fehler beim Laden: ' + err.message))
      .finally(() => setLoading(false));
  }, [doc]);

  return (
    <div className="h-full flex flex-col">
      <div className="flex items-center gap-4 mb-4 pb-4 border-b border-factory-border">
        <button onClick={onBack} className="text-factory-text-secondary hover:text-factory-text">
          <ArrowLeft size={20} />
        </button>
        <div>
          <h2 className="text-lg font-semibold text-factory-text">{doc.display_name}</h2>
          <p className="text-sm text-factory-text-secondary">{doc.chapter_label} — {doc.size_kb} KB</p>
        </div>
      </div>

      <div className="flex-1 overflow-y-auto">
        {loading ? (
          <p className="text-factory-text-secondary">Lade Dokument...</p>
        ) : (
          <div className="bg-factory-surface rounded-xl border border-factory-border p-6">
            <pre className="text-sm text-factory-text whitespace-pre-wrap font-mono leading-relaxed">
              {content}
            </pre>
          </div>
        )}
      </div>
    </div>
  );
}
