import Foundation
import SwiftUI

// MARK: - Supporting Types

enum AppRegion: String, CaseIterable {
    case dach = "dach"
    case us = "us"
    case uk = "uk"
}

struct RegionMetadata {
    let name: String
    let locale: Locale
    let currencyCode: String

    static func metadata(for region: AppRegion) -> RegionMetadata {
        switch region {
        case .dach:
            return RegionMetadata(name: "DACH", locale: Locale(identifier: "de_DE"), currencyCode: "EUR")
        case .us:
            return RegionMetadata(name: "United States", locale: Locale(identifier: "en_US"), currencyCode: "USD")
        case .uk:
            return RegionMetadata(name: "United Kingdom", locale: Locale(identifier: "en_GB"), currencyCode: "GBP")
        }
    }
}

struct RegionConfig {
    let minimumAge: Int
    let regionCode: String
    let supportsMetric: Bool

    static func config(for region: AppRegion) -> RegionConfig {
        switch region {
        case .dach:
            return RegionConfig(minimumAge: 18, regionCode: "DE", supportsMetric: true)
        case .us:
            return RegionConfig(minimumAge: 16, regionCode: "US", supportsMetric: false)
        case .uk:
            return RegionConfig(minimumAge: 17, regionCode: "GB", supportsMetric: true)
        }
    }
}

enum UserDefaultsKey {
    static let selectedRegion = "com.growmeldai.selectedRegion"
}

// MARK: - RegionManager

@MainActor
final class RegionManager: ObservableObject {
    @Published private(set) var currentRegion: AppRegion
    @Published private(set) var regionMetadata: RegionMetadata
    @Published private(set) var regionConfig: RegionConfig

    private let defaults: UserDefaults

    init(
        initialRegion: AppRegion = .dach,
        userDefaults: UserDefaults = .standard
    ) {
        self.defaults = userDefaults

        let saved = userDefaults.string(forKey: UserDefaultsKey.selectedRegion) ?? "dach"
        let region = AppRegion(rawValue: saved) ?? initialRegion

        self.currentRegion = region
        self.regionMetadata = RegionMetadata.metadata(for: region)
        self.regionConfig = RegionConfig.config(for: region)
    }

    func switchRegion(_ region: AppRegion) async {
        guard region != currentRegion else { return }

        await MainActor.run {
            self.currentRegion = region
            self.regionMetadata = RegionMetadata.metadata(for: region)
            self.regionConfig = RegionConfig.config(for: region)
            self.persistRegion()
        }
    }

    private func persistRegion() {
        defaults.set(currentRegion.rawValue, forKey: UserDefaultsKey.selectedRegion)
    }
}