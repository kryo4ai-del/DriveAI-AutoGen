import SwiftUI

struct WelcomeView: View {
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "graduationcap.fill")
                .font(.system(size: 60))
                .foregroundStyle(.blue.gradient)

            Text("Dein Prüfungsstart")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Wir machen dich bereit für deine Theorieprüfung")
                .font(.title3)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Spacer()

            Button(action: {
                viewModel.advance(to: .cameraPermission)
            }) {
                Text("Los geht's")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding()
    }
}