import SwiftUI

struct MeditationSetupView: View {

    @StateObject private var viewModel = MeditationSetupViewModel()
    @State private var activeViewModel: MeditationActiveViewModel?
    @State private var navigateToActive = false

    var body: some View {
        NavigationStack {
            ZStack {
                background
                ScrollView {
                    VStack(spacing: 0) {
                        headerSection
                            .padding(.top, 48)
                        statsSection
                            .padding(.top, 40)
                        durationPicker
                            .padding(.top, 40)
                        Spacer(minLength: 48)
                        startButton
                            .padding(.bottom, 48)
                    }
                    .padding(.horizontal, 24)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $navigateToActive) {
                if let vm = activeViewModel {
                    MeditationActiveView(viewModel: vm)
                }
            }
            .onAppear { viewModel.onAppear() }
        }
    }

    // MARK: - Background

    private var background: some View {
        LinearGradient(
            colors: [
                Color(red: 0.05, green: 0.11, blue: 0.17),
                Color(red: 0.08, green: 0.16, blue: 0.24)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
        .overlay(
            RadialGradient(
                colors: [Color.teal.opacity(0.12), Color.clear],
                center: .top,
                startRadius: 0,
                endRadius: 380
            )
            .ignoresSafeArea()
        )
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 14) {
            Text("🧘")
                .font(.system(size: 56))
                .accessibilityHidden(true)

            Text("Vor der Prüfung\ndurchatmen")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)

            Text("Nimm dir einen Moment der Ruhe")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.65))
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Stats

    private var statsSection: some View {
        HStack(spacing: 0) {
            statItem(
                value: "\(viewModel.completedSessionCount)",
                label: "Meditationen",
                icon: "leaf.fill"
            )

            Divider()
                .frame(width: 1, height: 40)
                .background(.white.opacity(0.2))

            statItem(
                value: "\(viewModel.currentStreak)",
                label: viewModel.currentStreak == 1 ? "Tag Streak" : "Tage Streak",
                icon: "flame.fill"
            )
        }
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.white.opacity(0.07))
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(viewModel.completedSessionCount) Meditationen, \(viewModel.currentStreak) Tage Streak"
        )
    }

    private func statItem(value: String, label: String, icon: String) -> some View {
        VStack(spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(.teal)
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
            }
            Text(label)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.55))
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Duration Picker

    private var durationPicker: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Dauer wählen")
                .font(.footnote)
                .fontWeight(.semibold)
                .foregroundStyle(.white.opacity(0.55))
                .textCase(.uppercase)
                .tracking(0.8)

            HStack(spacing: 12) {
                ForEach(MeditationDuration.allCases) { duration in
                    DurationPill(
                        duration: duration,
                        isSelected: viewModel.selectedDuration == duration
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            viewModel.selectedDuration = duration
                        }
                    }
                }
            }

            Text(viewModel.selectedDuration.description)
                .font(.subheadline)
                .foregroundStyle(.teal.opacity(0.9))
                .animation(.easeInOut(duration: 0.2), value: viewModel.selectedDuration)
        }
    }

    // MARK: - Start Button

    private var startButton: some View {
        Button {
            activeViewModel = viewModel.makeActiveViewModel()
            navigateToActive = true
        } label: {
            Text("Jetzt starten")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.teal, Color.teal.opacity(0.75)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
        }
        .accessibilityLabel("Meditation starten, \(viewModel.selectedDuration.label)")
        .accessibilityHint("Startet eine Atemübung von \(viewModel.selectedDuration.label)")
    }
}

// MARK: - Duration Pill

private struct DurationPill: View {
    let duration: MeditationDuration
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(duration.label)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundStyle(isSelected ? .white : .white.opacity(0.55))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(isSelected ? Color.teal : Color.white.opacity(0.08))
                )
        }
        .accessibilityLabel("\(duration.label), \(duration.description)")
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}