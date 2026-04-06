// Define a driving-focused color palette
enum AppColors {
    static let dangerRed = Color(red: 0.9, green: 0.1, blue: 0.1)      // Stop sign red
    static let warningYellow = Color(red: 1.0, green: 0.8, blue: 0.0)  // Caution sign
    static let roadWhite = Color(red: 0.98, green: 0.98, blue: 0.98)   // Road markings
    static let safetyGreen = Color(red: 0.1, green: 0.7, blue: 0.2)    // Go sign
    static let asphaltGray = Color(red: 0.3, green: 0.3, blue: 0.35)   // Road surface
}

// Icon system tied to traffic signs
enum TrafficIcon {
    case warning      // Yellow triangle
    case stop         // Red octagon
    case rightOfWay   // White-on-red rectangle
    case mandatory    // Blue circle
    case prohibition  // Red circle with slash
    
    var sfSymbol: String {
        switch self {
        case .warning: return "triangle.fill"
        case .stop: return "octagon.fill"
        case .rightOfWay: return "rectangle.fill"
        case .mandatory: return "circle.fill"
        case .prohibition: return "circle.slash"
        }
    }
}

// Apply to question categories
struct CategoryCard: View {
    let category: Category
    let progress: UserProgress
    
    var trafficIcon: TrafficIcon {
        switch category.id {
        case "traffic-signs": return .warning
        case "right-of-way": return .rightOfWay
        case "fines": return .prohibition
        default: return .warning
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: trafficIcon.sfSymbol)
                    .font(.title)
                    .foregroundColor(categoryColor)
                
                Text(category.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            // Progress bar styled like a road
            ProgressView(value: progress.accuracy)
                .tint(categoryColor)
                .frame(height: 6)
                .cornerRadius(3)
            
            Text("\(Int(progress.accuracy * 100))% sicher")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(categoryColor.opacity(0.1)))
        .border(categoryColor.opacity(0.3), width: 2)
    }
    
    private var categoryColor: Color {
        switch category.id {
        case "traffic-signs": return AppColors.warningYellow
        case "right-of-way": return AppColors.dangerRed
        case "fines": return AppColors.dangerRed
        default: return AppColors.asphaltGray
        }
    }
}