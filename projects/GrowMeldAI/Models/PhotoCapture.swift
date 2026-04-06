import Foundation
import UIKit

struct PhotoCapture: Identifiable {
    let id: UUID
    let image: UIImage
    let timestamp: Date
    let fileSize: Int
    
    init(image: UIImage, timestamp: Date = Date()) {
        self.id = UUID()
        self.image = image
        self.timestamp = timestamp
        self.fileSize = image.jpegData(compressionQuality: 0.8)?.count ?? 0
    }
}