import Foundation

struct CameraAccessRequest: Sendable {
    enum Source {
        case dashboard
        case learningModule
        case examPrep
    }
    
    let source: Source
    let context: String?  // Optional additional context
    let timestamp: Date
    
    init(source: Source, context: String? = nil) {
        self.source = source
        self.context = context
        self.timestamp = Date()
    }
}