import SwiftUI

struct DashboardScreen: View {
    @ObservedObject var profileViewModel: ProfileViewModel

    var body: some View {
        VStack {
            if let daysUntilExam = profileViewModel.daysUntilExam {
                Text("🗓️ \(daysUntilExam) Tage bis zur Prüfung")
                    .font(.headline)
            }

            Text("Score: \(profileViewModel.passRateFormatted)")
            Text(profileViewModel.streakStatusText)
        }
    }
}