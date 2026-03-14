import SwiftUI

struct ResultHeader: View {
    let result: SimulationResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(result.isPassed ? "PASSED" : "FAILED")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("\(Int(result.overallScore))%")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Image(systemName: result.isPassed ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.white)
            }
            
            HStack {
                Image(systemName: "calendar")
                    .font(.caption)
                Text(formattedDate)
                    .font(.caption)
            }
            .foregroundColor(.white.opacity(0.8))
        }
        .padding(16)
        .background(backgroundColor)
        .cornerRadius(12)
    }
    
    private var backgroundColor: Color {
        result.isPassed ? Color(red: 0.2, green: 0.8, blue: 0.2) : Color(red: 0.8, green: 0.2, blue: 0.2)
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: result.timestamp)
    }
}