import SwiftUI

struct BreathFlowSessionView: View {

    @ObservedObject var viewModel: BreathFlowSessionViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showEndConfirmation = false

    var body: some View {
        ZStack {
            // Adaptive background tint from pattern color
            viewModel.pattern.accentColor
                .opacity(0.06)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                sessionControls
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                Spacer()

                BreathAnimationView(
                    phase: viewModel.currentPhase,
                    phaseProgress: viewModel.phaseProgress,
                    accentColor: viewModel.pattern.accentColor
                )
                .frame(width: 240, height: 240)

                Spacer().frame(height: 24)

                PhaseLabel(phase: viewModel.currentPhase)

                Spacer().frame(height: 32)

                PhaseStepIndicator(
                    phases: viewModel.pattern.phases,
                    currentIndex: viewModel.currentPhaseIndex
                )

                Spacer()

                BreathProgressRing(
                    progress: viewModel.cycleProgress,
                    completedCycles: viewModel.completedCycles,
                    totalCycles: viewModel.totalCycles,
                    accentColor: viewModel.pattern.accentColor
                )
                .frame(height: 72)
                .padding(.horizontal, 40)

                Spacer().frame(height: 32)
            }

            // Countdown overlay
            if case .countdown(let n) = viewModel.state {
                CountdownOverlay(value: n)
            }
        }
        .navigationBarHidden(true)
        .onAppear { viewModel.startSession() }
        .onChange(of: viewModel.state) { _, newState in
            if case .complete = newState { dismiss() }
        }
        .confirmationDialog(
            "Atemübung beenden?",
            isPresented: $showEndConfirmation,
            titleVisibility: .visible
        ) {
            Button("Beenden", role: .destructive) {
                viewModel.endSession(completed: false)
            }
            Button("Weitermachen", role: .cancel) {}
        }
    }

    // MARK: - Controls

    private var sessionControls: some View {
        HStack {
            Button(action: { showEndConfirmation = true }) {
                Label("Beenden", systemImage: "xmark")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if case .paused = viewModel.state {
                Button(action: viewModel.resumeSession) {
                    Image(systemName: "play.fill")
                        .font(.title3)
                        .foregroundStyle(.primary)
                }
            } else if case .breathing = viewModel.state {
                Button(action: viewModel.pauseSession) {
                    Image(systemName: "pause.fill")
                        .font(.title3)
                        .foregroundStyle(.primary)
                }
            }
        }
        .padding(.vertical, 12)
    }
}