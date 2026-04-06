import SwiftUI

struct AccessibleProgressIndicator: View {
    let progress: Double
    var body: some View {
        ProgressView(value: progress)
            .accessibilityLabel("Progress: \(Int(progress * 100))%")
    }
}
