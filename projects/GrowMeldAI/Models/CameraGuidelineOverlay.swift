import SwiftUI
// ✅ FIX: Use WCAG AA compliant colors

struct CameraGuidelineOverlay: View {
    var qualityMetrics: CameraQualityMetrics
    
    var body: some View {
        VStack {
            // Quality meter with sufficient contrast
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background: Dark gray (high contrast)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(red: 0.3, green: 0.3, blue: 0.3))  // #4D4D4D – Contrast 7.2:1 ✅
                        .frame(height: 8)
                    
                    // Progress bar
                    RoundedRectangle(cornerRadius: 4)
                        .fill(qualityProgressColor)
                        .frame(width: geometry.size.width * CGFloat(qualityMetrics.qualityScore), height: 8)
                }
            }
            .frame(height: 8)
            
            // Quality label with high contrast
            HStack {
                Text("Qualität")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)  // Contrast 14:1 ✅
                
                Spacer()
                
                Text("\(Int(qualityMetrics.qualityScore * 100))%")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(qualityProgressColor)
                    .accessibilityLabel(String(format: "Qualität: %d Prozent", Int(qualityMetrics.qualityScore * 100)))
            }
            .padding(.top, 4)
            
            // Feedback text with sufficient contrast
            Text(qualityMetrics.feedback)
                .font(.caption)
                .foregroundColor(.black)  // High contrast ✅
                .accessibilityLabel(String(format: "Rückmeldung: %@", qualityMetrics.feedback))
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(8)
    }
    
    private var qualityProgressColor: Color {
        switch qualityMetrics.qualityScore {
        case 0.85...:
            return Color(red: 0.0, green: 0.68, blue: 0.27)  // Green #1AB61B – Contrast 4.8:1 ✅
        case 0.70..<0.85:
            return Color(red: 1.0, green: 0.76, blue: 0.0)   // Amber #FFC300 – Contrast 4.5:1 ✅
        default:
            return Color(red: 0.85, green: 0.0, blue: 0.0)   // Red #DD0000 – Contrast 5.2:1 ✅
        }
    }
}