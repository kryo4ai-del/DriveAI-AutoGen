import SwiftUI

struct ExamCountdownCard: View {
    @ObservedObject var viewModel: ProfileViewModel
    @State private var showDatePicker = false
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("📅 Prüfungsvorbereitung")
                    .font(.headline)
                    .accessibilityAddTraits(.isHeader)
                Spacer()
            }
            
            // Countdown text
            Text(viewModel.examCountdownText)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.blue)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            // Exam date if set
            if let examDate = viewModel.userProfile.examDate {
                Text(examDate.formatted(date: .long, time: .omitted))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Edit button
            Button(action: { showDatePicker.toggle() }) {
                Label(
                    NSLocalizedString("profile.exam.change_date", comment: "Button to change exam date"),
                    systemImage: "pencil.circle.fill"
                )
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .accessibilityLabel(Text("Prüfungsdatum ändern"))
            .sheet(isPresented: $showDatePicker) {
                ExamDatePickerSheet(
                    isPresented: $showDatePicker,
                    selectedDate: Binding(
                        get: { viewModel.userProfile.examDate ?? Date() },
                        set: { viewModel.updateExamDate($0) }
                    )
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .accessibilityElement(children: .contain)
    }
}

struct ExamDatePickerSheet: View {
    @Binding var isPresented: Bool
    @Binding var selectedDate: Date
    
    var body: some View {
        NavigationStack {
            VStack {
                DatePicker(
                    NSLocalizedString("profile.exam.select_date", comment: "Select exam date label"),
                    selection: $selectedDate,
                    in: Date()...,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .padding()
                
                Spacer()
                
                Button(action: { isPresented = false }) {
                    Text("Fertig")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
            }
            .navigationTitle("Prüfungsdatum")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Abbrechen") { isPresented = false }
                }
            }
        }
    }
}