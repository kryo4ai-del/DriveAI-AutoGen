import SwiftUI

struct UserInfoView: View {
    let user: User

    private var formattedDate: String {
        DateFormatter.localizedString(from: user.examDate, dateStyle: .medium, timeStyle: .none)
    }

    private var daysText: String {
        let days = user.daysUntilExam
        switch days {
        case 0:  return "Exam day!"
        case 1:  return "1 day left"
        default: return "\(days) days left"
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "calendar.badge.clock")
                .font(.title3)
                .foregroundColor(.blue)
            VStack(alignment: .leading, spacing: 2) {
                Text("Exam: \(formattedDate)")
                    .font(.subheadline)
                    .bold()
                Text(daysText)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}
