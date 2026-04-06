import SwiftUI

struct WelcomeScreen: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with icon
            VStack(spacing: 16) {
                Image(systemName: "car.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.accentColor)
                    .padding(.top, 48)
                
                VStack(spacing: 8) {
                    Text("Du schaffst das.")
                        .font(.system(size: 32, weight: .bold))
                    
                    Text("Wir zeigen dir wie.")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.secondary)
                }
                .multilineTextAlignment(.center)
            }
            .padding(.bottom, 40)
            
            // Features
            VStack(alignment: .leading, spacing: 16) {
                FeatureBullet(
                    icon: "checkmark.circle.fill",
                    text: "1000+ echte Prüfungsfragen"
                )
                FeatureBullet(
                    icon: "chart.bar.fill",
                    text: "Detaillierter Lernfortschritt"
                )
                FeatureBullet(
                    icon: "timer",
                    text: "Realistische Prüfungssimulation"
                )
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
            
            Spacer()
            
            // CTA Button
            Button(action: {
                viewModel.nextStep()
            }) {
                Text("Jetzt starten")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
            .accessibilityLabel("Onboarding starten")
            .accessibilityHint("Tippen Sie hier, um Ihren Prüfungstermin einzustellen")
        }
    }
}

#Preview {
    WelcomeScreen(viewModel: OnboardingViewModel())
}