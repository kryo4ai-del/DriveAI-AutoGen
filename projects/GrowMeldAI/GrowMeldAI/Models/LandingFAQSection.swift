import SwiftUI

struct LandingFAQSection: View {
    @StateObject private var contentService = LandingContentService.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("landing.faq.title".localized)
                .font(LandingTypography.sectionTitle)
                .foregroundColor(.primary)
                .padding(.horizontal, LandingMetrics.paddingLarge)
            
            VStack(spacing: LandingMetrics.paddingSmall) {
                ForEach(contentService.faqItems, id: \.question) { item in
                    FAQAccordionItem(item: item)
                }
            }
            .padding(.horizontal, LandingMetrics.paddingLarge)
        }
    }
}

struct FAQItem: Identifiable, Hashable {
    let id = UUID()
    let question: String
    let answer: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: FAQItem, rhs: FAQItem) -> Bool {
        lhs.id == rhs.id
    }
}

#Preview {
    FAQAccordionItem(
        item: FAQItem(
            question: "Sind die Fragen wirklich aus der offiziellen Prüfung?",
            answer: "Ja! Wir nutzen den aktuellen TÜV-Katalog 2024. Die Fragen entsprechen 1:1 dem Original."
        )
    )
}