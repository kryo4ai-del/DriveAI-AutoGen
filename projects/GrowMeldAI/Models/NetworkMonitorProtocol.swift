// MARK: - Tests/Mocks/MockNetworkMonitor.swift

import Network
import Foundation

protocol NetworkMonitorProtocol {
  var isConnected: Bool { get }
  func startMonitoring()
  func stopMonitoring()
}
