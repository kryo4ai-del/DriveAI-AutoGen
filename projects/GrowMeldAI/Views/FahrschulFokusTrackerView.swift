// FahrschulFokusTrackerView.swift
import SwiftUI

struct FahrschulFokusTrackerView: View {
    @StateObject private var viewModel: FahrschulFokusTrackerViewModel
    @State private var showingResetAlert = false

    init(viewModel: FahrschulFokusTrackerViewModel = FahrschulFokusTrackerViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Lade Themen...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = viewModel.error {
                    ErrorView(error: error, retryAction: viewModel.loadTopics)
                } else {
                    contentView
                }
            }
            .navigationTitle("Fahrschul-Fokus-Tracker")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingResetAlert = true }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .alert("Themen zurücksetzen?", isPresented: $showingResetAlert) {
                Button("Abbrechen", role: .cancel) { }
                Button("Zurücksetzen", role: .destructive) {
                    viewModel.resetAllTopics()
                }
            } message: {
                Text("Möchtest du wirklich alle Themen zurücksetzen? Dein Fortschritt geht dabei verloren.")
            }
        }
    }

    private var contentView: some View {
        ScrollView {
            VStack(spacing: 24) {
                progressHeader
                topicsGrid
            }
            .padding()
        }
    }

    private var progressHeader: some View {
        VStack(spacing: 16) {
            ProgressCircleView(progress: viewModel.model.completionPercentage)
                .frame(width: 120, height: 120)

            Text("Fortschritt")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text("\(viewModel.model.completedTopics)/\(viewModel.model.totalTopics) Themen gemeistert")
                .font(.title2.bold())
        }
        .frame(maxWidth: .infinity)
    }

    private var topicsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible())], spacing: 16) {
            ForEach(viewModel.model.topics) { topic in
                TopicCardView(topic: topic) {
                    let nextLevel: ExamTopic.MasteryLevel
                    switch topic.masteryLevel {
                    case .notStarted: nextLevel = .inProgress
                    case .inProgress: nextLevel = .reviewed
                    case .reviewed: nextLevel = .mastered
                    case .mastered: nextLevel = .notStarted
                    }

                    viewModel.updateMasteryLevel(for: topic.id, newLevel: nextLevel)
                }
            }
        }
    }
}

private struct ProgressCircleView: View {
    let progress: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 8)
                .opacity(0.3)
                .foregroundStyle(Color.blue.opacity(0.3))

            Circle()
                .trim(from: 0, to: progress)
                .stroke(style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .foregroundStyle(Color.blue)
                .rotationEffect(.degrees(-90))

            VStack {
                Text("\(Int(progress * 100))%")
                    .font(.headline)
                Text("Fertig")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private struct TopicCardView: View {
    let topic: ExamTopic
    let action: () -> Void

    private var backgroundColor: Color {
        switch topic.masteryLevel {
        case .notStarted: return .gray.opacity(0.2)
        case .inProgress: return .yellow.opacity(0.3)
        case .reviewed: return .orange.opacity(0.3)
        case .mastered: return .green.opacity(0.3)
        }
    }

    private var iconName: String {
        switch topic.masteryLevel {
        case .notStarted: return "circle"
        case .inProgress: return "arrow.trianglehead.counterclockwise"
        case .reviewed: return "arrow.clockwise"
        case .mastered: return "checkmark.circle.fill"
        }
    }

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(topic.title)
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Image(systemName: iconName)
                        .foregroundStyle(
                            topic.masteryLevel == .mastered ? .green :
                            topic.masteryLevel == .inProgress ? .yellow :
                            topic.masteryLevel == .reviewed ? .orange : .gray
                        )
                }

                Text(topic.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                Spacer()

                HStack {
                    Text(topic.category.rawValue)
                        .font(.caption)
                        .padding(4)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(4)

                    Spacer()

                    Text(topic.difficulty.rawValue.capitalized)
                        .font(.caption)
                        .padding(4)
                        .background(
                            topic.difficulty == .beginner ? Color.green.opacity(0.2) :
                            topic.difficulty == .intermediate ? Color.yellow.opacity(0.2) :
                            Color.red.opacity(0.2)
                        )
                        .cornerRadius(4)
                }
            }
            .padding()
        }
        .buttonStyle(CardButtonStyle())
        .background(backgroundColor)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

private struct CardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}
