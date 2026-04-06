private func loadLocalizationBundle() throws {
    let languageCode = currentRegion.languageCode
    
    guard let path = Bundle.main.path(forResource: languageCode, ofType: "lproj"),
          let bundle = Bundle(path: path) else {
        throw LocalizationError.missingBundle(language: languageCode, 
                                              availableBundles: listAvailableBundles())
    }
    
    self.bundle = bundle
}

enum LocalizationError: LocalizedError {
    case missingBundle(language: String, availableBundles: [String])
    
    var errorDescription: String? {
        switch self {
        case .missingBundle(let lang, let available):
            return "Missing localization bundle for \(lang). Available: \(available)"
        }
    }
}

private func listAvailableBundles() -> [String] {
    let bundlePaths = Bundle.main.localizations
    return bundlePaths
}