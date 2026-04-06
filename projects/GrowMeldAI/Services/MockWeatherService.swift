import Foundation

extension WeatherService {
    static func mock() -> WeatherServiceProtocol {
        MockWeatherService()
    }
}

private final class MockWeatherService: WeatherServiceProtocol {
    func fetchWeatherConditions() async throws -> WeatherConditions {
        try await Task.sleep(nanoseconds: 500_000_000) // Simulate network delay
        return WeatherConditions.mock
    }
}