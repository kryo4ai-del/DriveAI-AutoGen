export default function Home() {
  return (
    <div className="space-y-8">
      <h1 className="text-4xl font-bold text-white">AskFin</h1>
      <p className="text-slate-300 text-lg">Dein Weg zum Fuehrerschein</p>
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <a href="/training" className="bg-slate-800 rounded-xl p-6 hover:bg-slate-700 transition">
          <h2 className="text-xl font-semibold text-white">Taegliches Training</h2>
          <p className="text-slate-400 mt-2">Adaptives Fragentraining</p>
        </a>
        <a href="/exam" className="bg-slate-800 rounded-xl p-6 hover:bg-slate-700 transition">
          <h2 className="text-xl font-semibold text-white">Generalprobe</h2>
          <p className="text-slate-400 mt-2">30-Fragen Pruefungssimulation</p>
        </a>
        <a href="/skillmap" className="bg-slate-800 rounded-xl p-6 hover:bg-slate-700 transition">
          <h2 className="text-xl font-semibold text-white">Skill Map</h2>
          <p className="text-slate-400 mt-2">Kompetenz pro Kategorie</p>
        </a>
        <a href="/readiness" className="bg-slate-800 rounded-xl p-6 hover:bg-slate-700 transition">
          <h2 className="text-xl font-semibold text-white">Readiness Score</h2>
          <p className="text-slate-400 mt-2">0-100% Pruefungsbereitschaft</p>
        </a>
      </div>
    </div>
  )
}