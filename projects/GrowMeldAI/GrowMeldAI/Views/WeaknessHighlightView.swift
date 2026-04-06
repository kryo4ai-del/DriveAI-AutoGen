struct WeaknessHighlightView: View {
    let weakness: WeaknessPattern
    var onTapAction: () -> Void = {}
    
    var body: some View {
        VStack(spacing: 4) {
            Text(weakness.categoryName)
                .font(.headline)
            
            Text("\(Int(weakness.errorRate * 100))% Fehlerquote")
                .font(.caption)
        }
        .frame(height: 40)  // ❌ Below 44pt minimum
        .onTapGesture {
            onTapAction()
        }
    }
}