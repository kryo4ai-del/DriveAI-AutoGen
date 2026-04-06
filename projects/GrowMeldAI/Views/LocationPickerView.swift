// ✅ REQUIRED ACCESSIBILITY PATTERNS

struct LocationPickerView: View {
    @ObservedObject var viewModel: LocationViewModel
    
    var body: some View {
        VStack {
            // Country Picker
            Picker("Land", selection: $viewModel.selectedCountry) {
                ForEach(DACHCountry.allCases, id: \.self) { country in
                    Text(country.displayName)
                        .tag(country)
                }
            }
            .accessibilityLabel("Land auswählen")
            .accessibilityHint("Wählen Sie Deutschland, Österreich oder Schweiz")
            
            // PLZ Input
            TextField("PLZ", text: $viewModel.enteredPLZ)
                .keyboardType(.numberPad)
                .accessibilityLabel("Postleitzahl eingeben")
                .accessibilityHint("Geben Sie \(viewModel.selectedCountry.expectedPLZLength) Ziffern ein")
                .onChange(of: viewModel.enteredPLZ) { _ in
                    viewModel.validateInput() // Real-time feedback for VoiceOver
                }
            
            // Validation Feedback
            if !viewModel.validationMessage.isEmpty {
                Text(viewModel.validationMessage)
                    .foregroundColor(.red)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityLabel("Validierungsmeldung: \(viewModel.validationMessage)")
            }
            
            // Results List
            List(viewModel.resolvedRegions, id: \.self) { region in
                Text(region.displayName(showCountry: false))
                    .accessibilityLabel(region.accessibilityLabel)
                    .accessibilityHint("Tippen zum Auswählen dieser Region")
            }
        }
    }
}