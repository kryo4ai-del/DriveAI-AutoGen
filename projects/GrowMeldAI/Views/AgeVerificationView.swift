// Views/Compliance/AgeVerificationView.swift

struct AgeVerificationView: View {
    @StateObject var viewModel: ComplianceGateViewModel
    @State private var selectedYear: Int = 2008
    
    var body: some View {
        VStack(spacing: 24) {
            // Header with emotional framing (addresses UX psychology note from memory)
            VStack(spacing: 8) {
                Text("Dein Weg zum Führerschein")
                    .font(.system(.title2, design: .default))
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Wir schützen deine Daten – immer")
                    .font(.system(.body, design: .default))
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 20)
            
            // Age verification (required for both GDPR + COPPA)
            VStack(alignment: .leading, spacing: 12) {
                Label("Wann wurdest du geboren?", systemImage: "calendar")
                    .font(.headline)
                
                Picker("Geburtsyear", selection: $selectedYear) {
                    ForEach((1995...2008), id: \.self) { year in
                        Text(String(year)).tag(year)
                    }
                }
                .pickerStyle(.wheel)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            // Accessibility: VoiceOver support
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Altersbestätigung")
            
            // Submit button
            Button(action: {
                Task {
                    await viewModel.submitAgeVerification(selectedYear)
                }
            }) {
                Label("Bestätigen und fortfahren", systemImage: "arrow.right")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .accessibilityLabel("Alter bestätigen")
            
            Spacer()
        }
        .padding()
        .task {
            await viewModel.initializeCompliance()
        }
    }
}

// Views/Compliance/ParentalConsentView.swift (COPPA-specific)

struct ParentalConsentView: View {
    @StateObject var viewModel: ComplianceGateViewModel
    @State private var parentEmail: String = ""
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 24) {
            // COPPA-specific messaging (emotional framing)
            VStack(spacing: 8) {
                Text("Zustimmung der Eltern erforderlich")
                    .font(.headline)
                
                Text("DriveAI schützt Ihre Daten und Ihren Datenschutz nach höchsten Standards.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemBlue).opacity(0.1))
            .cornerRadius(12)
            
            // Parent email input (verifiable parental consent — COPPA requirement)
            VStack(alignment: .leading, spacing: 8) {
                Label("E-Mail-Adresse eines Elternteils", systemImage: "envelope")
                    .font(.headline)
                
                TextField("parent@example.de", text: $parentEmail)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .accessibilityLabel("E-Mail-Adresse des Elternteils")
            }
            
            Button(action: {
                Task {
                    isLoading = true
                    await viewModel.submitParentalConsent(parentEmail)
                    isLoading = false
                }
            }) {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Zustimmung senden")
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
            .disabled(!isValidEmail(parentEmail) || isLoading)
            
            Spacer()
        }
        .padding()
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        email.contains("@") && email.contains(".")
    }
}