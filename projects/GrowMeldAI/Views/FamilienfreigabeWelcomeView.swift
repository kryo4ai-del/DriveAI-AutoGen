// FamilienfreigabeWelcomeView.swift
struct FamilienfreigabeWelcomeView: View {
    @ObservedObject var viewModel: FamilienfreigabeViewModel
    @Environment(\.sizeCategory) var sizeCategory
    
    var body: some View {
        VStack(alignment: .leading, spacing: verticalSpacing) {
            Image(systemName: "person.2.fill")
                .font(.system(size: 48))
                .foregroundColor(.driveAIBlue)
                .accessibilityHidden(true)
            
            Text("Schützen Sie Ihren Nachwuchs")
                .font(.title.weight(.bold))
                .accessibilityAddTraits(.isHeader)
            
            Text("Mit Familienfreigabe können Sie den Lernfortschritt Ihres Kindes verfolgen — respektvoll und transparent.")
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(nil)
            
            Spacer()
            
            Button(action: { viewModel.advanceSetup() }) {
                Text("Jetzt einrichten")
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
            }
            .buttonStyle(.primaryDriveAI)
            .accessibilityIdentifier("welcome.setup.button")
        }
        .padding()
        .navigationTitle("Familienfreigabe")
    }
    
    private var verticalSpacing: CGFloat {
        sizeCategory > .extraExtraLarge ? 32 : 24
    }
}

// FamilienfreigabeAddChildView.swift
struct FamilienfreigabeAddChildView: View {
    @ObservedObject var viewModel: FamilienfreigabeViewModel
    @State private var childName = ""
    @State private var childEmail = ""
    @State private var dateOfBirth = Date()
    @FocusState private var focusedField: Field?
    
    enum Field { case name, email, dob }
    
    var body: some View {
        Form {
            Section("Kindinformationen") {
                TextField("Name", text: $childName)
                    .focused($focusedField, equals: .name)
                    .accessibilityLabel("Name des Kindes")
                
                TextField("E-Mail", text: $childEmail)
                    .focused($focusedField, equals: .email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .accessibilityLabel("E-Mail-Adresse")
                
                DatePicker(
                    "Geburtsdatum",
                    selection: $dateOfBirth,
                    displayedComponents: .date
                )
                .focused($focusedField, equals: .dob)
                .accessibilityLabel("Geburtsdatum des Kindes")
                .accessibilityValue(dateOfBirth.formatted(date: .long, time: .omitted))
            }
            
            if let error = viewModel.error {
                Section {
                    Text(error)
                        .foregroundColor(.red)
                        .accessibilityLabel("Fehler")
                        .accessibilityValue(error)
                        .accessibilityLiveRegion(.assertive)
                }
            }
            
            Section {
                Button(action: addChild) {
                    Text(viewModel.isLoading ? "Wird hinzugefügt..." : "Kind hinzufügen")
                        .frame(maxWidth: .infinity)
                }
                .disabled(viewModel.isLoading || childName.trimmingCharacters(in: .whitespaces).isEmpty)
                .accessibilityIdentifier("add_child.submit.button")
            }
        }
        .navigationTitle("Kind hinzufügen")
    }
    
    private func addChild() {
        Task {
            await viewModel.addChild(
                name: childName,
                email: childEmail,
                dateOfBirth: dateOfBirth
            )
            if viewModel.error == nil {
                viewModel.advanceSetup()
            }
        }
    }
}