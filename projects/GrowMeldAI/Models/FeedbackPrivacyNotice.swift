import SwiftUI
struct FeedbackPrivacyNotice: View {
    @State private var consentGiven = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Datenschutzerklärung")
                .font(.headline)
            
            Text(privacyText)  // GDPR Art. 7 compliant language
                .font(.caption)
            
            // Explicit opt-in (not pre-checked)
            Toggle("Ich stimme der Erfassung meines Feedbacks zu", 
                   isOn: $consentGiven)
            
            // Optional contact info
            if consentGiven {
                TextField("E-Mail (optional)", text: $email)
            }
        }
    }
    
    private var privacyText: String {
        """
        Ihre Rückmeldung hilft uns, die Lern-App zu verbessern...
        [FULL GDPR Art. 7 COMPLIANT TEXT HERE]
        """
    }
}