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
            .flatMap { [weak self] _ -> AnyPublisher<[DebugInfo], Never> in
                guard let self else { return Just([]).eraseToAnyPublisher() }
                return self.debugDataService.retrieveDebugData()
            }
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { _ in }) { [weak self] logs in
                self?.debugLogs = logs
            }
            .store(in: &cancellables)
    }
}