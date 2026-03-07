import SwiftUI

struct SettingsRow: View {
    let title: String
    let isToggle: Bool
    @Binding var isOn: Bool
    var toggleAction: (() -> Void)?
    var description: String? // New optional description parameter

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(title)
                Spacer()
                if isToggle {
                    Toggle(isOn: $isOn, label: {
                        EmptyView()
                    })
                    .labelsHidden()
                    .onChange(of: isOn) { _ in
                        toggleAction?()
                    }
                } else {
                    Text(isOn ? "Enabled" : "Disabled")
                        .foregroundColor(.gray)
                }
            }
            if let description = description {
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
    }
}