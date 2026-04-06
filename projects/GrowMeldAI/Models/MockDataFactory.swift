// MARK: - Models/MockDataFactory.swift

import Foundation

// MARK: - Supporting Types

enum Country: String, CaseIterable {
    case australia = "AU"
    case canada = "CA"
}

struct Region: Identifiable, Equatable {
    let id: String
    let name: String
    let subtitle: String
    let isoCode: String
    let questionCount: Int
    let minPassScore: Int
}

// MARK: - RegionRepository Protocol

class RegionRepository {
    enum Error: Swift.Error {
        case networkUnavailable
        case regionNotFound
        case unknown(String)
    }

    func regions(for country: Country) async throws -> [Region] {
        return []
    }
}

// MARK: - Mock Data Factory

struct MockDataFactory {
    static let australiaCountry = Country.australia
    static let canadaCountry = Country.canada

    static let nsw = Region(
        id: "NSW",
        name: "New South Wales",
        subtitle: "Sydney",
        isoCode: "AU-NSW",
        questionCount: 200,
        minPassScore: 75
    )

    static let victoria = Region(
        id: "VIC",
        name: "Victoria",
        subtitle: "Melbourne",
        isoCode: "AU-VIC",
        questionCount: 195,
        minPassScore: 75
    )

    static let ontario = Region(
        id: "ON",
        name: "Ontario",
        subtitle: "Toronto",
        isoCode: "CA-ON",
        questionCount: 210,
        minPassScore: 80
    )

    static func createRegionRepository(
        regions: [Region] = [nsw, victoria, ontario]
    ) -> MockRegionRepository {
        MockRegionRepository(regions: regions)
    }
}

// MARK: - Mock RegionRepository

class MockRegionRepository: RegionRepository {
    var regionsToReturn: [Region]
    var shouldThrowError: RegionRepository.Error?
    var loadRegionsCalled = 0

    init(regions: [Region] = []) {
        self.regionsToReturn = regions
    }

    override func regions(for country: Country) async throws -> [Region] {
        loadRegionsCalled += 1

        if let error = shouldThrowError {
            throw error
        }

        return regionsToReturn.filter { region in
            (country == .australia && region.isoCode.starts(with: "AU")) ||
            (country == .canada && region.isoCode.starts(with: "CA"))
        }
    }
}

// MARK: - Async/await test helpers (XCTest-free, usable in production targets)

/// Waits for an async condition to become true, polling every `interval` seconds up to `timeout`.
/// Returns `true` if condition was met, `false` if timed out.
@discardableResult
func waitForCondition(
    timeout: TimeInterval = 2,
    interval: TimeInterval = 0.01,
    condition: @escaping () async -> Bool
) async -> Bool {
    let deadline = Date().addingTimeInterval(timeout)
    while Date() < deadline {
        if await condition() {
            return true
        }
        try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
    }
    return false
}

/// Waits for an async block to complete within the given timeout.
func waitForAsync(
    timeout: TimeInterval = 2,
    block: @escaping () async -> Void
) async {
    await withCheckedContinuation { continuation in
        let task = Task {
            await block()
            continuation.resume()
        }
        Task {
            try? await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
            task.cancel()
        }
    }
}

/// Polls a value until it matches the expected value or times out.
/// Returns `true` if the value matched within the timeout, `false` otherwise.
@discardableResult
func assertPublishedValue<T: Equatable>(
    getValue: @escaping () -> T,
    expectedValue: T,
    description: String = "",
    timeout: TimeInterval = 2
) async -> Bool {
    let deadline = Date().addingTimeInterval(timeout)
    while Date() < deadline {
        if getValue() == expectedValue {
            return true
        }
        try? await Task.sleep(nanoseconds: 10_000_000) // 10ms
    }
    return false
}