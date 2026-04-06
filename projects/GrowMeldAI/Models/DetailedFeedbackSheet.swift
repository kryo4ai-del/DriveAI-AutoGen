struct DetailedFeedbackSheet: View {
    @State private var consentCheckbox = false
    
    var body: some View {
        VStack {
            // Feedback form content...
            
            // Privacy disclosure BEFORE submission
            Divider()
            
            Link("Datenschutzerklärung", destination: privacyURL)
                .font(.caption)
                .foregroundColor(.blue)
            
            // Checkbox MUST be unchecked by default (Art. 7)
            Toggle("Ich habe die Datenschutzerklärung gelesen und bin einverstanden",
                   isOn: $consentCheckbox)
            
            Button("Senden") {
                if consentCheckbox {
                    submitFeedback()
                }
            }
            .disabled(!consentCheckbox)
        }
    }
}