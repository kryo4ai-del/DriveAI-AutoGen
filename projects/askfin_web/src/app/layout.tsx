import type { Metadata } from 'next'
import './globals.css'

export const metadata: Metadata = {
  title: 'AskFin - Fuehrerschein Trainer',
  description: 'AI-powered coaching for German driving exam',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="de">
      <body>
        <nav className="bg-slate-800 p-4">
          <div className="max-w-6xl mx-auto flex gap-6">
            <a href="/" className="text-white font-bold">AskFin</a>
            <a href="/training" className="text-slate-300 hover:text-white">Training</a>
            <a href="/exam" className="text-slate-300 hover:text-white">Generalprobe</a>
            <a href="/skillmap" className="text-slate-300 hover:text-white">Skill Map</a>
            <a href="/readiness" className="text-slate-300 hover:text-white">Readiness</a>
          </div>
        </nav>
        <main className="max-w-6xl mx-auto p-6">
          {children}
        </main>
      </body>
    </html>
  )
}