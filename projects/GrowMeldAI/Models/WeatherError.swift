import Foundation

enum WeatherError: Error, LocalizedError {
    case invalidURL
    case networkError(Error)
    case decodingError
    case apiError(String)
    case locationUnavailable

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Der Server konnte die Anfrage nicht verarbeiten. Bitte versuche es später erneut."
        case .networkError(let error):
            return "Netzwerkfehler: \(error.localizedDescription)"
        case .decodingError:
            return "Die Wetterdaten konnten nicht gelesen werden. Bitte versuche es später erneut."
        case .apiError(let message):
            return "Wetterdienst-Fehler: \(message)"
        case .locationUnavailable:
            return "Standort nicht verfügbar. Übe mit unseren Standard-Fragen."
        }
    }
}

protocol WeatherServiceProtocol {
    func fetchWeatherConditions() async throws -> WeatherConditions
}

struct WeatherConditions: Codable, Equatable {
    let temperature: Double
    let precipitation: Bool
    let visibility: Double
    let windSpeed: Double
    let conditions: String

    static let mock = WeatherConditions(
        temperature: 15.0,
        precipitation: false,
        visibility: 10.0,
        windSpeed: 5.0,
        conditions: "klar"
    )
}

final class WeatherService: WeatherServiceProtocol {
    private let baseURL: URL
    private let apiKey: String

    init(baseURL: URL = URL(string: "https://api.openweathermap.org/data/2.5")!,
         apiKey: String = ProcessInfo.processInfo.environment["OPENWEATHER_API_KEY"] ?? "") {
        self.baseURL = baseURL
        self.apiKey = apiKey
    }

    func fetchWeatherConditions() async throws -> WeatherConditions {
        var components = URLComponents(url: baseURL.appendingPathComponent("weather"), resolvingAgainstBaseURL: true)
        components?.queryItems = [
            URLQueryItem(name: "q", value: "Berlin,DE"),
            URLQueryItem(name: "appid", value: apiKey),
            URLQueryItem(name: "units", value: "metric")
        ]

        guard let url = components?.url else {
            throw WeatherError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw WeatherError.apiError("Server returned invalid response")
        }

        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(WeatherResponse.self, from: data).toWeatherConditions()
        } catch {
            throw WeatherError.decodingError
        }
    }
}

private struct WeatherResponse: Codable {
    let weather: [Weather]
    let main: Main
    let wind: Wind
    let visibility: Int
    let name: String

    func toWeatherConditions() -> WeatherConditions {
        WeatherConditions(
            temperature: main.temp,
            precipitation: weather.contains { $0.main == "Rain" || $0.main == "Snow" },
            visibility: Double(visibility) / 1000.0,
            windSpeed: wind.speed,
            conditions: weather.first?.description ?? "unbekannt"
        )
    }
}

private struct Weather: Codable {
    let main: String
    let description: String
}

private struct Main: Codable {
    let temp: Double
}

private struct Wind: Codable {
    let speed: Double
}