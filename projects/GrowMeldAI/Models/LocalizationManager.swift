class LocalizationManager: ObservableObject {
    @Published var currentLanguage: Language {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: "appLanguage")
            // ❌ Dual notification mechanism
            NotificationCenter.default.post(name: NSNotification.Name("LanguageChanged"), object: nil)
        }
    }
}

// App.swift attempts to refresh both ways:
@StateObject var localizationManager = LocalizationManager.shared

var body: some Scene {
    WindowGroup {
        ContentView()
            .environmentObject(localizationManager)  // ✅ Subscribes to @Published
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("LanguageChanged"))) { _ in
                // ❌ Also listens to notification
                // Question: Which triggers View refresh first? Race condition.
            }
    }
}