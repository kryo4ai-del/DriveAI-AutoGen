struct ExamDatePickerView: View {
    @StateObject private var formVM = ExamDateViewModel()
    @ObservedObject var authVM: AuthViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Wann ist deine Prüfung?")
                .font(.title2.bold())
            
            DatePicker(
                "Select Exam Date",
                selection: Binding(
                    get: { formVM.selectedDate ?? Date() },
                    set: { formVM.selectDate($0) }
                ),
                displayedComponents: .date
            )
            .datePickerStyle(.wheel)
            
            if formVM.daysUntilExam > 0 {
                ExamCountdownPreview(daysUntilExam: formVM.daysUntilExam)
                
                Text(formVM.studyRecommendation)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            }
            
            Button("Weiter") {
                authVM.advanceToSignUp()
            }
            .buttonStyle(.borderedProminent)
            .disabled(!formVM.isDateValid)
            
            Spacer()
        }
        .padding()
    }
}