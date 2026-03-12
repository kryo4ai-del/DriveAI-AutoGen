import Combine

class DesignSystemViewModel: ObservableObject {
    @Published var theme: AppTheme = .light {
        didSet {
            notifyThemeChange()
        }
    }

    private let themeService: ThemeService

    init(themeService: ThemeService) {
        self.themeService = themeService
        self.themeService.$currentTheme
            .assign(to: \.theme, on: self)
            .store(in: &cancellables)
    }

    func toggleTheme() {
        theme = (theme == .light) ? .dark : .light
    }

    private func notifyThemeChange() {
        themeService.updateTheme(theme)
    }

    private var cancellables = Set<AnyCancellable>()
}