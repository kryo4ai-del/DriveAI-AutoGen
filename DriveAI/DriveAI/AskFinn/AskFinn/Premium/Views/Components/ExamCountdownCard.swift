import SwiftUI

struct ExamCountdownCard: View {
    let countdown: ExamCountdown
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("exam.countdown", bundle: nil)
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
            }
            
            HStack(alignment: .center, spacing: 16) {
                // Big countdown number
                VStack(alignment: .center, spacing: 4) {
                    Text("\(countdown.daysRemaining)")
                        .font(.system(size: 44, weight: .bold, design: .default))
                        .foregroundColor(statusColor)
                    
                    Text("exam.days.label", bundle: nil)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(minWidth: 90)
                
                Divider()
                    .frame(height: 60)
                
                // Details
                VStack(alignment: .leading, spacing: 8) {
                    Text("exam.date.label", bundle: nil)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(countdown.examDate.formatted(date: .abbreviated, time: .omitted))
                        .font(.body)
                        .fontWeight(.semibold)
                    
                    statusBadge
                }
                
                Spacer()
            }
        }
        .padding(16)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(.systemBlue).opacity(0.08),
                    Color(.systemCyan).opacity(0.04)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray3).opacity(0.3), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            Text(
                String(format: NSLocalizedString(
                    "exam.countdown.a11y",
                    comment: "Exam countdown label"
                ), countdown.daysRemaining)
            )
        )
    }
    
    @ViewBuilder
    private var statusBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: statusIcon)
                .font(.caption2)
            Text(countdown.status.description)
                .font(.caption2)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(statusBadgeBackground)
        .foregroundColor(statusBadgeColor)
        .cornerRadius(4)
    }
    
    private var statusColor: Color {
        switch countdown.status {
        case .upcoming: .blue
        case .imminent: .orange
        case .today: .red
        case .passed: .green
        }
    }
    
    private var statusBadgeColor: Color {
        switch countdown.status {
        case .upcoming: .blue
        case .imminent: .orange
        case .today: .red
        case .passed: .green
        }
    }
    
    private var statusBadgeBackground: Color {
        switch countdown.status {
        case .upcoming: Color.blue.opacity(0.12)
        case .imminent: Color.orange.opacity(0.12)
        case .today: Color.red.opacity(0.12)
        case .passed: Color.green.opacity(0.12)
        }
    }
    
    private var statusIcon: String {
        switch countdown.status {
        case .upcoming: "calendar"
        case .imminent: "exclamationmark.circle.fill"
        case .today: "star.fill"
        case .passed: "checkmark.circle.fill"
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        ExamCountdownCard(
            countdown: ExamCountdown(
                daysRemaining: 14,
                examDate: Date().addingTimeInterval(14 * 86400),
                status: .upcoming
            )
        )
        
        ExamCountdownCard(
            countdown: ExamCountdown(
                daysRemaining: 3,
                examDate: Date().addingTimeInterval(3 * 86400),
                status: .imminent
            )
        )
    }
    .padding()
}