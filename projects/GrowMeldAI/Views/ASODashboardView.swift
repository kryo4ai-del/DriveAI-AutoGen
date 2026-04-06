// MARK: - ASO Dashboard View
// File: ASODashboardView.swift
import SwiftUI

/// Main dashboard for managing all ASO-related tasks
struct ASODashboardView: View {
    @State private var selectedTab: Tab = .metadata

    enum Tab {
        case metadata
        case screenshots
        case keywords
        case compliance
        case preview
    }

    var body: some View {
        NavigationStack {
            TabView(selection: $selectedTab) {
                ASOMetadataView()
                    .tabItem {
                        Label("Metadaten", systemImage: "doc.text")
                    }
                    .tag(Tab.metadata)

                ScreenshotSequenceView()
                    .tabItem {
                        Label("Screenshots", systemImage: "photo.on.rectangle")
                    }
                    .tag(Tab.screenshots)

                KeywordAnalysisView()
                    .tabItem {
                        Label("Keywords", systemImage: "magnifyingglass")
                    }
                    .tag(Tab.keywords)

                ComplianceChecklistView()
                    .tabItem {
                        Label("Compliance", systemImage: "checkmark.shield")
                    }
                    .tag(Tab.compliance)

                LocalizationPreviewView()
                    .tabItem {
                        Label("Vorschau", systemImage: "eye")
                    }
                    .tag(Tab.preview)
            }
            .navigationTitle("DriveAI ASO")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ASODashboardView()
}