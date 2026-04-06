import UIKit

// ✅ UIImage extension for memory estimation
extension UIImage {
    var estimatedMemorySize: Int {
        Int(size.width * size.height * scale * scale * 4)  // RGBA = 4 bytes
    }
}