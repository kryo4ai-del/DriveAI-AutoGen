import SwiftUI

struct OnboardingView: View {
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        VStack(spacing: 28) {

            // Header
            VStack(spacing: 12) {

                // Logo mark
                ZStack {
                    Circle()
                        .fill(Color.askFinCard)
                        .frame(width: 84, height: 84)
                        .shadow(color: Color.askFinPrimary.opacity(0.40), radius: 12)

                    Circle()
                        .stroke(Color.askFinPrimary.opacity(0.28), lineWidth: 1.5)
                        .frame(width: 84, height: 84)

                    Text("F")
                        .font(.system(size: 46, weight: .bold, design: .rounded))
                        .foregroundColor(Color.askFinPrimary)
                }

                Text("Willkommen bei AskFin")
                    .font(.largeTitle)
                    .bold()

                Text("Nutze Fin und sage Ja")
                    .font(.subheadline)
                    .foregroundColor(Color.askFinPrimary.opacity(0.85))
                    .multilineTextAlignment(.center)

                Text("Wähle dein Prüfungsdatum, um dein Lernen zu personalisieren.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 2)
            }
            .padding(.top, 16)

            // Date picker
            DatePicker(
                "Exam Date",
                selection: $viewModel.examDate,
                in: Date()...,
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .labelsHidden()
            .accentColor(Color.askFinPrimary)

            // Continue button
            Button(action: { viewModel.saveUserData() }) {
                Text("Los geht's")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.askFinPrimary)
                    .foregroundColor(Color.askFinBackground)
                    .cornerRadius(AppTheme.cornerRadius)
                    .shadow(color: Color.askFinPrimary.opacity(AppTheme.glowOpacity),
                            radius: AppTheme.glowRadius)
            }
        }
        .padding()
        .navigationTitle("AskFin")
        .navigationBarBackButtonHidden(true)
    }
}
