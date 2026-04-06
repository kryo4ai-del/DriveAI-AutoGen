// TimerService.swift
import Foundation
import Combine

protocol TimerServiceProtocol: ObservableObject {
    var elapsedSeconds: Int { get }
    var isRunning: Bool { get }
    var timeRemaining: Int { get }
    var timeRemainingFormatted: String { get }
    var progressPercentage: Double { get }

    func start(onExpired: (() -> Void)?)
    func pause()
    func resume()
    func finish()
}
