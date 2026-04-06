// Sources/Services/Backup/BackupScheduler.swift
import Foundation

final class BackupScheduler {
    private let service: BackupService
    private var timer: Timer?
    private let queue = DispatchQueue(label: "com.driveai.backup.scheduler")

    init(service: BackupService) {
        self.service = service
    }

    func scheduleAutoBackup(interval: TimeInterval) {
        stopAutoBackup()

        guard interval > 0 else { return }

        timer = Timer.scheduledTimer(
            withTimeInterval: interval,
            repeats: true
        ) { [weak self] _ in
            Task {
                do {
                    _ = try await self?.service.createBackup()
                } catch {
                    print("Auto-backup failed: \(error.localizedDescription)")
                }
            }
        }

        RunLoop.current.add(timer!, forMode: .common)
    }

    func stopAutoBackup() {
        timer?.invalidate()
        timer = nil
    }
}