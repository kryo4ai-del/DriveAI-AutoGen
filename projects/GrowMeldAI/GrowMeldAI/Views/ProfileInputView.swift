// ✅ Accessible keyboard navigation
struct ProfileInputView: View {
    @FocusState private var focusedField: FormField?
    
    enum FormField: Hashable {
        case name
        case examDate
        case licenseCategory
        case continueButton
    }
    
    var body: some View {
        Form {
            Section("Persönliche Informationen") {
                TextField("Name", text: $viewModel.name)
                    .focused($focusedField, equals: .name)
                    .submitLabel(.next)  // Show "Next" on keyboard
                    .onSubmit {
                        focusedField = .examDate  // Move to next field
                    }
                
                DatePicker("Prüfungsdatum", selection: $viewModel.examDate)
                    .focused($focusedField, equals: .examDate)
                    .onSubmit {
                        focusedField = .licenseCategory
                    }
                
                Picker("Führerscheinklasse", selection: $viewModel.licenseCategory) {
                    ForEach(LicenseCategory.allCases, id: \.self) { category in
                        Text(category.localizedName).tag(category)
                    }
                }
                .focused($focusedField, equals: .licenseCategory)
            }
            
            Section {
                Button(action: { viewModel.submitForm() }) {
                    Text("Weiter")
                        .frame(maxWidth: .infinity)
                }
                .focused($focusedField, equals: .continueButton)
                .accessibilityLabel("Weiter zum nächsten Schritt")
            }
        }
        .onAppear {
            // Set initial focus to first field
            focusedField = .name
        }
    }
}