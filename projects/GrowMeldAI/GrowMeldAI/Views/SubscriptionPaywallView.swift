struct SubscriptionPaywallView: View {
    @Environment(\.dismiss) var dismiss
    @State private var focusedPlanId: String?
    
    let plans: [SubscriptionPlan]
    let onPurchase: (SubscriptionPlan) async -> Result<Void, PurchaseError>
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // MARK: - Scrim (blocks background but allows dismiss)
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .accessibilityHidden(true)
                .onTapGesture { dismiss() }
            
            // MARK: - Modal Card
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Premium-Abo", comment: "Paywall title")
                        .font(.headline)
                        .accessibilityAddTraits(.isHeader)
                    
                    Spacer()
                    
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .frame(width: 44, height: 44)
                            .contentShape(Circle())
                    }
                    .accessibilityLabel(String(localized: "close_button", defaultValue: "Schließen"))
                    .accessibilityHint(String(localized: "close_hint", defaultValue: "Schließt den Abonnement-Dialog"))
                    .keyboardShortcut(.cancelAction)
                }
                .padding()
                
                Divider()
                    .accessibilityHidden(true)
                
                // Plans Container
                ScrollView {
                    VStack(spacing: 12) {
                        Text("Wählen Sie einen Plan:", comment: "Plan selection instruction")
                            .font(.subheadline)
                            .accessibilityAddTraits(.isHeader)
                        
                        ForEach(plans, id: \.id) { plan in
                            PricingTierCard(
                                plan: plan,
                                isSelected: focusedPlanId == plan.id,
                                onSelect: { focusedPlanId = plan.id }
                            )
                            // CRITICAL: Each card is individually focusable
                            .accessibilityElement(children: .combine)
                            .onTapGesture { focusedPlanId = plan.id }
                        }
                    }
                    .padding()
                }
                
                Divider()
                    .accessibilityHidden(true)
                
                // Subscribe Button
                if let selectedPlan = plans.first(where: { $0.id == focusedPlanId }) {
                    SubscribeButton(
                        plan: selectedPlan,
                        onPurchase: { await onPurchase(selectedPlan) }
                    )
                    .padding()
                }
            }
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .padding()
            // CRITICAL: Do NOT use .accessibilityElement(children: .contain)
            // Instead, let SwiftUI handle focus naturally
        }
        .onAppear {
            focusedPlanId = plans.first?.id
            
            // Announce modal with escape instruction
            UIAccessibility.post(
                notification: .screenChanged,
                argument: "Abonnement-Dialog. Drücken Sie Escape oder tippen Sie auf Schließen zum Beenden."
            )
        }
    }
}