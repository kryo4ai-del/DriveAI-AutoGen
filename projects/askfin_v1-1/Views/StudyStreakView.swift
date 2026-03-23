import SwiftUI

struct StudyStreakView: View {

    @StateObject private var viewModel = StudyStreakViewModel()

    // Controls the "log session" sheet
    @State private var showingLogSheet: Bool = false
    @State private var minutesInput: String = ""
    @State private var showingResetConfirmation: Bool = false

    // MARK: - Body

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 28) {
                    streakHeaderSection
                    calendarDotsSection
                    todayStatusSection
                    logSessionButton
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
            .navigationTitle("Study Streak")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(role: .destructive) {
                        showingResetConfirmation = true
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(.red.opacity(0.8))
                    }
                }
            }
            .confirmationDialog(
                "Reset all streak data?",
                isPresented: $showingResetConfirmation,
                titleVisibility: .visible
            ) {
                Button("Reset", role: .destructive) {
                    viewModel.resetAllData()
                }
                Button("Cancel", role: .cancel) {}
            }
            .sheet(isPresented: $showingLogSheet) {
                logSessionSheet
            }
            .onAppear {
                viewModel.refresh()
            }
        }
    }

    // MARK: - Subviews

    private var streakHeaderSection: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.orange.opacity(0.85), Color.red.opacity(0.75)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .shadow(color: .orange.opacity(0.45), radius: 16, x: 0, y: 8)

                VStack(spacing: 2) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)

                    Text("\(viewModel.currentStreak)")
                        .font(.system(size: 36, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                }
            }

            Text(viewModel.currentStreak == 1 ? "day streak" : "day streak")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.secondary)

            if viewModel.currentStreak >= 7 {
                Label("On fire! Keep it up 🔥", systemImage: "star.fill")
                    .font(.caption)
                    .foregroundColor(.orange)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.12))
                    .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private var calendarDotsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Last 7 Days")
                .font(.headline)
                .foregroundColor(.primary)

            HStack(spacing: 0) {
                ForEach(viewModel.last7DayStatuses) { status in
                    dayDotView(status: status)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private func dayDotView(status: StudyStreakViewModel.DayStatus) -> some View {
        let isToday = Calendar.current.isDateInToday(status.date)

        return VStack(spacing: 6) {
            Text(status.shortLabel)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(isToday ? .orange : .secondary)

            ZStack {
                Circle()
                    .fill(dotColor(for: status))
                    .frame(width: 28, height: 28)

                if status.didStudy {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    Circle()
                        .fill(Color(.tertiarySystemBackground))
                        .frame(width: 14, height: 14)
                }
            }
            .overlay(
                Circle()
                    .stroke(isToday ? Color.orange : Color.clear, lineWidth: 2)
                    .frame(width: 28, height: 28)
            )
        }
        .frame(maxWidth: .infinity)
    }

    private func dotColor(for status: StudyStreakViewModel.DayStatus) -> Color {
        if status.didStudy {
            return .orange
        }
        return Color(.systemGray5)
    }

    private var todayStatusSection: some View {
        HStack(spacing: 14) {
            Image(systemName: viewModel.hasStudiedToday ? "checkmark.circle.fill" : "clock.circle")
                .font(.system(size: 28))
                .foregroundColor(viewModel.hasStudiedToday ? .green : .secondary)

            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.hasStudiedToday ? "Studied Today!" : "Not studied yet today")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)

                if viewModel.hasStudiedToday {
                    Text("\(viewModel.todayMinutes) min logged today")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text("Log a session to keep your streak alive")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(viewModel.hasStudiedToday
                      ? Color.green.opacity(0.10)
                      : Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(viewModel.hasStudiedToday ? Color.green.opacity(0.3) : Color.clear, lineWidth: 1)
        )
    }

    private var logSessionButton: some View {
        Button {
            minutesInput = ""
            showingLogSheet = true
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 20))
                Text("Log Study Session")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [Color.orange, Color.red.opacity(0.85)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: .orange.opacity(0.35), radius: 10, x: 0, y: 5)
        }
    }

    // MARK: - Log Session Sheet

    private var logSessionSheet: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 44))
                        .foregroundColor(.orange)

                    Text("How long did you study?")
                        .font(.title3.bold())
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Minutes studied")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    TextField("e.g. 30", text: $minutesInput)
                        .keyboardType(.numberPad)
                        .font(.system(size: 18, weight: .medium))
                        .padding(14)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .padding(.horizontal, 20)

                Button {
                    let minutes = Int(minutesInput) ?? 0
                    if minutes > 0 {
                        viewModel.logStudySession(minutes: minutes)
                        showingLogSheet = false
                    }
                } label: {
                    Text("Save Session")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            (Int(minutesInput) ?? 0) > 0
                            ? AnyShapeStyle(LinearGradient(colors: [.orange, .red.opacity(0.85)],
                                                           startPoint: .leading,
                                                           endPoint: .trailing))
                            : AnyShapeStyle(Color.gray.opacity(0.4))
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .disabled((Int(minutesInput) ?? 0) <= 0)
                .padding(.horizontal, 20)

                Spacer()
            }
            .navigationTitle("Log Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        showingLogSheet = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Preview

struct StudyStreakView_Previews: PreviewProvider {
    static var previews: some View {
        StudyStreakView()
    }
}