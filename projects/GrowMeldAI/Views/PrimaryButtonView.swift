import SwiftUI
struct PrimaryButtonView: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(.body, design: .default))
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .frame(height: 48)  // Minimum 44pt, use 48 for comfort
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
        .accessibilityLabel(title)
    }
}