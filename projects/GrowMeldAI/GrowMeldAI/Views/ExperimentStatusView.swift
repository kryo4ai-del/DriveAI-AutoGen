// AFTER (✅ Announces changes)
struct ExperimentStatusView: View {
    @State var isActive: Bool
    
    var body: some View {
        HStack {
            Image(systemName: isActive ? "checkmark.circle.fill" : "xmark.circle")
                .foregroundColor(isActive ? .green : .red)
                .accessibilityHidden(true)
            
            Text("Status: \(isActive ? "Active" : "Inactive")")
                .accessibilityLabel("Experiment status")
                .accessibilityValue(isActive ? "Active" : "Inactive")
            
            Button(action: {
                isActive.toggle()
                
                // ✅ Announce state change
                let announcement = isActive ? "Experiment activated" : "Experiment deactivated"
                UIAccessibility.post(notification: .announcement, argument: announcement)
            }) {
                Text(isActive ? "Deactivate" : "Activate")
                    .accessibilityLabel(isActive ? "Deactivate experiment" : "Activate experiment")
            }
        }
        .padding()
    }
}