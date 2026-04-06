import SwiftUI

struct InitializationView: View {
    let onComplete: () -> Void

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.blue)

                VStack(spacing: 8) {
                    Text("Welcome to DriveAI")
                        .font(.headline)
                    Text("Setting up your learning environment")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                ProgressView()
                    .tint(.blue)
            }
            .padding()
        }
        .onAppear(perform: onComplete)
    }
}