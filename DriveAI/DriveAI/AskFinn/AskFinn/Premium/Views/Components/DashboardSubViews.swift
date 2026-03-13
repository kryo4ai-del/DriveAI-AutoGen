import SwiftUI

// MARK: - ExamStartModal

struct ExamStartModal: View {
    @Binding var isPresented: Bool
    let onStartExam: (TimeInterval) -> Void

    var body: some View {
        VStack(spacing: 24) {
            Text("Prüfungssimulation starten")
                .font(.title2.bold())

            Text("Wähle die Dauer deiner Simulation:")
                .foregroundColor(.secondary)

            VStack(spacing: 12) {
                durationButton(minutes: 30)
                durationButton(minutes: 45)
                durationButton(minutes: 60)
            }

            Button("Abbrechen") {
                isPresented = false
            }
            .foregroundColor(.secondary)
        }
        .padding(24)
    }

    private func durationButton(minutes: Int) -> some View {
        Button {
            onStartExam(TimeInterval(minutes * 60))
        } label: {
            Text("\(minutes) Minuten")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
    }
}

// MARK: - CategoryDetailView

struct CategoryDetailView: View {
    let category: String

    var body: some View {
        VStack(spacing: 16) {
            Text(category)
                .font(.title2.bold())
            Text("Kategorie-Details werden geladen...")
                .foregroundColor(.secondary)
        }
        .navigationTitle(category)
    }
}

// MARK: - DashboardLoadingView

struct DashboardLoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Dashboard wird geladen...")
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - DashboardErrorView

struct DashboardErrorView: View {
    let message: String
    let retryAction: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundColor(.orange)

            Text("Fehler")
                .font(.title2.bold())

            Text(message)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button("Erneut versuchen", action: retryAction)
                .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

// MARK: - ResumableQuizCard

struct ResumableQuizCard: View {
    let quiz: QuizSession
    let onResume: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Fortsetzen")
                    .font(.caption.bold())
                    .foregroundColor(.accentColor)
                Text(quiz.categoryName)
                    .font(.subheadline.bold())
                ProgressView(value: quiz.progress)
                    .frame(height: 4)
            }

            Spacer()

            Button("Weiter", action: onResume)
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - QuickActionButtons

struct QuickActionButtons: View {
    let onStartExam: () -> Void
    let onBrowseCategories: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onStartExam) {
                Label("Prüfung starten", systemImage: "clock.badge.checkmark")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            Button(action: onBrowseCategories) {
                Label("Kategorien", systemImage: "square.grid.2x2")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray5))
                    .foregroundColor(.primary)
                    .cornerRadius(10)
            }
        }
    }
}
