// TrialStorage.swift
import Foundation

/// Persistence layer for trial data
final class TrialStorage {
    static let shared = TrialStorage()

    private let userDefaults: UserDefaults
    private let storageKey = "com.driveai.trial.storage"

    private init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    // MARK: - Trial Status

    func saveTrialStatus(_ status: TrialStatus) throws {
        let data = try JSONEncoder().encode(status)
        userDefaults.set(data, forKey: "\(storageKey).status")
    }

    func loadTrialStatus() -> TrialStatus {
        guard let data = userDefaults.data(forKey: "\(storageKey).status") else {
            return .neverStarted
        }
        return (try? JSONDecoder().decode(TrialStatus.self, from: data)) ?? .neverStarted
    }

    // MARK: - Trial Period

    func saveTrialPeriod(_ period: TrialPeriod) throws {
        let data = try JSONEncoder().encode(period)
        userDefaults.set(data, forKey: "\(storageKey).period")
    }

    func loadTrialPeriod() -> TrialPeriod? {
        guard let data = userDefaults.data(forKey: "\(storageKey).period") else {
            return nil
        }
        return try? JSONDecoder().decode(TrialPeriod.self, from: data)
    }

    func deleteTrialPeriod() {
        userDefaults.removeObject(forKey: "\(storageKey).period")
    }

    // MARK: - Device Fingerprinting

    func hasDeviceUsedTrialBefore() -> Bool {
        userDefaults.bool(forKey: "\(storageKey).deviceUsedTrial")
    }

    func markDeviceAsUsedTrial() {
        userDefaults.set(true, forKey: "\(storageKey).deviceUsedTrial")
    }

    func resetAllTrialData() {
        let keys = [
            "\(storageKey).status",
            "\(storageKey).period",
            "\(storageKey).deviceUsedTrial"
        ]
        keys.forEach { userDefaults.removeObject(forKey: $0) }
    }
}