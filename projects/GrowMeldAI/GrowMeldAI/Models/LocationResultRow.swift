struct LocationResultRow: View {
    @State var isExpanded: Bool = false
    
    var body: some View {
        Button(action: { isExpanded.toggle() }) {
            VStack(alignment: .leading, spacing: 8) {
                // Main row (existing)
                HStack {
                    Text(region.displayName)
                        .fontWeight(.medium)
                    Spacer()
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                    }
                }
                
                // Expand to show: "What will you learn?"
                if isExpanded {
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 12) {
                            Image(systemName: "book.fill")
                                .font(.caption)
                            Text("\(region.questionCount) Fragen zum Trainieren")
                                .font(.caption)
                        }
                        .foregroundColor(.blue)
                        
                        HStack(spacing: 12) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.caption)
                            Text("Prüfungsquote: 82% bestehen")
                                .font(.caption)
                        }
                        .foregroundColor(.green)
                    }
                    .padding(.top, 8)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
        }
    }
}