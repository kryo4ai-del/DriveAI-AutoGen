struct MotivationalHeader: View {
    let profile: UserProfile
    
    var readiness: ExamReadiness {
        ExamReadiness(
            userProfile: profile,
            allCategoryStats: profile.categoryPerformance
        )
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Nur noch \(profile.daysUntilExam) Tag\(profile.daysUntilExam == 1 ? "" : "e")")
                    .font(.title3)  // ✓ Use semantic font sizes, not .system(size:)
                    .fontWeight(.bold)
                
                Text(readiness.status.emoji)
                    .font(.title)
                    .accessibilityHidden(true)
                
                Spacer()
            }
            
            Text(readiness.motivationalMessage)
                .font(.body)  // ✓ Scales with Dynamic Type
                .lineLimit(nil)  // ✓ Allow wrapping
                .fixedSize(horizontal: false, vertical: true)  // ✓ Accommodate larger text
                .foregroundColor(.primary)
            
            // ✓ Actionable CTA
            Button(action: {}) {
                Label("Jetzt üben", systemImage: "play.circle.fill")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(6)
                    .frame(minHeight: 44)  // ✓ Touch target
            }
            .accessibilityLabel("Jetzt mit dem Üben beginnen")
            .accessibilityHint("Startet die Praxis-Session für deine schwächsten Kategorien")
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(8)
    }
}