// Create a safe animation helper
@Environment(\.reduceMotion) var reduceMotion

extension View {
    func safeAnimation() -> some View {
        if reduceMotion {
            return self.animation(nil, value: UUID())
        } else {
            return self.animation(.easeInOut(duration: 0.3), value: UUID())
        }
    }
}

// Usage:
struct ExamResultsScreen: View {
    @State var showResult = false
    
    var body: some View {
        VStack {
            if showResult {
                ResultCard(result: result)
                    .transition(.opacity)  // No scale/move animations
            }
        }
        .onAppear {
            if reduceMotion {
                showResult = true  // Instant
            } else {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showResult = true
                }
            }
        }
    }
}