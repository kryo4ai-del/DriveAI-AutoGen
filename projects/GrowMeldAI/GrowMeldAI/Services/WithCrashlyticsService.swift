// 1. Create a default instance provider
extension CrashlyticsService {
    static let `default` = CrashlyticsService(privacyService: .shared)
}

// 2. Provide fallback via ViewModifier
struct WithCrashlyticsService<Content: View>: View {
    let crashlytics: CrashlyticsService
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        content()
            .environment(crashlytics)
    }
}

// 3. Use in App.swift with explicit setup
@main

// 4. In previews/tests, provide explicitly
#Preview {
    WithCrashlyticsService(crashlytics: .mock) {
        QuestionView()
    }
}