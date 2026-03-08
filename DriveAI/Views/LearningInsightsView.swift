import SwiftUI

struct LearningInsightsView: View {
    @StateObject private var viewModel = LearningInsightsViewModel()

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
        .navigationTitle("Learning Insights")
        .onAppear { viewModel.load() }
    }

    // MARK: - Sections

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 48))
                .foregroundColor(.green)
            Text("No weak areas detected yet.")
                .font(.headline)
            Text("Answer more questions to see your learning patterns.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }

    private var weaknessSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Top Weak Areas")
                .font(.title2)
                .bold()

            ForEach(viewModel.topWeakCategories) { category in
                WeaknessCategoryCard(category: category)
            }
        }
    }

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
                        .foregroundColor(accuracyColor(category.accuracy))
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

struct WeaknessCategoryCard: View {
    let category: WeaknessCategory

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(category.categoryName)
                    .font(.headline)
                Spacer()
                Text("\(category.accuracyPercentage)% correct")
                    .font(.subheadline)
                    .foregroundColor(accuracyColor(category.accuracy))
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                        .frame(height: 8)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(accuracyColor(category.accuracy))
                        .frame(width: geo.size.width * category.accuracy, height: 8)
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
