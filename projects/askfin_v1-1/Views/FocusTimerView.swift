import SwiftUI

struct FocusTimerView: View {

    @StateObject private var viewModel = FocusTimerViewModel()

    private let ringLineWidth: CGFloat = 14
    private let ringSize: CGFloat = 260

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 40) {
                headerView
                timerRingView
                elapsedTimeView
                controlButtonsView
                durationPickerView
            }
            .padding(.horizontal, 24)
        }
        .navigationTitle("Focus Timer")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Subviews

    private var headerView: some View {
        VStack(spacing: 6) {
            Text("Focus Session")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)

            Text(viewModel.isCompleted ? "Session Complete! 🎉" : "Stay focused and productive")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    private var timerRingView: some View {
        ZStack {
            Circle()
                .stroke(
                    Color(.systemGray5),
                    lineWidth: ringLineWidth
                )
                .frame(width: ringSize, height: ringSize)

            Circle()
                .trim(from: 0, to: CGFloat(viewModel.progress))
                .stroke(
                    ringGradient,
                    style: StrokeStyle(
                        lineWidth: ringLineWidth,
                        lineCap: .round
                    )
                )
                .frame(width: ringSize, height: ringSize)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1.0), value: viewModel.progress)

            VStack(spacing: 8) {
                Text(viewModel.formatTime(viewModel.timeRemaining))
                    .font(.system(size: 52, weight: .thin, design: .monospaced))
                    .foregroundColor(.primary)
                    .contentTransition(.numericText())

                Text(timerStatusText)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(timerStatusColor)
                    .textCase(.uppercase)
                    .tracking(1.5)
            }
        }
    }

    private var elapsedTimeView: some View {
        HStack(spacing: 32) {
            VStack(spacing: 4) {
                Text(viewModel.formatTime(viewModel.elapsedTime))
                    .font(.system(size: 18, weight: .semibold, design: .monospaced))
                    .foregroundColor(.primary)
                Text("Elapsed")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Divider()
                .frame(height: 36)

            VStack(spacing: 4) {
                Text(viewModel.formatTime(viewModel.timeRemaining))
                    .font(.system(size: 18, weight: .semibold, design: .monospaced))
                    .foregroundColor(.primary)
                Text("Remaining")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private var controlButtonsView: some View {
        HStack(spacing: 24) {
            Button(action: { viewModel.reset() }) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.secondary)
                    .frame(width: 56, height: 56)
                    .background(
                        Circle()
                            .fill(Color(.secondarySystemBackground))
                    )
            }

            Button(action: handlePrimaryAction) {
                HStack(spacing: 8) {
                    Image(systemName: primaryButtonIcon)
                        .font(.system(size: 22, weight: .semibold))
                    Text(primaryButtonLabel)
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(width: 160, height: 56)
                .background(
                    Capsule()
                        .fill(primaryButtonColor)
                )
                .shadow(color: primaryButtonColor.opacity(0.4), radius: 8, x: 0, y: 4)
            }
            .disabled(viewModel.isCompleted)

            Button(action: {}) {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.secondary)
                    .frame(width: 56, height: 56)
                    .background(
                        Circle()
                            .fill(Color(.secondarySystemBackground))
                    )
            }
        }
    }

    private var durationPickerView: some View {
        VStack(spacing: 12) {
            Text("Duration")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
                .tracking(1.2)

            HStack(spacing: 12) {
                ForEach([15, 25, 45, 60], id: \.self) { minutes in
                    Button(action: {
                        viewModel.setDuration(minutes: minutes)
                    }) {
                        Text("\(minutes)m")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(isSelectedDuration(minutes) ? .white : .primary)
                            .frame(width: 60, height: 36)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(isSelectedDuration(minutes) ? Color.accentColor : Color(.secondarySystemBackground))
                            )
                    }
                    .disabled(viewModel.isRunning)
                }
            }
        }
    }

    // MARK: - Computed Helpers

    private var ringGradient: AngularGradient {
        AngularGradient(
            gradient: Gradient(colors: [Color.accentColor.opacity(0.6), Color.accentColor]),
            center: .center,
            startAngle: .degrees(-90),
            endAngle: .degrees(270)
        )
    }

    private var timerStatusText: String {
        if viewModel.isCompleted {
            return "Completed"
        } else if viewModel.isRunning {
            return "Focusing"
        } else if viewModel.isPaused {
            return "Paused"
        } else {
            return "Ready"
        }
    }

    private var timerStatusColor: Color {
        if viewModel.isCompleted {
            return .green
        } else if viewModel.isRunning {
            return .accentColor
        } else if viewModel.isPaused {
            return .orange
        } else {
            return .secondary
        }
    }

    private var primaryButtonIcon: String {
        if viewModel.isRunning {
            return "pause.fill"
        } else if viewModel.isPaused {
            return "play.fill"
        } else {
            return "play.fill"
        }
    }

    private var primaryButtonLabel: String {
        if viewModel.isRunning {
            return "Pause"
        } else if viewModel.isPaused {
            return "Resume"
        } else {
            return "Start"
        }
    }

    private var primaryButtonColor: Color {
        if viewModel.isRunning {
            return .orange
        } else {
            return .accentColor
        }
    }

    private func handlePrimaryAction() {
        if viewModel.isRunning {
            viewModel.pause()
        } else {
            viewModel.start()
        }
    }

    private func isSelectedDuration(_ minutes: Int) -> Bool {
        let selectedSeconds = TimeInterval(minutes * 60)
        return abs(selectedSeconds - (viewModel.timeRemaining + viewModel.elapsedTime)) < 1
    }
}

// MARK: - Preview

struct FocusTimerView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FocusTimerView()
        }
    }
}