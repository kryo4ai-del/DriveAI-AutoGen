// CategoryBrowserView.swift
import SwiftUI

struct CategoryBrowserView: View {
    @EnvironmentObject var appState: AppState

    let categories: [Category] = [
        .init(id: "traffic_signs", name: "Traffic Signs", icon: "signpost.right"),
        .init(id: "rules_of_the_road", name: "Rules of the Road", icon: "road.lanes"),
        .init(id: "hazard_recognition", name: "Hazard Recognition", icon: "exclamationmark.triangle"),
        .init(id: "road_conditions", name: "Road Conditions", icon: "road.highway")
    ]

    var body: some View {
        List(categories) { category in
            NavigationLink {
                QuestionListView(category: category)
            } label: {
                CategoryRow(category: category)
            }
        }
        .navigationTitle("Categories")
    }
}

private struct CategoryRow: View {
    let category: Category

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: category.icon)
                .frame(width: 24, height: 24)
                .foregroundColor(.accentColor)

            Text(category.name)
                .font(.headline)

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        CategoryBrowserView()
            .environmentObject(AppState())
    }
}