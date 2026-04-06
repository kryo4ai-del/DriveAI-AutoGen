final class CameraPerformanceMonitor {
    @Published var averageFPS: Double = 0
    @Published var droppedFrameCount: Int = 0
    
    func trackFrameCapture() { ... }
    func trackFrameDrop() { ... }
}