struct DiagnosticActionCard: View {
    let action: DiagnosticAction
    let isPrimary: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Traffic sign visual: red triangle for critical, yellow for moderate
            ZStack {
                if action.isHighlighted {
                    Image(systemName: "triangle.fill")
                        .resizable()
                        .foregroundColor(.red)
                        .frame(width: 44, height: 44)
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemBackground))
                        .stroke(Color.blue, lineWidth: 2)
                }
                
                Image(systemName: action.icon)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(action.isHighlighted ? .white : .blue)
            }
            .frame(height: 60)
            
            Text(action.label)
                .font(.headline)
                .accessibilityAddTraits(.isHeader)
        }
        .padding()
        .background(isPrimary ? Color.blue.opacity(0.1) : Color(.systemBackground))
        .cornerRadius(12)
    }
}