struct AgeGateConfirmationView: View {
    let birthDate: Date
    let recordedDate: Date = Date()
    var onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            // Success Icon
            VStack(spacing: 16) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.green)
                
                Text("Bestätigung erfolgreich")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            // Recorded Info (Zeigarnik closure)
            VStack(alignment: .leading, spacing: 12) {
                Label("Geburtsdatum erfasst", systemImage: "calendar")
                Label("Gerät identifiziert", systemImage: "iphone")
                Label("Zeitstempel: \(recordedDate.formatted(date: .abbreviated, time: .shortened))", 
                      systemImage: "clock")
            }
            .font(.callout)
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            
            Spacer()
            
            // Continue Button
            Button(action: onContinue) {
                Text("Weiter zur App")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding(24)
    }
}