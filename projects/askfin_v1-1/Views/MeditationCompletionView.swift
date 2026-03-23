import SwiftUI

struct MeditationCompletionView: View {
    @ObservedObject var viewModel: MeditationCompletionViewModel
    let onDismissAll: () -> Void

    var body: some View {
        VStack {
            Button("Fertig") {
                onDismissAll()
            }
        }
    }
}