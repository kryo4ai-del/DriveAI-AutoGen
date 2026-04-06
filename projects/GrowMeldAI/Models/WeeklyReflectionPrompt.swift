import SwiftUI
struct WeeklyReflectionPrompt: View {
    var body: some View {
        VStack {
            Text("Diese Woche hast du 12 Momente erfasst")
                .font(.custom("Georgia", size: 18))  // ← Fixed size, ignores Dynamic Type
                .lineLimit(2)  // ← May truncate at large text sizes
            
            Text("8 halfen dir, dich sicherer zu fühlen")
                .font(.caption)
            
            HStack {
                ForEach(EmotionalTag.allCases, id: \.self) { tag in
                    Text(tag.emoji)  // ← No alternative text
                        .font(.system(size: 20))  // ← Fixed size
                }
            }
            
            Button("Welcher Moment hat dich am meisten weiterbracht?") {
                // open reflection modal
            }
            .font(.caption2)  // ← Too small for accessibility
        }
    }
}