import SwiftUI

struct SettingRow: View {
    var option: SettingOption
    var action: () -> Void
    
    var body: some View {
        HStack {
            Text(option.title)
                .font(.headline)
            Spacer()
            Toggle("", isOn: Binding(
                get: { option.isOn },
                set: { _ in action() } // Combine toggle action with value change
            ))
            .labelsHidden()
        }
    }
}