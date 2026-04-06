import SwiftUI
struct StreakCard: View {
    let current: Int
    let longest: Int
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Trainingssträhne")
                        .font(.headline)
                    Text("\(current) Tage")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                Text(streakEmoji)
                    .font(.system(size: 44))  // ✓ Emoji large enough for recognition
                    .accessibilityLabel(streakLabel)
            }
            .padding()
            .frame(minHeight: 60)  // ✓ Touch target minimum 44pt
            
            HStack {
                Label("Rekord: \(longest) Tage", systemImage: "flag.fill")
                    .frame(minHeight: 44)  // ✓ Touch target
                    .accessibilityElement(children: .combine)
            }
            .padding()
        }
        .background(Color(.secondarySystemBackground))
        .cornerRadius(8)
    }
    
    private var streakLabel: String {
        switch current {
        case 0:
            return "Keine Strähne. Beginne heute!"
        case 1...6:
            return "\(current) Tage Feuer-Strähne"
        case 7...29:
            return "\(current) Tage Doppel-Feuer-Strähne"
        case 30...59:
            return "\(current) Tage Dreifach-Feuer-Strähne"
        default:
            return "\(current) Tage Trophäen-Strähne"
        }
    }
    
    private var streakEmoji: String {
        switch current {
        case 0: return "🚀"
        case 1...6: return "🔥"
        case 7...29: return "🔥🔥"
        case 30...59: return "🔥🔥🔥"
        default: return "🏆"
        }
    }
}