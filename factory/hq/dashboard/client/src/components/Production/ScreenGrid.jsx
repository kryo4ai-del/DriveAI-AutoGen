import { useState } from 'react';
import { CheckCircle, XCircle, Wrench, Loader } from 'lucide-react';

export default function ScreenGrid({ screens, screensComplete, totalFiles, totalLoc }) {
  const [selectedScreen, setSelectedScreen] = useState(null);

  return (
    <div className="bg-factory-surface rounded-xl border border-factory-border p-5">
      <h3 className="font-semibold text-factory-text mb-3">Screen Progress</h3>

      {/* Grid */}
      <div className="grid gap-1.5" style={{ gridTemplateColumns: 'repeat(auto-fill, minmax(80px, 1fr))' }}>
        {screens.map(screen => (
          <button
            key={screen.id}
            onClick={() => setSelectedScreen(selectedScreen?.id === screen.id ? null : screen)}
            className={`relative rounded-lg p-2 text-center text-xs transition-all border ${
              screen.status === 'completed' ? 'bg-factory-success/10 border-factory-success/30 text-factory-success' :
              screen.status === 'repaired' ? 'bg-factory-success/10 border-factory-success/30 text-factory-success' :
              screen.status === 'in_progress' ? 'bg-factory-warning/10 border-factory-warning/30 text-factory-warning animate-pulse' :
              screen.status === 'error' ? 'bg-factory-error/10 border-factory-error/30 text-factory-error' :
              'bg-factory-bg border-factory-border/50 text-factory-text-secondary'
            } ${selectedScreen?.id === screen.id ? 'ring-1 ring-factory-accent' : 'hover:border-factory-accent/30'}`}
          >
            <div className="font-mono font-bold text-[11px]">{screen.id}</div>
            <div className="mt-0.5 flex items-center justify-center gap-0.5">
              {screen.status === 'completed' && <CheckCircle size={10} />}
              {screen.status === 'repaired' && <><CheckCircle size={10} /><Wrench size={8} className="ml-0.5" /></>}
              {screen.status === 'in_progress' && <Loader size={10} className="animate-spin" />}
              {screen.status === 'error' && <XCircle size={10} />}
              {screen.loc > 0 && <span className="text-[9px] ml-0.5">{screen.loc}</span>}
            </div>
          </button>
        ))}
      </div>

      {/* Summary Line */}
      <p className="text-xs text-factory-text-secondary mt-3">
        {screensComplete}/{screens.length} Screens fertig
        {totalFiles > 0 && <> &middot; {totalFiles} Dateien</>}
        {totalLoc > 0 && <> &middot; {totalLoc.toLocaleString()} LOC</>}
      </p>

      {/* Detail Popup */}
      {selectedScreen && (
        <div className="mt-3 p-3 bg-factory-bg rounded-lg border border-factory-border">
          <div className="flex items-center justify-between mb-2">
            <span className="font-mono font-bold text-factory-text">{selectedScreen.id}</span>
            <span className={`text-xs px-2 py-0.5 rounded-full ${
              selectedScreen.status === 'completed' || selectedScreen.status === 'repaired'
                ? 'bg-factory-success/20 text-factory-success'
                : selectedScreen.status === 'error'
                  ? 'bg-factory-error/20 text-factory-error'
                  : selectedScreen.status === 'in_progress'
                    ? 'bg-factory-warning/20 text-factory-warning'
                    : 'bg-factory-border text-factory-text-secondary'
            }`}>
              {selectedScreen.status === 'completed' ? 'Fertig' :
               selectedScreen.status === 'repaired' ? 'Repariert' :
               selectedScreen.status === 'in_progress' ? 'In Arbeit' :
               selectedScreen.status === 'error' ? 'Fehler' : 'Wartend'}
            </span>
          </div>
          <div className="grid grid-cols-3 gap-3 text-xs">
            <div>
              <p className="text-factory-text-secondary">Agent</p>
              <p className="text-factory-text font-medium">{selectedScreen.agent || '\u2014'}</p>
            </div>
            <div>
              <p className="text-factory-text-secondary">LOC</p>
              <p className="text-factory-text font-medium">{selectedScreen.loc || '\u2014'}</p>
            </div>
            <div>
              <p className="text-factory-text-secondary">Kosten</p>
              <p className="text-factory-text font-medium">
                {selectedScreen.cost > 0 ? `$${selectedScreen.cost.toFixed(3)}` : '\u2014'}
              </p>
            </div>
            <div>
              <p className="text-factory-text-secondary">Dauer</p>
              <p className="text-factory-text font-medium">
                {selectedScreen.duration > 0 ? `${selectedScreen.duration.toFixed(1)}s` : '\u2014'}
              </p>
            </div>
            <div>
              <p className="text-factory-text-secondary">Dateien</p>
              <p className="text-factory-text font-medium">{selectedScreen.files || '\u2014'}</p>
            </div>
            <div>
              <p className="text-factory-text-secondary">Reparaturen</p>
              <p className="text-factory-text font-medium">{selectedScreen.repairs || 0}</p>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
