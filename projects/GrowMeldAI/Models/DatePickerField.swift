// PATTERN: Form components use @Binding
struct DatePickerField: View {
    let label: String
    @Binding var selection: Date
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(label).font(AppTheme.typography.caption)
            DatePicker("", selection: $selection, displayedComponents: [.date])
                .accessibilityLabel(label)
        }
    }
}

// ViewModel owns the state
@Observable

// Screen binds to ViewModel
@State var viewModel = OnboardingViewModel()
DatePickerField(label: "Prüfungsdatum", selection: $viewModel.examDate)