import SwiftUI

struct ReminderListView: View {
    @StateObject var viewModel: ReminderViewModel

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let errorMessage = viewModel.errorMessage {
                ErrorView(message: errorMessage) {
                    Task { await viewModel.loadData() }
                }
            } else {
                contentView
            }
        }
        .navigationTitle("Prüfungsfit bleiben")
        .task {
            await viewModel.loadData()
        }
        .refreshable {
            await viewModel.loadData()
        }
    }

    private var contentView: some View {
        ScrollView {
            VStack(spacing: 16) {
                motivationalCard

                if viewModel.reminders.isEmpty && viewModel.weakTopics.isEmpty {
                    emptyStateView
                } else {
                    remindersSection
                    weakTopicsSection
                }
            }
            .padding()
        }
    }

    private var motivationalCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Dein Fahrlehrer sagt:")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text(viewModel.getMotivationalMessage())
                .font(.body)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }

    private var remindersSection: some View {
        SectionView(title: "Ausstehende Erinnerungen") {
            if viewModel.reminders.isEmpty {
                Text("Keine ausstehenden Erinnerungen")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(viewModel.reminders) { reminder in
                    ReminderCard(reminder: reminder) {
                        Task { await viewModel.completeReminder(reminder) }
                    }
                }
            }
        }
    }

    private var weakTopicsSection: some View {
        SectionView(title: "Deine schwächsten Themen") {
            if viewModel.weakTopics.isEmpty {
                Text("Keine schwachen Themen gefunden")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(viewModel.weakTopics) { topic in
                    WeakTopicCard(topic: topic) {
                        Task { await viewModel.scheduleReminder(for: topic) }
                    }
                }
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.green)

            Text("Alles im grünen Bereich!")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Du hast keine schwachen Themen und keine ausstehenden Erinnerungen.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

private struct ReminderCard: View {
    let reminder: Reminder
    let onComplete: () async -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            priorityIndicator

            VStack(alignment: .leading, spacing: 4) {
                Text(reminder.topicName)
                    .font(.headline)

                Text("\(reminder.questionCount) Fragen • \(reminder.timeRemaining)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if reminder.isOverdue {
                    Text("Überfällig!")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }

            Spacer()

            Button(action: {
                Task { await onComplete() }
            }) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.green)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }

    private var priorityIndicator: some View {
        Circle()
            .fill(Color(reminder.priority.color))
            .frame(width: 12, height: 12)
            .overlay(
                Circle()
                    .stroke(Color(.systemBackground), lineWidth: 2)
            )
    }
}

private struct WeakTopicCard: View {
    let topic: WeakTopic
    let onSchedule: () async -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(topic.topicName)
                        .font(.headline)

                    Spacer()

                    Text("\(topic.missCount)x")
                        .font(.caption)
                        .padding(4)
                        .background(Color.red.opacity(0.2))
                        .cornerRadius(4)
                }

                Text("\(topic.daysSinceMissed) Tage seit letztem Fehler")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                priorityBadge
            }

            Spacer()

            Button(action: {
                Task { await onSchedule() }
            }) {
                Text("Üben")
                    .font(.subheadline)
                    .padding(8)
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }

    private var priorityBadge: some View {
        Text(topic.priority.displayName)
            .font(.caption)
            .padding(4)
            .background(Color(topic.priority.color).opacity(0.2))
            .foregroundStyle(Color(topic.priority.color))
            .cornerRadius(4)
    }
}

private struct SectionView<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            content
        }
    }
}
