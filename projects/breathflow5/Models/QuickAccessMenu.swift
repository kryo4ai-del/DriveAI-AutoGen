import SwiftUI

struct QuickAccessMenu: View {
    // Shows options: Resume, Weak Areas, Today's Challenge
    // Communicates with QuickAccessViewModel

    var body: some View {
        VStack(spacing: 16) {
            Button(action: {
                // Resume action
            }) {
                Text("Resume")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }

            Button(action: {
                // Weak Areas action
            }) {
                Text("Weak Areas")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }

            Button(action: {
                // Today's Challenge action
            }) {
                Text("Today's Challenge")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
    }
}