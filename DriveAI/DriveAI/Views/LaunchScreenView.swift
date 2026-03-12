import SwiftUI

struct LaunchScreenView: View {
    @State private var glowPulse = false
    @State private var textOpacity: Double = 0

    var body: some View {
        ZStack {
            // Dark futuristic gradient background
            LinearGradient(
                colors: [
                    Color.askFinBackground,
                    Color(red: 5/255, green: 8/255, blue: 18/255)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {

                // Logo mark — "F" in a glowing circle
                ZStack {
                    Circle()
                        .fill(Color.askFinCard)
                        .frame(width: 100, height: 100)
                        .shadow(
                            color: Color.askFinPrimary.opacity(glowPulse ? 0.65 : 0.18),
                            radius: glowPulse ? 22 : 8
                        )

                    Circle()
                        .stroke(Color.askFinPrimary.opacity(glowPulse ? 0.50 : 0.15), lineWidth: 1.5)
                        .frame(width: 100, height: 100)

                    Text("F")
                        .font(.system(size: 54, weight: .bold, design: .rounded))
                        .foregroundColor(Color.askFinPrimary)
                }
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.3).repeatForever(autoreverses: true)) {
                        glowPulse = true
                    }
                }

                // App name
                Text("AskFin")
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                // Slogan
                Text("Nutze Fin und sage Ja")
                    .font(.subheadline)
                    .foregroundColor(Color.askFinPrimary.opacity(0.85))
                    .tracking(0.4)
            }
            .opacity(textOpacity)
            .onAppear {
                withAnimation(.easeOut(duration: 0.5)) {
                    textOpacity = 1
                }
            }
        }
    }
}
