// ExamView.swift
import SwiftUI

struct ExamView: View {
    @EnvironmentObject var analyticsService: AnalyticsService

    var body: some View {
        NavigationView {
            VStack {
                Text("Theorieprüfung vorbereiten")
                    .font(.title)
                    .padding()

                ExamCategoryView(category: .basic)
                ExamCategoryView(category: .advanced)

                Spacer()
            }
            .navigationTitle("Prüfung")
            .onAppear {
                analyticsService.logEvent("exam_view_appeared")
            }
        }
    }
}

struct ExamCategoryView: View {
    let category: ExamCategory
    @EnvironmentObject var analyticsService: AnalyticsService

    var body: some View {
        VStack(alignment: .leading) {
            Text(category.title)
                .font(.headline)

            ProgressView(value: 0.75)
                .padding(.vertical, 4)

            Text("75% abgeschlossen")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
        .onTapGesture {
            analyticsService.logEvent("exam_category_tapped", parameters: ["category": category.rawValue])
        }
    }
}

enum ExamCategory: String {
    case basic = "basic"
    case advanced = "advanced"

    var title: String {
        switch self {
        case .basic: return "Grundlagen"
        case .advanced: return "Erweiterte Themen"
        }
    }
}