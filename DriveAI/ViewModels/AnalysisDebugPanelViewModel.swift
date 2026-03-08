import SwiftUI
import Combine

class AnalysisDebugPanelViewModel: ObservableObject {
    @Published var debugLogs: [DebugInfo] = []
    private var cancellables = Set<AnyCancellable>()
    
    private let debugDataService: DebugDataService
    
    init(debugDataService: DebugDataService = DebugDataService()) {
        self.debugDataService = debugDataService
        startFetchingLogs()
    }
    
    func startFetchingLogs(every interval: TimeInterval = 2.0) {
        Timer.publish(every: interval, on: .main, in: .common)
            .autoconnect()
            .flatMap { _ in self.debugDataService.retrieveDebugData() }
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("Error fetching logs: \(error)") // Improved error handling
                case .finished:
                    break
                }
            }) { [weak self] logs in
                self?.debugLogs = logs
            }
            .store(in: &cancellables)
    }
}