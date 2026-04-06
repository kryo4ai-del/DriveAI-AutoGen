import SwiftUI

struct MaintenanceStatusCardView: View {
    let check: CategoryMaintenanceCheck
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            headerView
            progressView
            motivationalView
        }
        .padding(12)
        .background(Color(.systemBackground))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray3), lineWidth: 1)
        )
        .cornerRadius(12)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Wartung: \(check.categoryName)")
        .accessibilityValue(accessibilityDescription)
    }
    
    // MARK: - Subviews
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(check.categoryName)
                    .font(.headline)
                    .lineLimit(2)
                
                statusBadge
            }
            
            Spacer()
            
            daysSinceView
        }
    }
    
    private var statusBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: check.status.statusIcon)
                .font(.caption2)
                .foregroundColor(.white)
            
            Text(check.status.displayName)
                .font(.caption)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(check.status.color)
        .cornerRadius(6)
    }
    
    private var daysSinceView: some View {
        VStack(alignment: .trailing, spacing: 2) {
            if check.daysSinceLastPractice != Int.max {
                Text("\(check.daysSinceLastPractice)d")
                    .font(.caption2)
                    .fontWeight(.semibold)
                
                Text("ago")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            } else {
                Text("—")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var progressView: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("maintenance.progress.label")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("maintenance.days.until \(daysUntilNext)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray4))
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(check.status.color)
                        .frame(width: geometry.size.width * check.progressToNextRecommendation)
                }
            }
            .frame(height: 6)
        }
    }
    
    private var motivationalView: some View {
        Text(check.status.motivationalMessage)
            .font(.caption)
            .foregroundColor(.secondary)
            .italic()
            .lineLimit(3)
    }
    
    // MARK: - Computed Properties
    
    private var daysUntilNext: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: check.nextRecommendedDate)
        return max(0, components.day ?? 0)
    }
    
    private var accessibilityDescription: String {
        let statusText = check.status.displayName
            .replacingOccurrences(of: "🔥", with: "")
            .replacingOccurrences(of: "⏰", with: "")
            .replacingOccurrences(of: "😴", with: "")
            .trimmingCharacters(in: .whitespaces)
        
        let daysText: String
        if check.daysSinceLastPractice == Int.max {
            daysText = "Nie geübt"
        } else {
            daysText = "\(check.daysSinceLastPractice) Tage seit letztem Üben"
        }
        
        let progressPercent = Int(check.progressToNextRecommendation * 100)
        
        return "\(statusText). \(daysText). Fortschritt: \(progressPercent)%."
    }
}

#Preview {
    VStack(spacing: 16) {
        MaintenanceStatusCardView(
            check: CategoryMaintenanceCheck(
                id: "1",
                categoryName: "Verkehrszeichen",
                status: .active,
                lastPracticeDate: Calendar.current.date(byAdding: .day, value: -3, to: Date()),
                daysSinceLastPractice: 3,
                nextRecommendedDate: Calendar.current.date(byAdding: .day, value: 4, to: Date()) ?? Date(),
                progressToNextRecommendation: 0.43
            )
        )
        
        MaintenanceStatusCardView(
            check: CategoryMaintenanceCheck(
                id: "2",
                categoryName: "Vorfahrtsregeln",
                status: .needsMaintenance,
                lastPracticeDate: Calendar.current.date(byAdding: .day, value: -10, to: Date()),
                daysSinceLastPractice: 10,
                nextRecommendedDate: Calendar.current.date(byAdding: .day, value: 4, to: Date()) ?? Date(),
                progressToNextRecommendation: 0.86
            )
        )
    }
    .padding()
}