import SwiftUI

struct CustomAlert: View {
    let title: String
    let message: String
    var actionTitles: [String]
    @Binding var isPresented: Bool
    var actions: [() -> Void]

    var body: some View {
        VStack(spacing: 20) {
            Text(title)
                .font(.headline)
            Text(message)
                .font(.subheadline)
            HStack {
                ForEach(0..<actionTitles.count, id: \.self) { index in
                    Button(action: {
                        actions[index]()
                        isPresented = false
                    }) {
                        Text(actionTitles[index])
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(DesignSystemModel().cornerRadius)
        .shadow(radius: 5)
        .padding()
        .accessibilityLabel("Alert: \(title)")
    }
}