import SwiftUI

struct TrafficSignWeaknessView: View {
    @StateObject private var viewModel = TrafficSignWeaknessViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if viewModel.topWeakCategories.isEmpty {
                    emptyState
                } else {
                    weaknessSection
                    allCategoriesSection
                }
            }
            .padding()
        }
        .navigationTitle("Sign Weaknesses")
        .onAppear { viewModel.load() }
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 48))
                .foregroundColor(.green)
            Text("No weak sign categories detected yet.")
                .font(.headline)
            Text("Answer sign questions in Learning Mode to track category accuracy.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }

    // MARK: - Top weak categories

    private var weaknessSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Top Weak Sign Categories")
                .font(.title2)
                .bold()

            ForEach(viewModel.topWeakCategories) { category in
                TrafficSignWeaknessCategoryCard(category: category)
            }
        }
    }

    // MARK: - All categories

    private var allCategoriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("All Categories")
                .font(.title3)
                .bold()

            ForEach(viewModel.allCategories) { category in
                HStack {
                    Text(category.categoryName)
                        .font(.subheadline)
                    Spacer()
                    Text("\(category.accuracyPercentage)%")
                        .font(.subheadline)
                        .foregroundColor(accuracyColor(category.accuracyRate))
                    Text("(\(category.totalAttempts) attempts)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
                Divider()
            }
        }
        .padding(.top, 8)
    }

    private func accuracyColor(_ accuracy: Double) -> Color {
        switch accuracy {
        case 0.75...: return .green
        case 0.50...: return .orange
        default:      return .red
        }
    }
}

// MARK: - Category Card

struct TrafficSignWeaknessCategoryCard: View {
    let category: TrafficSignWeaknessCategory

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(category.categoryName)
                    .font(.headline)
                Spacer()
                Text("\(category.accuracyPercentage)% correct")
                    .font(.subheadline)
                    .foregroundColor(accuracyColor(category.accuracyRate))
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                        .frame(height: 8)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(accuracyColor(category.accuracyRate))
                        .frame(width: geo.size.width * category.accuracyRate, height: 8)
                }
            }
            .frame(height: 8)

            Text("\(category.incorrectCount) of \(category.totalAttempts) incorrect")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }

    private func accuracyColor(_ accuracy: Double) -> Color {
        switch accuracy {
        case 0.75...: return .green
        case 0.50...: return .orange
        default:      return .red
        }
    }
}
