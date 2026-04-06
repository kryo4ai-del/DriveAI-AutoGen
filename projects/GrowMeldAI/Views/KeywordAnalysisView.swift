// MARK: - Keyword Analysis View
// File: KeywordAnalysisView.swift
import SwiftUI

/// View for competitive keyword analysis and research
struct KeywordAnalysisView: View {
    @State private var userKeywords: String = ""
    @State private var competitorKeywords: [Competitor] = [
        Competitor(name: "Fahrschule 2024", keywords: "fahrschule, theorie, führerschein, test"),
        Competitor(name: "TheoriePro", keywords: "theorieprüfung, lernen, fragen, test"),
        Competitor(name: "Führerscheinheld", keywords: "führerschein, theorie, prüfung, lernen")
    ]

    @State private var selectedKeyword: String = ""
    @State private var showCompetitorAnalysis: Bool = true

    struct Competitor: Identifiable {
        let id = UUID()
        let name: String
        var keywords: String
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Eigene Keywords")) {
                    TextField("Deine Keywords (kommagetrennt)", text: $userKeywords)
                }

                Section(header: Text("Wettbewerbsanalyse")) {
                    Toggle("Wettbewerbsanalyse anzeigen", isOn: $showCompetitorAnalysis)

                    if showCompetitorAnalysis {
                        ForEach($competitorKeywords) { $competitor in
                            VStack(alignment: .leading) {
                                Text(competitor.name)
                                    .font(.headline)

                                TextField("Keywords", text: $competitor.keywords)

                                Button("Analysieren") {
                                    selectedKeyword = competitor.keywords.components(separatedBy: ", ")
                                        .map { $0.trimmingCharacters(in: .whitespaces) }
                                        .first ?? ""
                                }
                                .font(.caption)
                            }
                        }
                    }
                }

                if !selectedKeyword.isEmpty {
                    Section(header: Text("Keyword-Empfehlungen")) {
                        Text(selectedKeyword)
                            .font(.headline)

                        VStack(alignment: .leading) {
                            Text("📊 Suchvolumen: Hoch")
                            Text("🏆 Wettbewerbsintensität: Mittel")
                            Text("💡 Relevanz für DriveAI: Sehr hoch")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Keyword-Analyse")
        }
    }
}

#Preview {
    KeywordAnalysisView()
}