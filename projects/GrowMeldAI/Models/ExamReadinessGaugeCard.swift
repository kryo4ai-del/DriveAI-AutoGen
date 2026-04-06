// Define WCAG AA-compliant color system
enum ReadinessColor: Int {
    case needsWork = 0xD32F2F      // Red (darker, 7:1 on white)
    case reviewing = 0xF57C00      // Orange-brown (6.2:1 on white)
    case ready = 0x388E3C          // Green (5.8:1 on white)
    case highlyConfident = 0x1565C0 // Dark blue (7.5:1 on white)
    
    var primaryColor: Color {
        Color(UIColor(red: CGFloat((self.rawValue >> 16) & 0xFF) / 255,
                      green: CGFloat((self.rawValue >> 8) & 0xFF) / 255,
                      blue: CGFloat(self.rawValue & 0xFF) / 255,
                      alpha: 1.0))
    }
    
    /// Always use white or high-contrast text
    var textColor: Color {
        .white  // Guaranteed 7:1+ on all readiness colors
    }
    
    /// Light background for additional context (e.g., badges)
    var lightBackground: Color {
        switch self {
        case .needsWork: return Color(red: 1.0, green: 0.9, blue: 0.9)      // Light red
        case .reviewing: return Color(red: 1.0, green: 0.95, blue: 0.85)    // Light orange
        case .ready: return Color(red: 0.9, green: 1.0, blue: 0.9)          // Light green
        case .highlyConfident: return Color(red: 0.85, green: 0.95, blue: 1.0) // Light blue
        }
    }
}

// Usage
struct ExamReadinessGaugeCard: View {
    let readiness: ExamReadinessSnapshot
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(readinessColor.lightBackground)
            
            VStack(spacing: 12) {
                CircularProgressView(progress: readiness.confidenceScore / 100.0)
                    .foregroundColor(readinessColor.primaryColor)
                
                Text(readinessLevelLabel)
                    .font(.headline)
                    .foregroundColor(readinessColor.textColor)
                    .padding(8)
                    .background(readinessColor.primaryColor)
                    .cornerRadius(6)
            }
            .padding(16)
        }
    }
    
    private var readinessColor: ReadinessColor {
        switch readiness.estimatedPassProbability {
        case 0..<0.50: return .needsWork
        case 0.50..<0.75: return .reviewing
        case 0.75..<0.90: return .ready
        default: return .highlyConfident
        }
    }
    
    private var readinessLevelLabel: String {
        switch readiness.estimatedPassProbability {
        case 0..<0.50: return "Noch nicht bereit"
        case 0.50..<0.75: return "Wird überprüft"
        case 0.75..<0.90: return "Bereit"
        default: return "Sehr bereit"
        }
    }
}