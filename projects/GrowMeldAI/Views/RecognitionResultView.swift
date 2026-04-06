struct RecognitionResultView: View {
    let plant: PlantIdentity
    
    var body: some View {
        VStack(spacing: 16) {
            Text(plant.germanName)
                .font(.title)  // ❌ Fixed font size, doesn't scale with Dynamic Type
                .foregroundColor(.white)  // ❌ May fail contrast on light backgrounds
            
            Text("Konfidenz: \(plant.confidencePercentage)%")
                .font(.caption)  // ❌ Too small, won't scale
            
            Text(plant.description)
                .font(.body)
                // ❌ No minimum line height for readability
        }
    }
}