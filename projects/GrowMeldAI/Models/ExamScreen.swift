import SwiftUI

struct ExamScreen: View {
    @ObservedObject var viewModel: ExamSimulationViewModel

    var body: some View {
        VStack {
            HStack {
                Image(systemName: "clock.fill")
                    .accessibilityHidden(true)
                Text(formattedTime(viewModel.remainingSeconds))
                    .font(.title2)
                    .foregroundColor(timerColor)
                    .accessibilityLabel("Time remaining")
                    .accessibilityValue(timeAccessibilityValue)
            }
        }
    }

    private var timeAccessibilityValue: String {
        let minutes = viewModel.remainingSeconds / 60
        let seconds = viewModel.remainingSeconds % 60
        if viewModel.remainingSeconds <= 60 {
            return "\(seconds) seconds remaining"
        }
        return "\(minutes) minutes, \(seconds) seconds remaining"
    }

    private var timerColor: Color {
        viewModel.remainingSeconds < 300 ? .red : .primary
    }

    private func formattedTime(_ seconds: Int) -> String {
        String(format: "%d:%02d", seconds / 60, seconds % 60)
    }
}
