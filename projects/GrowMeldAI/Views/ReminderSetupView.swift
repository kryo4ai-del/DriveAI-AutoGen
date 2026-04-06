import SwiftUI

struct ReminderSetupView: View {
    @StateObject var viewModel: ReminderViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Meine Lern-Erinnerungen")) {
                    Text("Ich will sicher bestehen — erinnere mich, wenn ich meine Schwächen wiederholen sollte")
                        .font(.headline)
                        .foregroundStyle(.blue)

                    ForEach(viewModel.reminders) { reminder in
                        ReminderRowView(reminder: reminder) {
                            viewModel.toggleReminder(for: reminder)
                        }
                    }
                }

                Section(header: Text("Erinnerungseinstellungen")) {
                    Stepper("Wiederholungsintervall: \(viewModel.reminders.first?.schedule.currentInterval ?? 3) Tage",
                            value: Binding(
                                get: { viewModel.reminders.first?.schedule.currentInterval ?? 3 },
                                set: { newValue in
                                    if let reminder = viewModel.reminders.first {
                                        viewModel.updateReminderSchedule(for: reminder, newInterval: newValue)
                                    }
                                }
                            ),
                            in: 1...14)
                }
            }
            .navigationTitle("Lern-Erinnerungen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fertig") {
                        dismiss()
                    }
                }
            }
            .alert("Fehler", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
}

struct ReminderRowView: View {
    let reminder: Reminder
    let onToggle: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(categoryName(for: reminder.categoryId))
                    .font(.headline)

                if let days = reminder.daysUntilNextReview {
                    Text("Nächste Wiederholung: in \(days) Tag\(days == 1 ? "" : "en")")
                        .font(.subheadline)
                        .foregroundStyle(reminder.isOverdue ? .red : .secondary)
                }
            }

            Spacer()

            Toggle("", isOn: Binding(
                get: { reminder.isEnabled },
                set: { _ in onToggle() }
            ))
            .labelsHidden()
        }
    }

    private func categoryName(for categoryId: String) -> String {
        // In a real app, this would come from a CategoryService
        switch categoryId {
        case "priority_signs": return "Vorfahrt"
        case "right_of_way": return "Vorfahrtsregeln"
        default: return "Unbekannte Kategorie"
        }
    }
}