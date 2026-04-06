import SwiftUI

@main

private struct LoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
            Text("Lade Fragen für deine Theorieprüfung...")
                .font(.headline)
        }
    }
}
