import SwiftUI

struct CameraQualityMetrics {
    var qualityScore: Double
    var feedback: String
}

struct CameraGuidelineOverlay: View {
    var qualityMetrics: CameraQualityMetrics

    var body: some View {
        VStack {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(red: 0.3, green: 0.3, blue: 0.3))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(qualityProgressColor)
                        .frame(width: geometry.size.width * CGFloat(qualityMetrics.qualityScore), height: 8)
                }
            }
            .frame(height: 8)

            HStack {
                Text("Qualität")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)

                Spacer()

                Text("\(Int(qualityMetrics.qualityScore * 100))%")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(qualityProgressColor)
                    .accessibilityLabel(String(format: "Qualität: %d Prozent", Int(qualityMetrics.qualityScore * 100)))
            }
            .padding(.top, 4)

            Text(qualityMetrics.feedback)
                .font(.caption)
                .foregroundColor(.black)
                .accessibilityLabel(String(format: "Rückmeldung: %@", qualityMetrics.feedback))
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(8)
    }

    private var qualityProgressColor: Color {
        switch qualityMetrics.qualityScore {
        case 0.85...:
            return Color(red: 0.0, green: 0.68, blue: 0.27)
        case 0.70..<0.85:
            return Color(red: 1.0, green: 0.76, blue: 0.0)
        default:
            return Color(red: 0.85, green: 0.0, blue: 0.0)
        }
    }
}