// Schedule picker UI will need:

struct MaintenanceScheduleView: View {
    @State private var selectedDay: Int = 1
    @State private var selectedHour: Int = 9
    
    var body: some View {
        VStack {
            // Day picker
            Picker(selection: $selectedDay) {
                ForEach(WeeklyMaintenanceSchedule.DayOfWeek.allCases, id: \.self) { day in
                    Text(day.localizedName)
                        .tag(day.rawValue)
                        .accessibilityLabel("Wartungs-Tag: \(day.localizedName)")
                }
            } label: {
                Label("Wartungstag wählen", systemImage: "calendar")
                    .accessibilityLabel("Wählen Sie den Tag für wöchentliche Wartungschecks")
            }
            
            // Hour picker (44x44 minimum)
            Picker(selection: $selectedHour) {
                ForEach(0..<24, id: \.self) { hour in
                    Text(String(format: "%02d:00", hour))
                        .tag(hour)
                        .accessibilityLabel("\(hour) Uhr")
                }
            } label: {
                Label("Uhrzeit wählen", systemImage: "clock")
                    .accessibilityLabel("Wählen Sie die Uhrzeit für Wartungschecks")
            }
        }
    }
}