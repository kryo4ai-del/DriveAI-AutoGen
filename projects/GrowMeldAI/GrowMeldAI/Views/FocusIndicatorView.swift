struct FocusIndicatorView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            // ✅ OUTER RING: High contrast (3:1 minimum)
            Rectangle()
                .stroke(
                    Color(colorScheme == .dark ? .yellow : .orange),
                    lineWidth: 3
                )
            
            // ✅ CORNER BRACKETS (more visible than circle)
            Canvas { context in
                let frame = CGRect(x: 20, y: 20, width: 80, height: 80)
                let cornerLength: CGFloat = 15
                let lineWidth: CGFloat = 3
                
                // Top-left
                var path = Path()
                path.move(to: CGPoint(x: frame.minX, y: frame.minY + cornerLength))
                path.addLine(to: CGPoint(x: frame.minX, y: frame.minY))
                path.addLine(to: CGPoint(x: frame.minX + cornerLength, y: frame.minY))
                
                context.stroke(
                    path,
                    with: .color(colorScheme == .dark ? .yellow : .orange),
                    lineWidth: lineWidth
                )
            }
            
            // ✅ INNER LABEL (VoiceOver only)
            Text("Fokus gesetzt")
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Fokus auf diesem Bereich gesperrt")
                .accessibilityHidden(true) // Visual indicator only
        }
        .frame(width: 120, height: 120)
        .accessibilityElement(children: .combine)
    }
}