// MetaTrackingBackend.swift
import Foundation

/// Meta Conversions API backend for tracking events.
public final class MetaTrackingBackend: TrackingBackend {
    private let baseURL = URL(string: "https://graph.facebook.com/v19.0/")!
    private let accessToken: String
    private var events: [TrackingEvent] = []

    public init(accessToken: String) {
        self.accessToken = accessToken
    }

    public func track(_ event: TrackingEvent) {
        events.append(event)
    }

    public func flush() async throws {
        guard !events.isEmpty else { return }

        let payload = MetaConversionPayload(events: events)
        let request = try createRequest(payload: payload)

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        events.removeAll()
    }

    private func createRequest(payload: MetaConversionPayload) throws -> URLRequest {
        var components = URLComponents(url: baseURL.appendingPathComponent("collect"), resolvingAgainstBaseURL: true)!
        components.queryItems = [
            URLQueryItem(name: "access_token", value: accessToken),
            URLQueryItem(name: "event", value: "Lead"),
            URLQueryItem(name: "noscript", value: "1")
        ]

        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(payload)

        return request
    }
}

private struct MetaConversionPayload: Codable {
    let events: [TrackingEvent]
    let dataProcessingOptions: [String] = ["LDU"]
    let dataProcessingCountry: Int = 1
    let dataProcessingState: Int = 1000
}