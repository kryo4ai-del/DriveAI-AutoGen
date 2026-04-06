// File: Views/TrafficSignFiltersView.swift
import SwiftUI

struct TrafficSignFiltersView: View {
    @ObservedObject var viewModel: TrafficSignViewModel

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Category")) {
                    Picker("Category", selection: $viewModel.selectedCategory) {
                        Text("All Categories").tag(nil as TrafficSignCategory?)
                        ForEach(viewModel.categories, id: \.self) { category in
                            Text(category.rawValue).tag(category as TrafficSignCategory?)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section(header: Text("Difficulty")) {
                    Picker("Difficulty", selection: $viewModel.selectedDifficulty) {
                        Text("All Levels").tag(nil as DifficultyLevel?)
                        ForEach(viewModel.difficultyLevels, id: \.self) { level in
                            Text(level.displayName).tag(level as DifficultyLevel?)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section {
                    TextField("Search signs...", text: $viewModel.searchText)
                        .textFieldStyle(.roundedBorder)
                }
            }
            .navigationTitle("Filter Traffic Signs")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Reset") {
                        viewModel.resetFilters()
                    }
                }
            }
        }
    }
}