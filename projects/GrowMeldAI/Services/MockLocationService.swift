// Services/MockLocationService.swift
import Foundation
import CoreLocation

final class MockLocationService: LocationService {
    func getCurrentRegion() async throws -> PLZRegion {
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5s delay
        return PLZRegion(id: "BY", name: "Bayern", plzRanges: ["80000-99999"])
    }
}
