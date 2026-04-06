struct EventListItem: View {
    @State var isExpanded = false
    let event: AnalyticsEvent
    
    var body: some View {
        VStack(alignment: .leading) {
            Button(action: { isExpanded.toggle() }) {
                HStack(spacing: 12) {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .frame(width: 20)
                        .accessibilityHidden(true) // Described by "expand/collapse"
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(event.eventName)
                            .font(.headline)
                        
                        Text(event.timestamp.formatted())
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .contentShape(Rectangle()) // ✅ Full-width tap target
                .frame(height: 44) // ✅ Minimum touch target
            }
            .accessibilityLabel("Event: \(event.eventName)")
            .accessibilityHint(isExpanded ? "Collapse details" : "Expand details")
            .accessibilityAddTraits(.isButton)
            
            if isExpanded {
                Divider()
                    .accessibilityHidden(true)
                
                VStack(alignment: .leading, spacing: 8) {
                    DetailRow(label: "Test ID", value: event.testID ?? "None")
                    DetailRow(label: "Variant", value: event.variantID ?? "None")
                    DetailRow(label: "User ID", value: event.userID)
                    
                    if !event.metadata.isEmpty {
                        Text("Metadata")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .accessibilityAddTraits(.isHeader)
                        
                        ForEach(event.metadata.sorted { $0.key < $1.key }, id: \.key) { key, value in
                            DetailRow(label: key, value: String(describing: value))
                        }
                    }
                }
                .padding(.top, 12)
                .accessibilityElement(children: .contain)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}
