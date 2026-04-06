struct ProgressRingView: View {
    let progress: Double  // 0.0 to 1.0
    let label: String
    
    var body: some View {
        ZStack {
            // Visual ring
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 8)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.correctAnswer, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut, value: progress)
            
            // Center text
            Text("\(Int(progress * 100))%")
                .font(.headline)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(label)
        .accessibilityValue("\(Int(progress * 100))% complete")
        .accessibilityHint("Progress through \(label)")
    }
}