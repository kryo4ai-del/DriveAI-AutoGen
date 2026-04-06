struct FAQAccordionItem: View {
    let item: FAQItem
    @State private var isExpanded: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: { withAnimation(.easeInOut(duration: 0.2)) { isExpanded.toggle() } }) {
                HStack {
                    Text(item.question)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(nil)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.secondary)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
            
            if isExpanded {
                Divider()
                    .padding(.vertical, 8)
                
                Text(item.answer)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.secondary)
                    .lineLimit(nil)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(Color(.systemGray6).opacity(0.5))
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    FAQAccordionItem(
        item: FAQItem(
            question: "Sample question?",
            answer: "Sample answer here."
        )
    )
}