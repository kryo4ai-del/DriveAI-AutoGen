struct MemoryStatsCard: View {
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Always visible: streak + quick stat
            HStack {
                VStack(alignment: .leading) {
                    Label("7 Tage", systemImage: "flame.fill")
                        .font(.headline)
                    Text("Erfolgsserie")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
            }
            
            // Progressive reveal on tap
            if isExpanded {
                Divider()
                
                // Insight 1: What enabled the streak?
                VStack(alignment: .leading, spacing: 8) {
                    Text("Diese Woche stark:")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    ForEach(topCategoriesThisWeek, id: \.self) { cat in
                        HStack {
                            Text(cat)
                            Spacer()
                            Text("92%")
                                .foregroundColor(.green)
                        }
                        .font(.caption)
                    }
                }
                
                Divider()
                
                // Insight 2: What's at risk?
                VStack(alignment: .leading, spacing: 8) {
                    Text("Auffrischen nötig:")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    ForEach(categoriesNeedingReview, id: \.self) { cat in
                        HStack {
                            Text(cat)
                            Spacer()
                            Text("4 Tage bis Review")
                                .font(.caption2)
                                .foregroundColor(.orange)
                        }
                    }
                }
                
                // CTA: Jump to timeline
                Button(action: { /* navigate */ }) {
                    Text("Zur Übersicht")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
        }
        .onTapGesture { isExpanded.toggle() }
    }
}