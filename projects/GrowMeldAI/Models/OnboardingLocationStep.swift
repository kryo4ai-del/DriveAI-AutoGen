struct OnboardingLocationStep: View {
    @ObservedObject var permissionManager: LocationPermissionManager
    @State var examDate: Date = Date()
    var onComplete: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            // Step indicator
            ProgressView(value: 0.67)
                .accessibilityLabel("Schritt 2 von 3 des Onboarding-Prozesses")
            
            // Exam date section (completed in step 1)
            Section(header: Text("Prüfungsdatum").font(.headline).accessibilityAddTraits(.isHeader)) {
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.blue)
                        .accessibilityHidden(true)
                    Text(examDate.formatted(date: .abbreviated, time: .omitted))
                        .font(.body)
                    Spacer()
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .accessibilityHidden(true)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .accessibilityElement(children: .combine)
            }
            
            // Location section (current step)
            LocationPermissionView(permissionManager: permissionManager)
            
            Spacer()
            
            // Continue button
            Button(action: onComplete) {
                Text("Weiter")
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .font(.headline)
                    .foregroundColor(.white)
                    .background(
                        permissionManager.permissionStatus.isAuthorized ? Color.blue : Color.gray
                    )
                    .cornerRadius(8)
            }
            .disabled(permissionManager.permissionStatus == .notDetermined)
            .accessibilityLabel("Weiter zum nächsten Schritt")
            .accessibilityHint(
                permissionManager.permissionStatus.isAuthorized
                    ? "Du kannst fortfahren"
                    : "Erlaube Standortzugriff um fortzufahren"
            )
        }
        .padding(20)
        .accessibilityElement(children: .contain)
    }
}