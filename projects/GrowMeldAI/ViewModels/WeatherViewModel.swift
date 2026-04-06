import Foundation
import Combine
import SwiftUI

@MainActor
final class WeatherViewModel: ObservableObject {
    @Published var weatherConditions: WeatherConditions?
    @Published var isLoading = false
    @Published var error: WeatherError?

    private let weatherService: WeatherServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    init(weatherService: WeatherServiceProtocol = WeatherService()) {
        self.weatherService = weatherService
    }

    func fetchWeather() async {
        isLoading = true
        error = nil

        do {
            weatherConditions = try await weatherService.fetchWeatherConditions()
        } catch {
            if let weatherError = error as? WeatherError {
                self.error = weatherError
            } else {
                self.error = .apiError(error.localizedDescription)
            }
        }

        isLoading = false
    }

    func mockWeather() {
        weatherConditions = .mock
    }
}