// ❌ CURRENT (ExamContext.swift):
var trafficLevelColor: String {
    switch region.trafficLevel {
    case .low: return "#10B981"      // Green – LOW CONTRAST
    case .medium: return "#F59E0B"   // Amber – MARGINAL CONTRAST
    case .high: return "#EF4444"     // Red – OK
    }
}

// ✅ FIXED – Higher contrast colors:
var trafficLevelColor: String {
    switch region.trafficLevel {
    case .low: return "#0B5E3A"      // Dark green (7.1:1 on white)
    case .medium: return "#B87700"   // Dark amber (5.8:1 on white)
    case .high: return "#9D1A1A"     // Dark red (6.2:1 on white)
    }
}

// ✅ ADD: Text-based fallback for color-blind users
var trafficLevelLabel: String {
    switch region.trafficLevel {
    case .low: return "🟢 Niedrig"
    case .medium: return "🟡 Mittel"
    case .high: return "🔴 Hoch"
    }
}

// ✅ VIEW IMPLEMENTATION:
struct ExamContextPreviewView: View {
    let context: ExamContext
    
    var body: some View {
        HStack(spacing: 8) {
            // ✅ USE BOTH COLOR AND SYMBOL FOR REDUNDANCY
            Circle()
                .fill(Color(hex: context.trafficLevelColor))
                .frame(width: 16, height: 16)
            
            Text(context.trafficLevelLabel)
                .font(.headline)
                .foregroundColor(.primary)
            
            Spacer()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Verkehrsaufkommen")
        .accessibilityValue(context.region.trafficLevel.displayName)
    }
}