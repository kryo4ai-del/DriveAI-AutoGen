import SwiftUI

class TrialStateManager: ObservableObject {
    static let shared = TrialStateManager()
    @Published var isTrialActive: Bool = false
    @Published var daysRemaining: Int = 0
}

struct TrialBadge: View {
    @ObservedObject var trialManager: TrialStateManager
    init(trialManager: TrialStateManager = TrialStateManager.shared) {
        self._trialManager = ObservedObject(wrappedValue: trialManager)
    }
    var body: some View {
        if trialManager.isTrialActive {
            Text("Trial: \(trialManager.daysRemaining) days")
                .font(.caption)
                .padding(4)
                .background(Color.orange.opacity(0.2))
                .cornerRadius(4)
        }
    }
}
