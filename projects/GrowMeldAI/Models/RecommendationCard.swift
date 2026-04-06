struct RecommendationCard: View {
    @ObservedObject var viewModel: HomeViewModel
    var onStartQuiz: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        if !viewModel.recommendationText.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                // Header with close button
                HStack(spacing: 8) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(.orange)
                    
                    Text("Personalisierte Empfehlung")
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Button(action: { viewModel.dismissRecommendation() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
                
                // Recommendation text
                Text(viewModel.recommendationText)
                    .font(.system(.body, design: .default))
                    .lineLimit(4)
                    .foregroundColor(.primary)
                
                // CTA Button
                Button(action: onStartQuiz) {
                    HStack(spacing: 8) {
                        Image(systemName: "play.fill")
                        Text("Jetzt üben")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
            .padding()
            .background(
                Color(colorScheme == .dark 
                    ? UIColor.systemGray6 
                    : UIColor.systemGray5)
            )
            .cornerRadius(14)
            .transition(.opacity.combined(with: .move(edge: .top)))  // ✅ Fixed
            .padding()
        }
    }
}

// ✅ Add Preview for Xcode canvas
#Preview {
    @StateObject var mockProgress = MockProgressTrackingService()
    @StateObject var mockData = MockLocalDataService()
    @StateObject var mockVM = HomeViewModel(
        dataService: mockData,
        progressService: mockProgress,
        readinessViewModel: ReadinessViewModel(progressService: mockProgress)
    )
    
    return RecommendationCard(
        viewModel: mockVM,
        onStartQuiz: { print("Start quiz tapped") }
    )
    .preferredColorScheme(.light)
}