// ✅ ACCESSIBLE RESULT VIEW
struct AccessibleRecognitionResultView: View {
    let plant: PlantIdentity
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // ✅ Dynamic Type support
            Text(plant.germanName)
                .font(.system(.title, design: .default))
                .dynamicTypeSize(.large...)  // At least Large
                .fontWeight(.bold)
                .foregroundColor(.green)  // ✅ Check contrast: should be ≥4.5:1 on background
                .accessibilityHeading(.h1)
            
            // Confidence with label
            HStack {
                Text("Erkennungssicherheit:")
                    .font(.system(.body))
                
                Text("\(plant.confidencePercentage)%")
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(plant.confidence > 0.8 ? .green : .orange)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(Text("Erkennungssicherheit"))
                    .accessibilityValue(Text("\(plant.confidencePercentage) Prozent"))
            }
            .accessibilityElement(children: .combine)
            
            // Description with semantic structure
            Text(plant.description)
                .font(.system(.body))
                .dynamicTypeSize(.large...)
                .lineSpacing(4)  // ✅ Improved readability
                .accessibilityElement(children: .combine)
                .accessibilityLabel(Text("Pflanzenbeschreibung"))
            
            // Action buttons with proper sizing
            HStack(spacing: 16) {
                Button(action: { }) {
                    Text("Speichern")
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)  // ✅ 48pt height ≥ 44pt minimum
                        .background(Color.green)
                        .foregroundColor(.white)
                }
                .accessibilityLabel(Text("Pflanze speichern"))
                
                Button(action: { }) {
                    Text("Erneut versuchen")
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color.gray)
                        .foregroundColor(.white)
                }
                .accessibilityLabel(Text("Erneut fotografieren"))
            }
        }
        .padding()
    }
}