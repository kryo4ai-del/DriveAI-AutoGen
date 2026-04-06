import SwiftUI

struct ConsentPreference {
    let titleKey: String
    let descriptionKey: String
}

struct ConsentToggleComponent: View {
    @Binding var isGranted: Bool
    let preference: ConsentPreference

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(preference.titleKey)
                        .font(.body)
                        .fontWeight(.semibold)

                    Text(preference.descriptionKey)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Toggle(isOn: $isGranted) {
                    EmptyView()  // Hidden label, using accessibility instead
                }
                .tint(.blue)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(Text(preference.titleKey))
            .accessibilityHint(Text(preference.descriptionKey))
            .accessibilityValue(Text(isGranted ? "On" : "Off"))
            .accessibilityAddTraits(.isToggle)
            .accessibilityRemoveTraits(.isButton)
        }
        .padding()
    }
}