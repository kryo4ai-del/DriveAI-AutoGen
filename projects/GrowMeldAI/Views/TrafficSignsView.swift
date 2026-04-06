// File: Views/TrafficSignsView.swift
import SwiftUI

struct TrafficSignsView: View {
    @StateObject private var viewModel = TrafficSignViewModel()
    @State private var showingFilterSheet = false

    var body: some View {
        NavigationStack {
            List(viewModel.filteredSigns) { sign in
                TrafficSignRow(sign: sign)
            }
            .navigationTitle("Traffic Signs")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingFilterSheet.toggle() }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .sheet(isPresented: $showingFilterSheet) {
                TrafficSignFiltersView(viewModel: viewModel)
                    .presentationDetents([.medium])
            }
        }
    }
}

struct TrafficSignRow: View {
    let sign: TrafficSign

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if let imageName = sign.imageName {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .foregroundColor(sign.isWarning ? .orange : .blue)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("\(sign.signNumber) - \(sign.name)")
                    .font(.headline)
                Text(sign.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                HStack {
                    Text(sign.category.rawValue)
                        .font(.caption)
                        .padding(4)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(4)
                    Text(sign.difficulty.displayName)
                        .font(.caption)
                        .padding(4)
                        .background(difficultyColor)
                        .cornerRadius(4)
                }
            }
        }
        .padding(.vertical, 8)
    }

    private var difficultyColor: Color {
        switch sign.difficulty {
        case .beginner: return .green
        case .intermediate: return .yellow
        case .advanced: return .red
        }
    }
}