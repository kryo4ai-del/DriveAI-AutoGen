import SwiftUI

struct CameraControlButton: View {
    let action: () -> Void
    let label: String
    let icon: String
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .semibold))
                .frame(width: 44, height: 44)
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(Circle())
        }
        .accessibilityLabel(label)
        .accessibilityHint("Doppeltippen zum \(label)")
        .frame(minWidth: 44, minHeight: 44)
    }
}