// ❌ NO TABLE SEMANTICS
struct CategoryMetricsView: View {
    let metrics: [String: RetentionMetrics.CategoryMetrics]
    
    var body: some View {
        List {
            ForEach(metrics.sorted(by: { $0.key < $1.key }), id: \.key) { category, stats in
                HStack {
                    Text(category)
                    Spacer()
                    Text("\(stats.tracked) questions")
                    Text("\(Int(stats.accuracy * 100))%")  // ❌ No header relationship
                    Text("\(stats.dueCount)")  // ❌ No header relationship
                }
            }
        }
    }
}