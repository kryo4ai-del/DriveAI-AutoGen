import SwiftUI
struct RetentionPeriodPicker: View {
    @Binding var selectedPeriod: Int
    let onChange: (Int) -> Void
    
    let options: [(days: Int, label: String, outcome: String)] = [
        (30, "1 Monat", "Nach der Prüfung automatisch gelöscht"),
        (90, "3 Monate", "Standard — sichere längere Vorbereitungsphase"),
        (365, "1 Jahr", "Für wiederholte Vorbereitung"),
        (Int.max, "Nie löschen", "Deine Daten bleiben dauerhaft")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(options, id: \.days) { option in
                Button(action: {
                    selectedPeriod = option.days
                    onChange(option.days)
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(option.label).font(.subheadline).fontWeight(.semibold)
                            Text(option.outcome).font(.caption).foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: selectedPeriod == option.days ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(selectedPeriod == option.days ? .blue : .gray)
                    }
                    .padding(10)
                    .background(selectedPeriod == option.days ? Color.blue.opacity(0.1) : Color.gray.opacity(0.05))
                    .cornerRadius(8)
                }
            }
        }
    }
}