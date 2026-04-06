// Views/IAP/SubscriptionStatusView.swift
struct SubscriptionStatusView: View {
    @StateObject var viewModel: SubscriptionStatusViewModel
    
    var body: some View {
        if let subscription = viewModel.subscription {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Premium Active")
                        .font(.headline)
                }
                
                if let expiresAt = subscription.expiresAt {
                    Text("Expires \(expiresAt.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let daysRemaining = viewModel.daysRemaining, daysRemaining < 7 {
                    Text("\(daysRemaining) days remaining")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
            .padding()
            .background(Color(.systemGreen).opacity(0.1))
            .cornerRadius(8)
        } else {
            Text("Upgrade to Premium for more features")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}